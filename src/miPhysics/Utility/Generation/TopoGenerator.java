package miPhysics;
import java.util.*;



public class TopoGenerator {


    public TopoGenerator(PhysicalModel model, String mn, String ln) {
        dimX = 1;
        dimY = 1;
        dimZ = 1;

        mLabel = mn;
        iLabel = ln;

        mdl = model;

        rotX = rotY = rotZ = 0;
        tX = tY = tZ = 0;

        plane2D = false;

        bCond = EnumSet.noneOf(Bound.class);
        //bCond.addAll(EnumSet.range(Bound.X_LEFT, Bound.Z_RIGHT)); // enable all constants
        bCond.removeAll(EnumSet.of(Bound.X_LEFT, Bound.FIXED_CENTRE)); // disable a couple
        //assert EnumSet.of(Bound.X_LEFT, Bound.Z_RIGHT).equals(bCond); // check set contents are correct

        System.out.println(bCond);
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


    public void generate() {

        String masName;
        Vect3D V0, U1;

        int nbBefore = mdl.getNumberOfMats();

        for (int i = 0; i < dimX; i++) {
            for (int j = 0; j < dimY; j++) {
                for (int k = 0; k < dimZ; k++) {

                    V0 = new Vect3D(0., 0., 0.);

                    masName = mLabel + "_" +(i+"_"+j+"_"+k);

                    if(plane2D){
                    mdl.addMass2DPlane(masName, M, new Vect3D(i*dist,
                                                         j*dist,
                                                         k*dist),
                                                         V0);}
                    else {mdl.addMass3D(masName, M, new Vect3D(i*dist,
                                    j*dist,
                                    k*dist),
                            V0);}
                    System.out.println("Created mass: " + masName);
                }
            }
        }

        // add the spring to the model: length, stiffness, connected mats
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
                                            mdl.addSpringDamper3D(mLabel + "1_" +i+j+k, d, K, Z, masName1, masName2);
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

        /*for (int i = 0; i < dimX; i++) {
            for (int j = 0; j < dimY; j++) {
                for (int k = 0; k < dimZ; k++) {

                    //println("Looking at: " + mLabel +(i+"_"+j+"_"+k));
                    masName1 = mLabel + "_" +(i+"_"+j+"_"+k);

                    for (int l = -neighbors; l < neighbors+1; l++) {
                        for (int m = -neighbors; m < neighbors+1; m++) {
                            for (int n = -neighbors; n < neighbors+1; n++) {
                                idx = i+l;
                                idy = j+m;
                                idz = k+n;

                                if ((idx < dimX) && (idy < dimY) && (idz < dimZ)) {
                                    if ((idx>=0) && (idy>=0) && (idz>=0)) {
                                        if ((l==i) && (j == m) && (n == k)) {
                                            break;
                                        } else {

                                            U1 = new Vect3D(l, m, n);

                                            double d = U1.norm() * l0;

                                            masName2 = mLabel + "_" +(idx+"_"+idy+"_"+idz);
                                            String ln = iLabel + "_" + (i+"_"+j+"_"+k) + "_" + (idx+"_"+idy+"_"+idz) ;
                                            mdl.addSpringDamper3D(mLabel + "1_" +i+j+k, d, K, Z, masName1, masName2);
                                            System.out.println("Created interaction: " + ln);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }*/

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

        ArrayList<Integer> toRemove = new ArrayList<Integer>();

        for (int i = 0; i < mdl.getNumberOfMats(); i++) {


            test2 = mdl.getMatPosAt(i);

            System.out.println("Iteration mass : " + mdl.getMatNameAt(i) +", " + test2.x +" " + test2.y + " " + test2.z);
            System.out.println("distance: " + test2.dist(test));

            if (ext == true) {
                if (test.dist(test2) > radius) {
                    System.out.println("Adding to remove list: " + mdl.getMatNameAt(i));
                    toRemove.add(i);
                }
            } else {
                if (test.dist(test2) < radius) {
                    System.out.println("Adding to remove list: " + mdl.getMatNameAt(i));
                    toRemove.add(i);
                }
            }
            System.out.println("");
        }

        while (toRemove.size()>0) {
            int index = toRemove.remove(toRemove.size()-1);
            System.out.println("index to remove: " + index + ", " + mdl.getMatNameAt(index));
            mdl.removeMatAndConnectedLinks(index);
        }
    }



    // Currently a problem with rotations along Y and Z, need to sort this...
    private void translateAndRotate(int nbBefore, float tx, float ty, float tz, float x_angle, float y_angle, float z_angle){

        Vect3D newPos = new Vect3D();
        Vect3D mdlPos = new Vect3D();

        for (int i = nbBefore; i < mdl.getNumberOfMats(); i++) {


            mdlPos = mdl.getMatPosAt(i);

            newPos.set(mdlPos);

            // x rotation
            newPos.x = newPos.x;
            newPos.y = newPos.y * Math.cos(x_angle) - newPos.z * Math.sin(x_angle);
            newPos.z = newPos.y * Math.sin(x_angle) + newPos.z * Math.cos(x_angle);

            // y rotation
            newPos.x = newPos.x * Math.cos(y_angle) + newPos.z * Math.sin(y_angle);
            newPos.y = newPos.y;
            newPos.z = newPos.z * Math.cos(y_angle) - newPos.x * Math.sin(y_angle);

            // z rotation
            newPos.x = newPos.x * Math.cos(z_angle) - newPos.y * Math.sin(z_angle);
            newPos.y = newPos.x * Math.sin(z_angle) + newPos.y * Math.cos(z_angle);
            newPos.z = newPos.z;

            newPos.x += tx;
            newPos.y += ty;
            newPos.z += tz;


            mdl.setMatPosAt(i, newPos);
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

    private int neighbors;
    private String mLabel;
    private String iLabel;

    private float rotX;
    private float rotY;
    private float rotZ;

    private float tX;
    private float tY;
    private float tZ;

    private boolean plane2D ;

    private EnumSet<Bound> bCond;

    private PhysicalModel mdl;
}
