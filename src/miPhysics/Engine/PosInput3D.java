package miPhysics.Engine;

/**
 * A 3D Haptic Input Mass module. Position received from outside world, force send to outside world.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class PosInput3D extends Mass {

    public PosInput3D(double size, Vect3D initPos, int smoothing) {
        super(1., size, initPos, new Vect3D(0,0,0));
        setType(massType.POSINPUT3D);

        m_drivePos = new Vect3D(initPos);
        m_smooth = 1./ smoothing;
    }

    public PosInput3D(double size, Vect3D initPos) {
        this(size, initPos, 1);
    }


    public void compute() {

        this.m_pos.x = m_smooth * m_drivePos.x + (1-m_smooth) * this.m_pos.x;
        this.m_pos.y = m_smooth * m_drivePos.y + (1-m_smooth) * this.m_pos.y;
        this.m_pos.z = m_smooth * m_drivePos.z + (1-m_smooth) * this.m_pos.z;

        // Nothing to do here, except reset the force buffer
        this.m_posR.set(this.m_pos);
        this.m_frc.set(0., 0., 0.);
    }

    /**
     * Set the position and also delayed position: for setting state "instantly" with null velocity
     * @param outsidePos the new position
     */
    public void setPosition(Vect3D outsidePos) {
        this.m_drivePos.x = outsidePos.x;
        this.m_drivePos.y = outsidePos.y;
        this.m_drivePos.z = outsidePos.z;

//        this.m_pos.x = outsidePos.x;
//        this.m_pos.y = outsidePos.y;
//        this.m_pos.z = outsidePos.z;
//        this.m_posR.set(this.m_pos);
    }

    /**
     * Drive position with a new value, without setting velocity to zero.
     * @param outsidePos the new position to apply
     */
    public void drivePosition(Vect3D outsidePos) {
        this.m_drivePos.x = outsidePos.x;
        this.m_drivePos.y = outsidePos.y;
        this.m_drivePos.z = outsidePos.z;
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

    private double m_smooth;
    private Vect3D m_drivePos;
}