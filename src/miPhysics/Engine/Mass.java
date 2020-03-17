package miPhysics.Engine;
import processing.core.PVector;

/**
 * Abstract class defining Material points.
 *
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public abstract class Mass extends Module {


    /**
     * Constructor method.
     *
     * @param M mass value.
     * @param initPos initial position.
     * @param initPosR delayed initial position.
     */
    public Mass(double M, double size, Vect3D initPos, Vect3D initPosR) {
        m_pos = new Vect3D(0., 0., 0.);
        m_posR = new Vect3D(0., 0., 0.);
        m_frc = new Vect3D(0., 0., 0.);

        tmp = new Vect3D();

        m_type = massType.UNDEFINED;

        m_size = size;

        changeMass(M);
        m_pos.set(initPos);
        m_posR.set(initPosR);

        m_frc.set(0., 0., 0.);
    }

    /**
     * Initialise the Mass module.
     * @param X initial position.
     * @param XR initial delayed position.
     */
    protected void init(Vect3D X, Vect3D XR) {
        this.m_pos = X;
        this.m_posR = XR;
    }

    /**
     * Compute the physics of the Mass module.
     *
     */
    public abstract void compute();

    /**
     * Apply external force to this Mass module.
     * @param force force to apply.
     */
    protected void applyExtForce(Vect3D force){
        m_frc.add(force);
    }

    /**
     * Get the current position of this Mass module.
     * @return the module position.
     */
    public Vect3D getPos() {
        return m_pos;
    }

    /**
     * Set the current position of this Mass module.
     * @param newPos the target position to set.
     * @return the module position.
     */
    protected void setPos(Vect3D newPos) {
        m_pos.set(newPos);
        m_posR.set(newPos);
    }

    protected void setPosR(Vect3D newPos){
        m_posR.set(newPos);
    }



    /**
     * Get the current position of this Mass module (in a PVector format).
     * @return the module position.
     */
    protected PVector getPosVector() {
        return new PVector((float)m_pos.x,(float)m_pos.y,(float)m_pos.z);
    }

    /**
     * Get the delayed position of the module.
     * @return the delayed position.
     */
    protected Vect3D getPosR() {
        return m_posR;
    }

    /**
     * Get the per-timestep vecocity of the module.
     * @return the velocity.
     */
    /*protected Vect3D getVel() {
        return m_pos - m_posR;
    }*/


    /**
     * Get the value in the force buffer.
     * @return force value.
     */
    protected Vect3D getFrc() {
        return m_frc;
    }

    /**
     * Set the mass parameter.
     * @param M mass value.
     * @return true if set the mass val
     */
    protected boolean changeMass (double M) {
        m_invMass = 1 / M;
        return true;
    }

    /**
     * Set the stiffness parameter.
     * @param K stiffness value.
     * @return true if set the stiffness val
     */
    protected boolean changeStiffness(double K){return false;}

    /**
     * Set the damping parameter.
     * @param Z damping value.
     * @return true if set the damping val
     */
    protected boolean changeDamping(double Z){return false;}

    /**
     * Get the mass parameter.
     * @return the mass value
     */
    protected double getMass () {
        return  1. / m_invMass;
    }

    /**
     * Get the stiffness parameter.
     * @return the stiffness value
     */
    protected double getStiffness () {
        return  -1.;
    }

    /**
     * Get the damping parameter.
     * @return the damping value
     */
    protected double getDamping () {
        return  -1.;
    }

    /**
     * Get the type of this Mass module.
     * @return the type of the current Mass module.
     */
    public massType getType(){
        return m_type;
    }

    /**
     * Set the module type for this Mass module.
     * @param t the Mass type module to set.
     */
    protected void setType(massType t){
        m_type = t;
    }

    protected void setSize(double s){
        m_size = s;
    }

    protected double getSize(){return m_size;}


    public abstract int setParam(param p, double val );

    public abstract double getParam(param p);

    public void setMedium(Medium m){
        m_medium = m;
    }

    public Medium getMedium(){
        return m_medium;
    }

    /**
     * Trigger a temporary velocity control
     * @param v the velocity used to displace the mat at each step
     */

    public void triggerVelocityControl(Vect3D v)
    {
        m_controlled = true;
        m_controlVelocity = v;
    }

    /**
     * Stop the current temporary velocity control
     */
    public void stopVelocityControl()
    {
        m_controlled = false;
    }
    /* Class attributes */

    protected Vect3D m_pos;
    protected Vect3D m_posR;
    protected Vect3D m_frc;

    protected Vect3D tmp;

    private massType m_type;
    protected double m_invMass;

    protected double m_size;

    protected Medium m_medium;


    // Should we really keep this stuff? It's pretty weird...
    protected boolean m_controlled = false;
    protected Vect3D m_controlVelocity = new Vect3D(0,0,0);
}
