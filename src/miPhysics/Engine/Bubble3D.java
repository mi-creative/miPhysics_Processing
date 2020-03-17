package miPhysics.Engine;

/**
 * Bubble interaction: one Mass is enclosed within a certain radius of another Mass.
 * When the distance is greater than the radius, a viscoelastic force is applied.
 *
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Bubble3D extends Interaction {

    /**
     * Create the Bubble Interaction.
     * @param distance distance (radius) between both Mats.
     * @param K_param stiffness parameter.
     * @param Z_param damping parameter.
     * @param m1 first (enclosed) Mass module.
     * @param m2 second (enclosing) Mass module.
     */
    public Bubble3D(double distance, double K_param, double Z_param) {
        super(distance, null, null);
        setType(interType.BUBBLE3D);
        m_K = K_param;
        m_Z = Z_param;
    }

    /* (non-Javadoc)
     * Bubble interaction force algorithm.
     * @see physicalModelling.Interaction#compute()
     */
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