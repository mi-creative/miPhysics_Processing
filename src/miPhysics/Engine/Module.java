package miPhysics.Engine;

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

    protected abstract void compute();
    public abstract int setParam(param p, double val );
    public abstract double getParam(param p);

    String m_name;
}