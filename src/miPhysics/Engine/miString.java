package miPhysics.Engine;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * A basic integrated string class.
 */
public class miString extends PhyModel {

    double m_K;
    double m_Z;
    double m_invM;
    double m_size;
    double m_len;
    double m_dist;

    public miString(String name, Medium m, int len, float size, double M, double K, double Z, double dist, double l0){
        this(name, m, len, size, M, K, Z, dist, l0, "3D");
    }


    public miString(String name, Medium m, int len, float size, double M, double K, double Z, double dist, double l0, String twoD){
        super(name, m);
        m_len  = len;
        m_size = size;
        m_K = K;
        m_invM = 1/M;
        m_Z = Z;
        m_dist  = dist;

        // Quick hack: a placeholder module to keep the compiler happy.
        Mass prev = new Ground3D(1, new Vect3D());

        System.out.println(this.getName() + ": creating mass elements with naming pattern: "
                + "m_[i]");
        System.out.println(this.getName() + ": creating mass elements with naming pattern: "
                + "i_[i]");

        // should definitely to some try catching in here...
        for(int i = 0; i < len; i++) {
            Mass tmp;
            if(twoD.equals("2D"))
                tmp = new Mass2DPlane(M, size, new Vect3D(0,0,i*dist), new Vect3D(0,0,i*dist));
            else
                tmp = new Mass3D(M, size, new Vect3D(0,0,i*dist), new Vect3D(0,0,i*dist));

            tmp.setName("m_"+i);
            tmp.setMedium(m_medium);
            this.m_masses.add(tmp);
            this.m_massLabels.put(tmp.getName(), tmp);
            if(i>0){
                SpringDamper3D inter = new SpringDamper3D(l0, K, Z);
                inter.setName("i_"+(i-1));
                inter.connect(prev, tmp);
                this.m_interactions.add(inter);
                this.m_intLabels.put(inter.getName(), inter);
            }
            prev = tmp;
        }
    }


    /*
    public Proxy3D createProxy(double r){
        m_proxyList.add(new )
    }
    */


    public int setParam(param p, double val ){
        switch(p){
            case MASS:
                this.m_invM = 1./val;
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
                return 1./this.m_invM;
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

    //private ArrayList<Proxy3D> m_proxyList = new ArrayList<>();
}
