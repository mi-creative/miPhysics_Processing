package miPhysics;


/**
 * Attraction interaction: distant pull between two Mat elements.
 * Experimental implementation !
 *
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Attractor3D extends Link {

    /**
     * @param distance
     * @param thresh dist
     * @param attraction force
     * @param m1
     * @param m2
     */
    public Attractor3D(double limitDist, double attrFactor, Mat m1, Mat m2) {
        super(limitDist, m1, m2);
        setType(linkModuleType.Attractor3D);
        m_attrFactor = attrFactor;
    }

    public void compute() {

        updateEuclidDist();
        if(m_dist > m_dRest)
            this.applyForces(-m_attrFactor / (m_dist*m_dist));
    }

    /***
     * This will actually set the attractor force value
     * @param stiff
     * @return
     */
    public boolean changeStiffness(double stiff){
        m_attrFactor = stiff;
        return true;
    }

    /***
     * There is no damping parameter for this interaction.
     * @param damp
     * @return
     */
    public boolean changeDamping(double damp){
        return false;
    }

    /* Reimplement in order to store squared distance */
    public boolean changeDRest(double d) {
        //m_dRest = d;
        //m_dRsquared = m_dRest * m_dRest;
        return false;
    }

    private double m_attrFactor;
}