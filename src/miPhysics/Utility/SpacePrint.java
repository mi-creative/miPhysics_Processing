package miPhysics.Utility;

import miPhysics.Engine.Mass;
import miPhysics.Engine.Vect3D;
import miPhysics.Engine.param;

public class SpacePrint {
    public double x_max = -100000;
    public double x_min = 100000;
    public double y_max = -100000;
    public double y_min = 100000;
    public double z_max = -100000;
    public double z_min = 100000;

    public SpacePrint(){

    }

    public void reset(){
        x_max = -100000;
        x_min = 100000;
        y_max = -100000;
        y_min = 100000;
        z_max = -100000;
        z_min = 100000;
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
    }

    public void update(SpacePrint sp){
        x_min = Math.min(x_min, sp.x_min);
        x_max = Math.max(x_max, sp.x_max);

        y_min = Math.min(y_min, sp.y_min);
        y_max = Math.max(y_max, sp.y_max);

        z_min = Math.min(z_min, sp.z_min);
        z_max = Math.max(z_max, sp.z_max);

    }

    public String toString(){
        return "X : [" + x_min + ", " + x_max +" ]"
                + ", Y : [" + y_min + ", " + y_max +" ]"
                + ", Z : [" + z_min + ", " + z_max +" ]";
    }
}
