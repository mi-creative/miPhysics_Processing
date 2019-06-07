package miPhysics;
import processing.core.PVector;

/**
 * Abstract class defining Material points.
 *
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public abstract class Mat {


    /**
     * Constructor method.
     *
     * @param M mass value.
     * @param initPos initial position.
     * @param initPosR delayed initial position.
     */
    public Mat(double M, Vect3D initPos, Vect3D initPosR) {
        m_pos = new Vect3D(0., 0., 0.);
        m_posR = new Vect3D(0., 0., 0.);
        m_frc = new Vect3D(0., 0., 0.);

        tmp = new Vect3D();

        m_type = matModuleType.UNDEFINED;

        changeMass(M);
        m_pos.set(initPos);
        m_posR.set(initPosR);

        m_frc.set(0., 0., 0.);
    }

    /**
     * Initialise the Mat module.
     * @param X initial position.
     * @param XR initial delayed position.
     */
    protected void init(Vect3D X, Vect3D XR) {
        this.m_pos = X;
        this.m_posR = XR;
    }

    /**
     * Compute the physics of the Mat module.
     *
     */
    public abstract void compute();

    /**
     * Apply external force to this Mat module.
     * @param force force to apply.
     */
    protected void applyExtForce(Vect3D force){
        m_frc.add(force);
    }

    /**
     * Get the current position of this Mat module.
     * @return the module position.
     */
    protected Vect3D getPos() {
        return m_pos;
    }

    /**
     * Set the current position of this Mat module.
     * @param newPos the target position to set.
     * @return the module position.
     */
    protected void setPos(Vect3D newPos) {
        m_pos.set(newPos);
        m_posR.set(newPos);
    }



    /**
     * Get the current position of this Mat module (in a PVector format).
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
    public boolean changeMass (double M) {
        m_invMass = 1 / M;
        return true;
    }

    public boolean changeStiffness(double K){return false;}

    public boolean changeDamping(double Z){return false;}

    /**
     * Get the mass parameter.
     * @return the mass value
     */
    public double getMass () {
        return  1. / m_invMass;
    }


    /**
     * Get the type of this Mat module.
     * @return the type of the current Mat module.
     */
    protected matModuleType getType(){
        return m_type;
    }

    /**
     * Set the module type for this Mat module.
     * @param t the Mat type module to set.
     */
    protected void setType(matModuleType t){
        m_type = t;
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

    public void stopVelocityControl()
    {
        m_controlled = false;
    }
    /* Class attributes */

    protected Vect3D m_pos;
    protected Vect3D m_posR;
    protected Vect3D m_frc;

    protected Vect3D tmp;

    private matModuleType m_type;
    public double m_invMass;

    protected boolean m_controlled=false;
    protected Vect3D m_controlVelocity = new Vect3D(0,0,0);
}
