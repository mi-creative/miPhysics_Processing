package miPhysics.Engine;


/**
 * Driver module (a interaction module that acts upon a Mass
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */

public class Driver3D extends InOut {

    public Driver3D(Mass m) {
        super(m);
        setType(inOutType.DRIVER3D);
    }

    public Driver3D() {
        this(null);
    }

    public void compute() {
    }

    /**
     * Apply position to connected Mass element
     * @param pos the position to apply
     */
    public void applyPos(Vect3D pos){
        this.getMat().setPos(pos);
    }

    /**
     * Apply force to connected Mass module
     * @param frc the Vec3D containing the force to apply
     */
    public void applyFrc(Vect3D frc){
        this.getMat().applyExtForce(frc);
    }

    /**
     * Move the driver to another mass
     * @param m the new mass to act upon
     */
    public void moveDriver(Mass m){
        this.connect(m);
    }

    public void setParam(param p, double val ){}


}
