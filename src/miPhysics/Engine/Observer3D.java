package miPhysics.Engine;


/**
 *  Listener module (a interaction module that only observes one mat
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */


public class Observer3D extends InOut {


    public Observer3D(filterType f, Mass m) {
        super(m);
        setType(inOutType.OBSERVER3D);

        m_posObs = new Vect3D();
        m_frcObs = new Vect3D();

        m_outPos = new Vect3D();
        m_outPrevPos = new Vect3D();

        m_outFrc = new Vect3D();
        m_outPrevFrc = new Vect3D();

        m_filtType = f;
        m_coef = 0.95;

        m_ramp = 0;
    }

    public Observer3D(filterType f) {
        this(f, null);
    }

    public Observer3D(){
        this(filterType.NONE, null);
    }

    public void compute() {
        m_posObs.set(getMat().getPos());
        m_frcObs.set(getMat().getFrc());

        if(m_ramp<1)
            m_ramp += 0.0001;

        if(m_filtType == filterType.HIGH_PASS) {

            m_outPos.x = (m_posObs.x - m_outPrevPos.x + m_coef * m_outPos.x) * m_ramp;
            m_outPos.y = (m_posObs.y - m_outPrevPos.y + m_coef * m_outPos.y) * m_ramp;
            m_outPos.z = (m_posObs.z - m_outPrevPos.z + m_coef * m_outPos.z) * m_ramp;

            m_outFrc.x = (m_frcObs.x - m_outPrevFrc.x + m_coef * m_outFrc.x) * m_ramp;
            m_outFrc.y = (m_frcObs.y - m_outPrevFrc.y + m_coef * m_outFrc.y) * m_ramp;
            m_outFrc.z = (m_frcObs.z - m_outPrevFrc.z + m_coef * m_outFrc.z) * m_ramp;

            m_outPrevPos.set(m_posObs);
            m_outPrevFrc.set(m_frcObs);
        }
        else{
            //m_outPos.set(m_posObs);
            //m_outFrc.set(m_frcObs);
            m_outPos.x = m_posObs.x * m_ramp;
            m_outPos.y = m_posObs.y * m_ramp;
            m_outPos.z = m_posObs.z * m_ramp;

            m_outFrc.x = m_frcObs.x * m_ramp;
            m_outFrc.y = m_frcObs.y * m_ramp;
            m_outFrc.z = m_frcObs.z * m_ramp;
        }
    }

    /**
     * Listen to the observed position
     * @return the Vec3D containing the position of the observed mass
     */
    public Vect3D observePos(){
        return m_outPos;
    }

    /**
     * Listen to the observed force
     * @return the Vec3D containing the force of the observed mass
     */
    public Vect3D observeFrc(){
        return m_outFrc;
    }

    /**
     * Move the listener to another mass
     * @param m the new mass to observe
     */
    public void moveObserver(Mass m){
        this.connect(m);
    }

    private Vect3D m_posObs;
    private Vect3D m_frcObs;

    private Vect3D m_outPos;
    private Vect3D m_outPrevPos;

    private Vect3D m_outFrc;
    private Vect3D m_outPrevFrc;

    private double m_coef;
    private filterType m_filtType;

    private double m_ramp;

}
