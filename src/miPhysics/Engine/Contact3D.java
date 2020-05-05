package miPhysics.Engine;


/**
 * Contact interaction: collision between two Mass elements.
 * When the distance is lower than the threshold distance, a viscoelastic force is applied.
 *
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Contact3D extends Interaction {

    // Monitor if this contact was previously active!
    private boolean prev_state = false;
    //private double dist;
    //private double prev_dist;

    private double interSize;
    /**
     * A conctact interaction defined between two points
     * @param K_param the stiffness of the collision interaction.
     * @param Z_param the damping of the collision interaction.
     */
    public Contact3D(double K_param, double Z_param) {
        super(0, null, null);
        setType(interType.CONTACT3D);
        m_K = K_param;
        m_Z = Z_param;
    }

    public void compute() {

        m_distSquared = m_mat1.m_pos.sqDist(m_mat2.m_pos);
        interSize = m_mat1.m_size + m_mat2.m_size;

        if (m_distSquared < (interSize * interSize)) {
            // Only recalcultate the previous distance if the contact was inactive in previous step
            // otherwise it is automatically updated at the end of the cycle.
            m_dist = Math.sqrt(m_distSquared);
            if(!prev_state)
                m_prevDist = m_mat1.m_posR.dist(m_mat2.m_posR);
            applyForcesAndShift(-(m_dist - interSize) * m_K - (m_dist - m_prevDist) * m_Z);
            prev_state = true;
        }
        else prev_state = false;
    }

    protected void forceRecalculateVelocity(){
        prev_state = false;
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