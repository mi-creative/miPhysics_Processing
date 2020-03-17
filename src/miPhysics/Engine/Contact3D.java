package miPhysics.Engine;


/**
 * Contact interaction: collision between two Mass elements.
 * When the distance is lower than the threshold distance, a viscoelastic force is applied.
 *
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Contact3D extends Interaction {

    /**
     * @param distance
     * @param K_param
     * @param Z_param
     * @param m1
     * @param m2
     */
    public Contact3D(double K_param, double Z_param) {
        super(0, null, null);
        setType(interType.CONTACT3D);
        m_K = K_param;
        m_Z = Z_param;
    }

    public void compute() {
        updateSquaredDist();
        if (m_distSquared < this.interRadiusSquared())
            this.applyForces( - getInterpenetration() * m_K - getRelativeVelocity() *  m_Z  );
    }

    public int setParam(param p, double val ){
        switch(p){
            case STIFFNESS:
                this.m_K = val;
                return 0;
            case DAMPING:
                this.m_Z = val;
                return 0;
            default:
                System.out.println("Cannot apply param " + val + " for "
                        + this + ": no " + p + " parameter");
                return -1;
        }
    }

    public double getParam(param p){
        switch(p){
            case STIFFNESS:
                return m_K;
            case DAMPING:
                return m_Z;
            default:
                System.out.println("No " + p + " parameter found in " + this);
                return 0.;
        }
    }

}