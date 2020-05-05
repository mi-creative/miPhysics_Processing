package miPhysics.Engine;

/**
 * Bubble interaction: one Mass is enclosed within a certain radius of another Mass.
 * When the distance is greater than the radius, a viscoelastic force is applied.
 *
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Bubble3D extends Interaction {
    private boolean prev_state = false;
    /**
     * Create the Bubble Interaction.
     * @param distance distance (radius) between both Mats.
     * @param K_param stiffness parameter.
     * @param Z_param damping parameter.
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
        m_distSquared = m_mat1.m_pos.sqDist(m_mat2.m_pos);

        if (m_distSquared > m_dRsquared) {
            // Only recalcultate the previous distance if the contact was inactive in previous step
            // otherwise it is automatically updated at the end of the cycle.
            m_dist = Math.sqrt(m_distSquared);
            if(!prev_state)
                m_prevDist = m_mat1.m_posR.dist(m_mat2.m_posR);
            applyForcesAndShift(-(m_dist - m_dRest) * m_K - (m_dist - m_prevDist) * m_Z);
            prev_state = true;
        }
        else prev_state = false;
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