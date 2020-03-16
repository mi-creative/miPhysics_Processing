package miPhysics;


/**
 * Defines a physical medium context (friction, gravity, etc.)
 * That will be applied to material points
 *
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Medium {

    public Medium(){
        this.m_mFric = 0;
        this.m_gravity = new Vect3D();
    }

    public Medium(double mediumFric, Vect3D gravity){
        this.m_mFric = mediumFric;
        this.m_gravity = new Vect3D();
        this.m_gravity.set(gravity);
    }

    public double getMediumFriction(){
        return this.m_mFric;
    }

    public Vect3D getGravity(){
        return new Vect3D(this.m_gravity);
    }

    public void setMediumFriction(double d){
        this.m_mFric = d;
    }
    public void setGravity(Vect3D v){
        this.m_gravity.set(v);
    }

    /* Class attributes */
    private Vect3D m_gravity;
    private double m_mFric;

}