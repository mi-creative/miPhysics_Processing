package miPhysics.Utility;

import miPhysics.Engine.Mass;
import miPhysics.Engine.Vect3D;
import miPhysics.Engine.param;

public class SpacePrint {

    private double x_max = -100000;
    private double x_min = 100000;
    private double y_max = -100000;
    private double y_min = 100000;
    private double z_max = -100000;
    private double z_min = 100000;
    private boolean valid = true;

    public SpacePrint(){

    }


    public SpacePrint(SpacePrint sp){
        this.set(sp);
    }

    public void set(SpacePrint sp){
        x_max = sp.x_max;
        x_min = sp.x_min;
        y_max = sp.y_max;
        y_min = sp.y_min;
        z_max = sp.z_max;
        z_min = sp.z_min;
        valid = sp.valid;
    }

    public void set(double x_mi, double x_ma, double y_mi, double y_ma, double z_mi, double z_ma){
        x_max = x_ma;
        x_min = x_mi;
        y_max = y_ma;
        y_min = y_mi;
        z_max = z_ma;
        z_min = z_mi;
        valid = true;
    }

    // TODO: this is a crap initialisation !!
    public void reset(){
        x_max = -100000;
        x_min = 100000;
        y_max = -100000;
        y_min = 100000;
        z_max = -100000;
        z_min = 100000;
        valid = false;
    }

    public void update(Mass m){
        Vect3D pos = m.getPos();
        double size = m.getParam(param.RADIUS);
        x_min = Math.min(x_min, pos.x - size);
        x_max = Math.max(x_max, pos.x + size);

        y_min = Math.min(y_min, pos.y - size);
        y_max = Math.max(y_max, pos.y + size);

        z_min = Math.min(z_min, pos.z - size);
        z_max = Math.max(z_max, pos.z + size);
        valid = true;
    }

    public void update(SpacePrint sp){
        x_min = Math.min(x_min, sp.x_min);
        x_max = Math.max(x_max, sp.x_max);

        y_min = Math.min(y_min, sp.y_min);
        y_max = Math.max(y_max, sp.y_max);

        z_min = Math.min(z_min, sp.z_min);
        z_max = Math.max(z_max, sp.z_max);
        valid = true;

    }

    public boolean isValid(){
        return valid;
    }


    public boolean intersectsWithMass(Mass m){

        Vect3D pos = m.getPos();
        double size = m.getParam(param.RADIUS);

        if((this.x_min > pos.x + size) || (this.x_max < pos.x-size)) return false;
        if ((this.y_min > pos.y + size) || (this.y_max < pos.y - size)) return false;
        if ((this.z_min > pos.z + size) || (this.z_max < pos.z - size)) return false;
        return true;

    }


    // TODO: could refactor this to make the code less redundant...
    public boolean intersection(SpacePrint sp1, SpacePrint sp2){

        if((sp2.x_min > sp1.x_max) || (sp2.x_max < sp1.x_min)) {
            this.valid = false;
            return false;
        }
        else {
            this.x_min = Math.max(sp1.x_min, sp2.x_min);
            this.x_max = Math.min(sp1.x_max, sp2.x_max);
        }
        if((sp2.y_min > sp1.y_max) || (sp2.y_max < sp1.y_min)) {
            this.valid = false;
            return false;
        }
        else {
            this.y_min = Math.max(sp1.y_min, sp2.y_min);
            this.y_max = Math.min(sp1.y_max, sp2.y_max);
        }
        if((sp2.z_min > sp1.z_max) || (sp2.z_max < sp1.z_min)) {
            this.valid = false;
            return false;
        }
        else {
            this.z_min = Math.max(sp1.z_min, sp2.z_min);
            this.z_max = Math.min(sp1.z_max, sp2.z_max);
        }
        this.valid = true;
        return true;

    }

    public Vect3D center(){
        return new Vect3D(0.5*(x_max+x_min), 0.5*(y_max+y_min), 0.5*(z_max+z_min));
    }

    public Vect3D size(){
        return new Vect3D(x_max-x_min, y_max-y_min, z_max-z_min);
    }

    public String toString(){
        return "X : [" + x_min + ", " + x_max +" ]"
                + ", Y : [" + y_min + ", " + y_max +" ]"
                + ", Z : [" + z_min + ", " + z_max +" ]";
    }
}
