package miPhysics;


/* LINK abstract class */

/**
 * Abstract Link class.
 * Defines generic structure and behavior for all possible Links.
 *
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public abstract class Link {

    /**
     * Constructor method.
     * @param distance resting distance of the Link.
     * @param m1 connected Mat at one end.
     * @param m2 connected Mat at other end.
     */
    public Link(double distance, Mat m1, Mat m2) {
        m_dRest = distance;
        m_mat1 = m1;
        m_mat2 = m2;
        m_type = linkModuleType.UNDEFINED;

        m_K = 0;
        m_Z = 0;

        m_invDist = 0;
    }

    /**
     * Compute behavior of the Link (depends on the concrete implementation of concerned module).
     *
     */
    public abstract void compute();

    /**
     * Connect the Link to two Mat modules.
     * @param m1 connected Mat at one end.
     * @param m2 connected Mat at other end.
     */
    public void connect (Mat m1, Mat m2) {
        m_mat1 = m1;
        m_mat2 = m2;
    }

    /**
     * Access the first Mat connected to this Link.
     * @return the first Mat module.
     */
    public Mat getMat1() {
        return m_mat1;
    }

    /**
     * Access the second Mat connected to this Link.
     * @return the second Mat module.
     */
    public Mat getMat2() {
        return m_mat2;
    }

    /**
     * Get the m_type of the Link module.
     * @return the Link module m_type.
     */
    protected linkModuleType getType(){
        return m_type;
    }


    /**
     * Set the m_type of the Link module.
     * @param t the Link module m_type.
     */
    protected void setType(linkModuleType t){
        m_type = t;
    }

    /**
     * Initialise distance and delayed distance for this Link.
     *
     */
    protected void initDistances() {
        m_dist = m_mat1.getPos().dist(m_mat2.getPos());
        m_distR = m_mat1.getPosR().dist(m_mat2.getPosR());
    }

    /**
     * Calculate the euclidian distance between both Mats connected to this Link.
     * @return
     */
    protected double updateEuclidDist() {
        m_distR = m_dist;
        m_dist = m_mat1.getPos().dist(m_mat2.getPos());
        return m_dist;
    }

    protected double calcSquaredDist() {
        return m_mat1.getPos().sqDist(m_mat2.getPos());
    }

    // Experimental stuff
    protected double calcDelayedDistance() {
        return m_mat1.getPosR().dist(m_mat2.getPosR());
    }

    protected double getDx() {
        return m_mat1.getPos().x - m_mat2.getPos().x;
    }

    protected double getDy() {
        return m_mat1.getPos().y - m_mat2.getPos().y;
    }

    protected double getDz() {
        return m_mat1.getPos().z - m_mat2.getPos().z;
    }


    protected double calcDist1D() {
        return (m_mat1.getPos().z - m_mat2.getPos().z);
    }


///**
// * Set the distance stored inside the link (and apply previous one to delayed distance).
// * @param d distance to apply.
// */
//protected void updateDistManual(double d) {
//    distR = dist;
//    dist = d;
//  }
//


    /**
     * Change resting distance for this Link.
     * @param d new resting distance.
     *  @return true if succesfully changed
     */
    public boolean changeDRest(double d) {
        m_dRest = d;
        return true;
    }

    /**
     * Change the stiffness of this Link.
     * @param k stiffness value.
     * @return true if succesfully changed
     */
    public boolean changeStiffness(double k) {m_K = k; return true;}

    /**
     * Change the damping of this Link.
     * @param z the damping value.
     * @return true if succesfully changed
     */
    public boolean changeDamping(double z){m_Z = z; return true;}

    /**
     * Get the stiffness of this link element
     * @return the stiffness parameter
     */
    public double getStiffness(){return m_K;}

    /**
     * Get the damping of this link element
     * @return the damping parameter
     */
    public double getDamping(){return m_Z;}

    /**
     * Get delayed velocity (per sample) between the two connected Mat modules
     * @return per sample velocity value.
     */
    protected double getVel() {
        return m_dist - m_distR;
    }

    /**
     * Get the distance between mat modules connected by the link
     * @return distance value.
     */
    protected double getDist() {
        return m_dist;
    }

    /**
     * Get the elongation (distance minus resting length between mat modules connected by the link
     * @return elongation value.
     */
    protected double getElong() {
        return getDist() - m_dRest;
    }

    /**
     * Apply forces to the connected Mat modules
     * @param lnkFrc force to apply symetrically.
     */
    protected void applyForces(double lnkFrc) {

        m_invDist = 1 / m_dist;

        double x_proj = (getMat1().m_pos.x - getMat2().m_pos.x) * m_invDist;
        double y_proj = (getMat1().m_pos.y - getMat2().m_pos.y) * m_invDist;
        double z_proj = (getMat1().m_pos.z - getMat2().m_pos.z) * m_invDist;

        getMat1().m_frc.x += lnkFrc * x_proj;
        getMat1().m_frc.y += lnkFrc * y_proj;
        getMat1().m_frc.z += lnkFrc * z_proj;

        getMat2().m_frc.x -= lnkFrc * x_proj;
        getMat2().m_frc.y -= lnkFrc * y_proj;
        getMat2().m_frc.z -= lnkFrc * z_proj;
    }

    protected void applyForces(Vect3D frcVect) {
        getMat1().m_frc.add(frcVect);
        getMat2().m_frc.sub(frcVect);
    }

    protected void applyForces1D(double lnkFrc) {
        getMat2().m_frc.z += lnkFrc;
        getMat1().m_frc.z -= lnkFrc;
    }

    /* Class attributes */
    private linkModuleType m_type;
    private Mat m_mat1;
    private Mat m_mat2;


    protected double m_dist;
    protected double m_distR;
    protected double m_dRest;

    protected double m_K;
    protected double m_Z;

    private double m_invDist;

    //protected double m_linkFrc;
}