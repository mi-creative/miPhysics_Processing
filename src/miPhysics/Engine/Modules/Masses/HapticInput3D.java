package miPhysics;

/**
 * A 3D Haptic Input Mass module. Position received from outside world, force send to outside world.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class HapticInput3D extends Mass {

    public HapticInput3D(double size, Vect3D initPos, int smoothingFactor) {
        super(1., size, initPos, initPos);
        setType(massType.HAPTICINPUT3D);

        m_directPos = new Vect3D(initPos);

        m_smooth = 1./(float)smoothingFactor;

    }

    public void compute() {

        /*
         * m_smooth the position input value according to factor
         * (Exponentially weighted moving average)
         */

        this.m_pos.x = m_smooth * m_directPos.x + (1-m_smooth) * this.m_pos.x;
        this.m_pos.y = m_smooth * m_directPos.y + (1-m_smooth) * this.m_pos.y;
        this.m_pos.z = m_smooth * m_directPos.z + (1-m_smooth) * this.m_pos.z;

        /*
         * The haptic input is probably low rate:
         * The force needs to accumulate in the force buffer during high rate steps,
         * The haptic input will reset the force once it has consumed it.
         */
    }


    public void applyInputPosition(Vect3D outsidePos) {
        this.m_directPos.x = outsidePos.x;
        this.m_directPos.y = outsidePos.y;
        this.m_directPos.z = outsidePos.z;
    }

    public Vect3D applyOutputForce() {
        /*
         * Consume the force accumulation buffer value
         * (send it to device), and reset it to zero.
         */
        Vect3D outFrc = new Vect3D(m_frc.x, m_frc.y, m_frc.z);
        m_frc.set(0,0,0);
        return outFrc;
    }


    public int setParam(param p, double val ){
        switch(p){
            case RADIUS:
                this.m_size = val;
                return 0;
            default:
                System.out.println("Cannot apply param " + val + " for "
                        + this + ": no " + p + " parameter");
                return -1;
        }
    }

    public double getParam(param p){
        switch(p){
            case RADIUS:
                return this.m_size;
            default:
                System.out.println("No " + p + " parameter found in " + this);
                return 0.;
        }
    }


    /* Class attributes */

    private Vect3D m_gFrc;

    private double m_smooth;
    private Vect3D m_directPos;
}