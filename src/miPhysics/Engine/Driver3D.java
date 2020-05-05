package miPhysics.Engine;


/**
 * Driver module (a interaction module that acts upon a Mass
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */

public class Driver3D extends InOut {

    /**
     * Create the driver and attach it to a mass module
     * @param m the to drive.
     */
    public Driver3D(Mass m) {
        super(m);
        setType(inOutType.DRIVER3D);
    }

    public Driver3D() {
        this(null);
    }

    public void compute() {
        if (m_rampActive) {
            m_steps++;
            m_currentForce.set(m_targetForce).mult((double)m_steps/(double)m_rampSteps);
            this.applyFrc(m_currentForce);

            if(m_steps > m_rampSteps)
                m_rampActive =false;
        }
    }

    /**
     * Apply an input position to the mass element controlled by the driver.
     * @param pos the position to apply
     */
    public void applyPos(Vect3D pos){
        this.getMat().setPos(pos);
    }

    public void applyPos(double x, double y, double z){
        Vect3D newPos = new Vect3D(x,y,z);
        this.applyPos(newPos);
    }

    /**
     * Apply an input force to the mass controlled by the driver.
     * @param frc the Vec3D containing the force to apply
     */
    public void applyFrc(Vect3D frc){
        this.getMat().applyForce(frc);
    }

    public void applyFrc(double x, double y, double z){
        Vect3D newFrc = new Vect3D(x,y,z);
        this.applyFrc(newFrc);
    }

    /**
     * Move the driver to another mass
     * @param m the new mass to act upon
     */
    public void moveDriver(Mass m){
        this.connect(m);
    }


    /**
     * Trigger a force ramp applied to the controlled mass.
     * @param x force amount along X.
     * @param y force amount along Y.
     * @param z force amount along Z.
     * @param timeSteps steps in samples over which the force ramp is applied.
     */
    public void triggerForceRamp(double x, double y, double z, int timeSteps){
        m_rampSteps = timeSteps;
        m_targetForce.x = x;
        m_targetForce.y = y;
        m_targetForce.z = z;
        m_currentForce.reset();
        m_steps = 0;
        m_rampActive = true;
    }

    /**
     * Trigger a force ramp applied to the controlled mass.
     * @param frc 3D vector containing the force to apply.
     * @param timeSteps steps in samples over which the force ramp is applied.
     */
    public void triggerForceRamp(Vect3D frc, int timeSteps){
        this.triggerForceRamp(frc.x, frc.y, frc.z, timeSteps);
    }


    private Vect3D m_targetForce = new Vect3D();
    private Vect3D m_currentForce = new Vect3D();
    private int m_steps = 0;
    private int m_rampSteps = 0;
    private boolean m_rampActive = false;

}
