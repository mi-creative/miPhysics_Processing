package miPhysics;

/**
 * Abstract class defining modules
 *
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public abstract class Module {

    public Module() {
        this.m_name = "";
    }

    public Module(String name) {
        this.m_name = name;
    }

    protected void setName(String name){
        this.m_name = name;
    }

    public String getName(){
        return this.m_name;
    }


    /**
     * Compute the physics of the Mass module.
     *
     */
    protected abstract void compute();

    String m_name;
}
