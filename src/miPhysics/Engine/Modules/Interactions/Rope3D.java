package miPhysics;


/**
 * Rope interaction: rope-like interaction between two Mass elements.
 * When the distance is lower than the threshold distance, no force is applied.
 * When the distance is higher than the threshold distance, a viscoelastic force is applied.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */

// TODO: This is identical to the bubble algorithm : REFACTOR
// (but keep distinct versions in the model creation)

public class Rope3D extends Interaction {

    public Rope3D(double distance, double K_param, double Z_param) {
        super(distance, null, null);
        setType(interType.ROPE3D);
        m_K = K_param;
        m_Z = Z_param;
    }

    public void compute() {
        updateSquaredDist();
        if (m_distSquared > m_dRsquared)
            applyForces( - getElongation()* m_K - getRelativeVelocity() *  m_Z );
    }


    public int setParam(param p, double val ){
        switch(p){
            case STIFFNESS:
                this.m_K = val;
                return 0;
            case DAMPING:
                this.m_Z = val;
                return 0;
            case DISTANCE:
                this.changeDRest(val);
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
            case DISTANCE:
                return m_dRest;
            default:
                System.out.println("No " + p + " parameter found in " + this);
                return 0.;
        }
    }



}
