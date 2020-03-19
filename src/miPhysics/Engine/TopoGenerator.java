package miPhysics.Engine;
import java.util.*;



public class TopoGenerator {


    public TopoGenerator(PhysicalModel model, String mn, String ln) {
        dimX = 1;
        dimY = 1;
        dimZ = 1;

        mLabel = mn;
        iLabel = ln;

        mdl = model;

        plane2D = false;

        matSubName = "";
        linkSubName = "";

        radius = 0;

        bCond = EnumSet.noneOf(Bound.class);
        bCond.removeAll(EnumSet.of(Bound.X_LEFT, Bound.FIXED_CENTRE)); // disable a couple

        System.out.println(bCond);
    }

    public void setMassRadius(double s){
        this.radius = s;
    }

    public void setDim(int dx, int dy, int dz, int span) {
        dimX = dx;
        dimY = dy;
        dimZ = dz;
        neighbors = span;
    }

    public void set2DPlane(boolean val){
        plane2D = val;
    }


    public void setParams(double mParam, double kParam, double zParam) {
        M = mParam;
        K = kParam;
        Z = zParam;
    }

    public void setGeometry(double d, double l) {
        dist = d;
        l0 = l;
    }

    public void setRotation(float x, float y, float z){
        rotX = x;
        rotY = y;
        rotZ = z;
    }

    public void setTranslation(float x, float y, float z){
        tX = x;
        tY = y;
        tZ = z;
    }

    public void setMatSubsetName(String name){
        matSubName = name;
    }

    public void setLinkSubsetName(String name){
        linkSubName = name;
    }


    public void generate() {

        String masName;
        Vect3D X0, V0, U1;

        int nbBefore = mdl.getNumberOfMasses();

        if(!matSubName.isEmpty())
            mdl.createMassSubset(matSubName);

        if(!linkSubName.isEmpty())
            mdl.createInteractionSubset(linkSubName);

        for (int i = 0; i < dimX; i++) {
            for (int j = 0; j < dimY; j++) {
                for (int k = 0; k < dimZ; k++) {

                    V0 = new Vect3D(0., 0., 0.);
                    X0 = new Vect3D(i*dist, j*dist, k*dist);

                    masName = mLabel + "_" +(i+"_"+j+"_"+k);

                    if(plane2D){
                        Mass2DPlane tmp = mdl.addMass(masName, new Mass2DPlane(M, radius, X0));
                        if(!matSubName.isEmpty())
                            mdl.addMassToSubset(tmp, matSubName);
                    }
                    else {
                        Mass3D tmp = mdl.addMass(masName, new Mass3D(M, radius, X0));
                        if(!matSubName.isEmpty())
                            mdl.addMassToSubset(tmp, matSubName);
                    }
                    System.out.println("Created mass: " + masName);
                }
            }
        }

        // add the springs to the model: length, stiffness, connected mats
        String masName1, masName2;
        int idx = 0, idy = 0, idz = 0;

        for (int i = 0; i < dimX; i++) {
            for (int j = 0; j < dimY; j++) {
                for (int k = 0; k < dimZ; k++) {

                    //println("Looking at: " + mLabel +(i+"_"+j+"_"+k));
                    masName1 = mLabel + "_" +(i+"_"+j+"_"+k);

                    for (int l = 0; l < neighbors+1; l++) {
                        for (int m = -neighbors; m < neighbors+1; m++) {
                            for (int n = -neighbors; n < neighbors+1; n++) {
                                idx = i+l;
                                idy = j+m;
                                idz = k+n;

                                if((l==0) && (m<0) && (n < 0))
                                    break;

                                else if ((idx < dimX) && (idy < dimY) && (idz < dimZ)) {
                                    if ((idx>=0) && (idy>=0) && (idz>=0)) {
                                        if ((idx==i) && (idy == j) && (idz == k)) {
                                            //println("Superposed at same point" + idx + " " + idy + " " + idz);
                                            break;
                                        } else {

                                            U1 = new Vect3D(l, m, n);

                                            double d = U1.norm() * l0;

                                            //println("distance: " + d + ", " + l + " " + m + " " + n);

                                            masName2 = mLabel + "_" +(idx+"_"+idy+"_"+idz);
                                            String ln = iLabel + "_" + (i+"_"+j+"_"+k) + "_" + (idx+"_"+idy+"_"+idz) ;

                                            SpringDamper3D tmp = mdl.addInteraction(ln, new SpringDamper3D(d, K, Z), masName1, masName2);

                                            if(!linkSubName.isEmpty())
                                                mdl.addInteractionToSubset(tmp, linkSubName);

                                            System.out.println("Created interaction: " + ln);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }


        this.translateAndRotate(nbBefore, tX, tY, tZ, rotX, rotY, rotZ);
        this.applyBoundaryConditions();
    }

    public void addBoundaryCondition(Bound b) {
        bCond.add(b);
    }

    private void applyBoundaryConditions() {

        if (bCond.contains(Bound.X_LEFT)) {
            for (int j = 0; j < dimY; j++) {
                for (int k = 0; k < dimZ; k++) {
                    String name = mLabel + ("_0_"+j+"_"+k);
                    mdl.changeToFixedPoint(name);
                }
            }
        }
        if (bCond.contains(Bound.X_RIGHT)) {
            for (int j = 0; j < dimY; j++) {
                for (int k = 0; k < dimZ; k++) {
                    String name = mLabel + ("_" + (dimX-1) + "_"+j+"_"+k);
                    mdl.changeToFixedPoint(name);
                }
            }
        }

        if (bCond.contains(Bound.Y_LEFT)) {
            for (int i = 0; i < dimX; i++) {
                for (int k = 0; k < dimZ; k++) {
                    String name = mLabel + ("_" + i + "_"+0+"_"+k);
                    mdl.changeToFixedPoint(name);
                }
            }
        }
        if (bCond.contains(Bound.Y_RIGHT)) {
            for (int i = 0; i < dimX; i++) {
                for (int k = 0; k < dimZ; k++) {
                    String name = mLabel + ("_" + i + "_"+(dimY-1)+"_"+k);
                    mdl.changeToFixedPoint(name);
                }
            }
        }

        if (bCond.contains(Bound.Z_LEFT)) {
            for (int i = 0; i < dimX; i++) {
                for (int j = 0; j < dimY; j++) {
                    String name = mLabel + ("_" + i + "_"+j+"_"+0);
                    mdl.changeToFixedPoint(name);
                }
            }
        }
        if (bCond.contains(Bound.Z_RIGHT)) {
            for (int i = 0; i < dimX; i++) {
                for (int j = 0; j < dimY; j++) {
                    String name = mLabel + ("_" + i + "_"+j+"_"+(dimZ-1));
                    mdl.changeToFixedPoint(name);
                }
            }
        }

        if (bCond.contains(Bound.FIXED_CORNERS)) {

            for (int i = 0; i < 2; i++) {
                for (int j = 0; j < 2; j++) {
                    for (int k = 0; k < 2; k++) {
                        String name = mLabel + ("_" + (i*(dimX-1)) + "_"+(j*(dimY-1))+"_"+(k*(dimZ-1)));
                        mdl.changeToFixedPoint(name);
                    }
                }
            }
        }

        if (bCond.contains(Bound.FIXED_CENTRE)) {

            String name = mLabel + ("_" + (Math.floor(dimX/2)) + "_"+(Math.floor(dimY/2))+"_"+(Math.floor(dimZ/2)));
            mdl.changeToFixedPoint(name);
        }
    }

    public void conditionAlongSphere(double radius, boolean ext) {

        Vect3D test = new Vect3D(0, 0, 0);
        Vect3D test2 = new Vect3D(0, 0, 0);
        String name = mLabel + ("_" + (Math.floor(dimX/2)) + "_"+(Math.floor(dimY/2))+"_"+(Math.floor(dimZ/2)));



        test = new Vect3D((dimX-1)*dist/2., (dimY-1)*dist/2., (dimZ-1)*dist/2.); //
        //test = mdl.getMatPosition(name);


        System.out.println("");
        System.out.println("Reference mass : " + name +", " + test.x +" " + test.y + " " + test.z);
        System.out.println("");

        ArrayList<Mass> toRemove = new ArrayList<Mass>();

        for (int i = 0; i < mdl.getNumberOfMasses(); i++) {

            Mass tmp = mdl.getMassList().get(i);
            test2 = tmp.getPos();
            String mName = tmp.getName();
            //test2 = mdl.getMatPosAt(i);

            System.out.println("Iteration mass : " + mName +", " + test2.x +" " + test2.y + " " + test2.z);
            System.out.println("distance: " + test2.dist(test));

            if (ext) {
                if (test.dist(test2) > radius) {
                    System.out.println("Adding to remove list: " + mName);
                    toRemove.add(tmp);
                }
            } else {
                if (test.dist(test2) < radius) {
                    System.out.println("Adding to remove list: " + mName);
                    toRemove.add(tmp);
                }
            }
            System.out.println("");
        }

        while (toRemove.size()>0) {
            Mass m = toRemove.remove(toRemove.size()-1);
            System.out.println("Mass to remove: " + m + ", " + m.getName());
            mdl.removeMassAndConnectedInteractions(m);
        }
    }



    // Currently a problem with rotations along Y and Z, need to sort this...
    private void translateAndRotate(int nbBefore, float tx, float ty, float tz, float x_angle, float y_angle, float z_angle){

        Vect3D mdlPos;

        Vect3D offset = new Vect3D();

        double cosa = Math.cos(x_angle);
        double sina = Math.sin(x_angle);

        double cosb = Math.cos(y_angle);
        double sinb = Math.sin(y_angle);

        double cosc = Math.cos(z_angle);
        double sinc = Math.sin(z_angle);

        double Axx = cosa*cosb;
        double Axy = cosa*sinb*sinc - sina*cosc;
        double Axz = cosa*sinb*cosc + sina*sinc;

        double Ayx = sina*cosb;
        double Ayy = sina*sinb*sinc + cosa*cosc;
        double Ayz = sina*sinb*cosc - cosa*sinc;

        double Azx = -sinb;
        double Azy = cosb*sinc;
        double Azz = cosb*cosc;

        offset.x = 0.5 * ((dimX-1) * dist);
        offset.y = 0.5 * ((dimY-1) * dist);
        offset.z = 0.5 * ((dimZ-1) * dist);

        Vect3D v = new Vect3D();

        for (int i = nbBefore; i < mdl.getNumberOfMats(); i++) {

            Mass tmp = mdl.getMassList().get(i);
            mdlPos = tmp.getPos();

            System.out.println("Input pos: " + mdlPos);

            mdlPos.x -= offset.x;
            mdlPos.y -= offset.y;
            mdlPos.z -= offset.z;

            v.x = Axx*mdlPos.x + Axy*mdlPos.y + Axz*mdlPos.z;
            v.y = Ayx*mdlPos.x + Ayy*mdlPos.y + Ayz*mdlPos.z;
            v.z = Azx*mdlPos.x + Azy*mdlPos.y + Azz*mdlPos.z;

            System.out.println("Position: " + v);

            mdlPos.x += offset.x + tx;
            mdlPos.y += offset.y + ty;
            mdlPos.z += offset.z + tz;

            tmp.setPos(v);
        }
    }


    private int dimX;
    private int dimY;
    private int dimZ;

    private double M;
    private double K;
    private double Z;

    private double dist;
    private double l0;

    private double radius;

    private int neighbors;
    private String mLabel;
    private String iLabel;

    private float rotX;
    private float rotY;
    private float rotZ;

    private float tX;
    private float tY;
    private float tZ;

    private String matSubName;
    private String linkSubName;

    private boolean plane2D ;

    private EnumSet<Bound> bCond;

    private PhysicalModel mdl;
}
