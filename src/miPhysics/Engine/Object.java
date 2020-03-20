package miPhysics.Engine;
import processing.core.PVector;

/**
 * Abstract class defining Physical objects: either masses or macro modules (considered as masses to outside world).
 *
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public abstract class Object extends Module {

    public Object() {
        m_type = massType.UNDEFINED;
    }

    public void clear(){
        m_type = massType.UNDEFINED;
    }

    //protected abstract void init();
    public abstract void compute();
    protected abstract void applyForce(Vect3D force);


    public abstract massType getType();
    protected abstract void setType(massType t);


    public void setMedium(Medium m){
        m_medium = m;
    }
    public Medium getMedium(){
        return m_medium;
    }


    /* Class attributes */

    protected massType m_type;
    protected Medium m_medium = new Medium (0, new Vect3D(0,0,0));
}
