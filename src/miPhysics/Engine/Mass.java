package miPhysics.Engine;

import org.omg.CORBA.ObjectHelper;

/**
 * Abstract class defining Material points.
 *
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public abstract class Mass extends Object {

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

        this.setType(massType.UNDEFINED);

        this.m_size = size;
        this.m_invMass = 1/M;

        this.init(initPos, initPosR);
        this.resetForce();
    }

    /**
     * Initialise the Mass module.
     * @param X initial position.
     * @param XR initial delayed position.
     */
    protected void init(Vect3D X, Vect3D XR) {
        this.m_pos.set(X);
        this.m_posR.set(XR);
    }

    protected void resetForce(){
        this.m_frc.reset();
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
    protected void applyForce(Vect3D force){
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



    /* Class attributes */

    protected Vect3D m_pos;
    protected Vect3D m_posR;
    protected Vect3D m_frc;

    protected Vect3D tmp;

    private massType m_type;
    protected double m_invMass;
    protected double m_size;
}
