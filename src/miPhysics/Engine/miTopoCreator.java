package miPhysics.Engine;
import java.util.*;

public class miTopoCreator extends PhyModel {

    private int m_dimX = 1;
    private int m_dimY = 1;
    private int m_dimZ = 1;

    private double m_M = 1;
    private double m_K = 0.01;
    private double m_Z = 0.001;
    private double m_size = 1;

    private double m_dist = 1;
    private double m_l0 = 1;

    private int m_neighbors = 1;
    private String m_mLabel = "m";
    private String m_iLabel = "i";

    //private String matSubName;
    //private String linkSubName;

    private boolean plane2D = false;
    private EnumSet<Bound> bCond;

    private boolean m_generated = false;

    public miTopoCreator(String name, Medium m){
        super(name, m);
        bCond = EnumSet.noneOf(Bound.class);

        System.out.println(bCond);
    }

    public void init(){
        super.init();
        if(!m_generated){
            System.out.println("The TopoCreator model has not yet been generated !");
            System.exit(-1);
        }
    }


    public void setMassRadius(double s){
        this.m_size = s;
    }

    public void setDim(int dx, int dy, int dz, int span) {
        m_dimX = dx;
        m_dimY = dy;
        m_dimZ = dz;
        m_neighbors = span;
    }

    public void set2DPlane(boolean val){
        plane2D = val;
    }

    public void setParams(double M, double K, double Z){
        m_M = M;
        m_K = K;
        m_Z = Z;
    }

    public void setGeometry(double d, double l) {
        m_dist = d;
        m_l0 = l;
    }


    public void generate() {

        String masName;
        Vect3D X0, U1;

        //int nbBefore = mdl.getNumberOfMasses();

        /*
        if(!matSubName.isEmpty())
            mdl.createMassSubset(matSubName);

        if(!linkSubName.isEmpty())
            mdl.createInteractionSubset(linkSubName);
        */

        System.out.println(this.getName() + ": creating mass elements with naming pattern: "
                + m_mLabel + "_[X]_[Y]_[Z]");


        for (int i = 0; i < m_dimX; i++) {
            for (int j = 0; j < m_dimY; j++) {
                for (int k = 0; k < m_dimZ; k++) {

                    X0 = new Vect3D(i*m_dist, j*m_dist, k*m_dist);

                    masName = m_mLabel + "_" +(i+"_"+j+"_"+k);

                    if(plane2D){
                        this.addMass(masName, new Mass2DPlane(m_M, m_size, X0));
                        //if(!matSubName.isEmpty())
                        //    mdl.addMassToSubset(tmp, matSubName);
                    }
                    else {
                        this.addMass(masName, new Mass3D(m_M, m_size, X0));
                        //if(!matSubName.isEmpty())
                        //    mdl.addMassToSubset(tmp, matSubName);
                    }
                    //System.out.println("Created mass: " + masName);
                }
            }
        }

        System.out.println(this.getName() + ": creating interaction elements with naming pattern: "
                + m_iLabel + "_[X1]_[Y1]_[Z1]_[X2]_[Y2]_[Z2]");

        // add the springs to the model: length, stiffness, connected mats
        String masName1, masName2;
        int idx = 0, idy = 0, idz = 0;

        for (int i = 0; i < m_dimX; i++) {
            for (int j = 0; j < m_dimY; j++) {
                for (int k = 0; k < m_dimZ; k++) {

                    //println("Looking at: " + mLabel +(i+"_"+j+"_"+k));
                    masName1 = m_mLabel + "_" +(i+"_"+j+"_"+k);

                    for (int l = 0; l < m_neighbors+1; l++) {
                        for (int m = - m_neighbors; m < m_neighbors+1; m++) {
                            for (int n = -m_neighbors; n < m_neighbors+1; n++) {
                                idx = i+l;
                                idy = j+m;
                                idz = k+n;

                                if((l==0) && (m<0) && (n < 0))
                                    break;

                                else if ((idx < m_dimX) && (idy < m_dimY) && (idz < m_dimZ)) {
                                    if ((idx>=0) && (idy>=0) && (idz>=0)) {
                                        if ((idx==i) && (idy == j) && (idz == k)) {
                                            //println("Superposed at same point" + idx + " " + idy + " " + idz);
                                            break;
                                        } else {

                                            U1 = new Vect3D(l, m, n);

                                            double d = U1.norm() * m_l0;

                                            //println("distance: " + d + ", " + l + " " + m + " " + n);

                                            masName2 = m_mLabel + "_" +(idx+"_"+idy+"_"+idz);
                                            String ln = m_iLabel + "_" + (i+"_"+j+"_"+k) + "_" + (idx+"_"+idy+"_"+idz) ;

                                            addInteraction(ln, new SpringDamper3D(d, m_K, m_Z), masName1, masName2);

                                            //if(!linkSubName.isEmpty())
                                            //    mdl.addInteractionToSubset(tmp, linkSubName);

                                            //System.out.println("Created interaction: " + ln);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        this.applyBoundaryConditions();

        m_generated = true;
    }

    public void addBoundaryCondition(Bound b) {
        bCond.add(b);
    }

    private void applyBoundaryConditions() {

        if (bCond.contains(Bound.X_LEFT)) {
            for (int j = 0; j < m_dimY; j++) {
                for (int k = 0; k < m_dimZ; k++) {
                    String name = m_mLabel + ("_0_"+j+"_"+k);
                    this.changeToFixedPoint(name);
                }
            }
        }
        if (bCond.contains(Bound.X_RIGHT)) {
            for (int j = 0; j < m_dimY; j++) {
                for (int k = 0; k < m_dimZ; k++) {
                    String name = m_mLabel + ("_" + (m_dimX-1) + "_"+j+"_"+k);
                    this.changeToFixedPoint(name);
                }
            }
        }

        if (bCond.contains(Bound.Y_LEFT)) {
            for (int i = 0; i < m_dimX; i++) {
                for (int k = 0; k < m_dimZ; k++) {
                    String name = m_mLabel + ("_" + i + "_"+0+"_"+k);
                    this.changeToFixedPoint(name);
                }
            }
        }
        if (bCond.contains(Bound.Y_RIGHT)) {
            for (int i = 0; i < m_dimX; i++) {
                for (int k = 0; k < m_dimZ; k++) {
                    String name = m_mLabel + ("_" + i + "_"+(m_dimY-1)+"_"+k);
                    this.changeToFixedPoint(name);
                }
            }
        }

        if (bCond.contains(Bound.Z_LEFT)) {
            for (int i = 0; i < m_dimX; i++) {
                for (int j = 0; j < m_dimY; j++) {
                    String name = m_mLabel + ("_" + i + "_"+j+"_"+0);
                    this.changeToFixedPoint(name);
                }
            }
        }
        if (bCond.contains(Bound.Z_RIGHT)) {
            for (int i = 0; i < m_dimX; i++) {
                for (int j = 0; j < m_dimY; j++) {
                    String name = m_mLabel + ("_" + i + "_"+j+"_"+(m_dimZ-1));
                    this.changeToFixedPoint(name);
                }
            }
        }

        if (bCond.contains(Bound.FIXED_CORNERS)) {

            for (int i = 0; i < 2; i++) {
                for (int j = 0; j < 2; j++) {
                    for (int k = 0; k < 2; k++) {
                        String name = m_mLabel + ("_" + (i*(m_dimX-1)) + "_"+(j*(m_dimY-1))+"_"+(k*(m_dimZ-1)));
                        this.changeToFixedPoint(name);
                    }
                }
            }
        }

        if (bCond.contains(Bound.FIXED_CENTRE)) {

            String name = m_mLabel + ("_" + (Math.floor(m_dimX/2)) + "_"+(Math.floor(m_dimY/2))+"_"+(Math.floor(m_dimZ/2)));
            this.changeToFixedPoint(name);
        }
    }

    public int setParam(param p, double val ){
        switch(p){
            case MASS:
                this.m_M = val;
                break;
            case RADIUS:
                this.m_size = val;
                break;
            case STIFFNESS:
                this.m_K = val;
                break;
            case DAMPING:
                this.m_Z = val;
                break;
            default:
                System.out.println("Cannot apply param " + val + " for "
                        + this + ": no " + p + " parameter");
                break;
        }
        for(Mass o : m_masses)
            o.setParam(p, val);
        for(Interaction i : m_interactions)
            i.setParam(p, val);
        return 0;
    }

    public double getParam(param p){
        switch(p){
            case MASS:
                return this.m_M;
            case RADIUS:
                return this.m_size;
            case STIFFNESS:
                return this.m_K;
            case DAMPING:
                return this.m_Z;
            default:
                System.out.println("No " + p + " parameter found in " + this);
                return 0.;
        }
    }
}