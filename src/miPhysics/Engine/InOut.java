package miPhysics.Engine;


/**
 * Abstract InOut class.
 * Defines generic structure and behavior for all possible Extern modules.
 *
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public abstract class InOut extends Module {

    /**
     * Generic in/out module constructor
     * @param m
     */
    public InOut(Mass m) {
        m_mat = m;
        m_type = inOutType.UNDEFINED;
    }

    /**
     * Compute behavior of the In/Out (depends on the concrete implementation of concerned module).
     *
     */
    public abstract void compute();

    /**
     * Connect the InOut module to one Mass module.
     * @param m1 connected Mass.
     */
    public void connect (Mass m1) {
        m_mat = m1;
    }

    /**
     * Access the first Mass connected to this InOut module.
     * @return the Mass module.
     */
    public Mass getMat() {
        return m_mat;
    }


    /**
     * Get the m_type of the InOut module.
     * @return the extern module m_type.
     */
    protected inOutType getType(){
        return m_type;
    }


    /**
     * Set the m_type of the InOut module.
     * @param t the extern module m_type.
     */
    protected void setType(inOutType t){
        m_type = t;
    }


    // CHEAP HACK: have to implement these if we want them to be inherited from the Module class
    public int setParam(param p, double val ){
        System.out.println("Currently no accessible params for InOut Modules");
        return -1;
    }
    public double getParam(param p){
        System.out.println("Currently no accessible params for InOut Modules");
        return -1;
    }



    /* Class attributes */
    private inOutType m_type;
    private Mass m_mat;

}