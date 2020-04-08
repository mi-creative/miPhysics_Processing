package miPhysics.Engine;


/* LINK abstract class */

/**
 * Abstract Interaction class.
 * Defines generic structure and behavior for all possible Links.
 *
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public abstract class Interaction extends Module {

    /**
     * Constructor method.
     * @param distance resting distance of the Interaction.
     * @param m1 connected Mass at one end.
     * @param m2 connected Mass at other end.
     */
    public Interaction(double distance, Mass m1, Mass m2) {
        // Init the resting distance and squared resting distance
        m_dRest = distance;
        m_dRsquared = m_dRest * m_dRest;

        m_mat1 = m1;
        m_mat2 = m2;

        m_type = interType.UNDEFINED;

        m_K = 0;
        m_Z = 0;
    }

    /**
     * Compute behavior of the Interaction (depends on the concrete implementation of concerned module).
     *
     */
     public abstract void compute();

    /**
     * Connect the Interaction to two Mass modules.
     * @param m1 connected Mass at one end.
     * @param m2 connected Mass at other end.
     */
    protected void connect (Mass m1, Mass m2) {
        m_mat1 = m1;
        m_mat2 = m2;
    }

    /**
     * Access the first Mass connected to this Interaction.
     * @return the first Mass module.
     */
    public Mass getMat1() {
        return m_mat1;
    }

    /**
     * Access the second Mass connected to this Interaction.
     * @return the second Mass module.
     */
    public Mass getMat2() {
        return m_mat2;
    }

    /**
     * Get the m_type of the Interaction module.
     * @return the Interaction module m_type.
     */
    public interType getType(){
        return m_type;
    }


    /**
     * Set the m_type of the Interaction module.
     * @param t the Interaction module m_type.
     */
    protected void setType(interType t){
        m_type = t;
    }

    /**
     * Initialise distance and delayed distance for this Interaction.
     *
     */
    protected void initDistances() {
        m_distSquared = m_mat1.getPos().sqDist(m_mat2.getPos());
        m_prevDistSquared = m_mat1.getPosR().sqDist(m_mat2.getPosR());

        m_prevDist = Math.sqrt(m_prevDistSquared);
        m_dist = Math.sqrt(m_distSquared);
    }

    public void init(){
        this.initDistances();
    }

    /**
     * Calculate the euclidian distance between both Mats connected to this Interaction.
     * @return
     */
    protected double updateSquaredDist() {
        m_prevDistSquared = m_distSquared;
        m_distSquared = m_mat1.getPos().sqDist(m_mat2.getPos());
        return m_distSquared;
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

    public double calcDist1D() {
        return (m_mat1.getPos().z - m_mat2.getPos().z);
    }




    /**
     * Change resting distance for this Interaction.
     * @param d new resting distance.
     *  @return true if succesfully changed
     */
    protected boolean changeDRest(double d) {
        m_dRest = d;
        m_dRsquared = d*d;
        return true;
    }

    /**
     * Get the resting distance of this interaction
     * @return the resting distance parameter
     */
    protected double getDRest(){
        return m_dRest;
    }

    /**
     * Change the stiffness of this Interaction.
     * @param k stiffness value.
     * @return true if succesfully changed
     */
    protected boolean changeStiffness(double k) {m_K = k; return true;}

    /**
     * Change the damping of this Interaction.
     * @param z the damping value.
     * @return true if succesfully changed
     */
    protected boolean changeDamping(double z){m_Z = z; return true;}

    /**
     * Get the stiffness of this interaction element
     * @return the stiffness parameter
     */
    protected double getStiffness(){return m_K;}

    /**
     * Get the damping of this interaction element
     * @return the damping parameter
     */
    protected double getDamping(){return m_Z;}

    /**
     * Get delayed velocity (per sample) between the two connected Mass modules
     * @return per sample velocity value.
     */
    protected double getRelativeVelocity() {
        return Math.sqrt(m_distSquared) - Math.sqrt(m_prevDistSquared);
    }

    /**
     * Get the distance between mat modules connected by the interaction
     * @return distance value.
     */
    protected double getDist() {
        return Math.sqrt(m_distSquared);
    }

    /**
     * Get the squared distance between mat modules connected by the interaction
     * @return the squared distance
     */
    protected double getDsquared(){
        return m_distSquared;
    }

    /**
     * Get the elongation (distance minus resting length between mat modules connected by the interaction
     * @return elongation value.
     */
    public double getElongation() {
        return m_dist - m_dRest;
    }

    protected double getInterpenetration(){
        return getDist() - interRadius();
    }

    protected double interRadiusSquared(){
        return interRadius() * interRadius();
    }

    protected double interRadius(){
        return getMat1().m_size + getMat2().m_size;
    }

    /**
     * Apply forces to the connected Mass modules
     * @param lnkFrc force to apply symetrically.
     */
    protected void applyForces(double lnkFrc) {

        double invDist = 1 / getDist();

        double x_proj = (getMat1().m_pos.x - getMat2().m_pos.x) * invDist;
        double y_proj = (getMat1().m_pos.y - getMat2().m_pos.y) * invDist;
        double z_proj = (getMat1().m_pos.z - getMat2().m_pos.z) * invDist;

        getMat1().m_frc.x += lnkFrc * x_proj;
        getMat1().m_frc.y += lnkFrc * y_proj;
        getMat1().m_frc.z += lnkFrc * z_proj;

        getMat2().m_frc.x -= lnkFrc * x_proj;
        getMat2().m_frc.y -= lnkFrc * y_proj;
        getMat2().m_frc.z -= lnkFrc * z_proj;
    }

    protected void applyForcesAndShift(double lnkFrc){
        double invDist = 1. / m_dist;

        double x_proj = (m_mat1.m_pos.x - m_mat2.m_pos.x) * invDist;
        double y_proj = (m_mat1.m_pos.y - m_mat2.m_pos.y) * invDist;
        double z_proj = (m_mat1.m_pos.z - m_mat2.m_pos.z) * invDist;

        m_mat1.m_frc.x += lnkFrc * x_proj;
        m_mat1.m_frc.y += lnkFrc * y_proj;
        m_mat1.m_frc.z += lnkFrc * z_proj;

        m_mat2.m_frc.x -= lnkFrc * x_proj;
        m_mat2.m_frc.y -= lnkFrc * y_proj;
        m_mat2.m_frc.z -= lnkFrc * z_proj;

        m_prevDist = m_dist;
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
    private interType m_type;
    protected Mass m_mat1;
    protected Mass m_mat2;


    protected double m_distSquared;
    protected double m_prevDistSquared;

    protected double m_dist;
    protected double m_prevDist;

    protected double m_dRest;
    protected double m_dRsquared;

    //protected double m_interRadiusSquared;
    //protected double m_interRadius;

    protected double m_K;
    protected double m_Z;


    //protected double m_linkFrc;
}