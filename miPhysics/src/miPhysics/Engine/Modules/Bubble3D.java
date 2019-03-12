package miPhysics;

/**
 * Bubble interaction: one Mat is enclosed within a certain radius of another Mat.
 * When the distance is greater than the radius, a viscoelastic force is applied.
 *
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Bubble3D extends Link {

    /**
     * Create the Bubble Link.
     * @param distance distance (radius) between both Mats.
     * @param K_param stiffness parameter.
     * @param Z_param damping parameter.
     * @param m1 first (enclosed) Mat module.
     * @param m2 second (enclosing) Mat module.
     */
    public Bubble3D(double distance, double K_param, double Z_param, Mat m1, Mat m2) {
        super(distance, m1, m2);
        setType(linkModuleType.Bubble3D);
        m_K = K_param;
        m_Z = Z_param;
    }

    /* (non-Javadoc)
     * Bubble interaction force algorithm.
     * @see physicalModelling.Link#compute()
     */
    public void compute() {
        updateEuclidDist();
        if (m_dist > m_dRest)
            applyForces( -(m_dist - m_dRest) * m_K - getVel() *  m_Z );
    }

}