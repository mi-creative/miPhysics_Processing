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
     * Constructor method.
     * @param distance resting distance of the Interaction.
     * @param m1 connected Mass at one end.
     * @param m2 connected Mass at other end.
     */
    public InOut(Mass m) {
        m_mat = m;
        m_type = inOutType.UNDEFINED;
    }

    /**
     * Compute behavior of the Interaction (depends on the concrete implementation of concerned module).
     *
     */
    public abstract void compute();

    /**
     * Connect the InOut module to one Mass module.
     * @param m connected Mass.
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



    /* Class attributes */
    private inOutType m_type;
    private Mass m_mat;

}