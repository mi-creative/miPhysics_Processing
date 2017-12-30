package physicalModelling;


// A simple vector class
public class Vect3D {
    public double x, y, z;

    // constructors
    public Vect3D( ) {
    }

    public Vect3D(double x, double y, double z) {
        this.x = x; this.y = y; this.z = z;
    }

    public Vect3D(Vect3D v) {
        x = v.x;
        y = v.y;
        z = v.z;
    }
    
    public double dist(Vect3D v2) {
    	return Math.sqrt(Math.pow(v2.x-this.x,2)+ Math.pow(v2.y-this.y,2) + Math.pow(v2.z-this.z,2));
    }
    
    public Vect3D add(Vect3D v2) {
    	this.x += v2.x;
    	this.y += v2.y;
    	this.z += v2.z;
    	return this;
    }
    
    public Vect3D sub(Vect3D v2) {
    	this.x -= v2.x;
    	this.y -= v2.y;
    	this.z -= v2.z;
    	return this;
    }
    
    public Vect3D mult(double factor) {
    	this.x = this.x * factor;
    	this.y = this.y * factor;
    	this.z = this.z * factor;
    	return this;
    }
    
    public Vect3D div(double factor) {
    	this.x = this.x / factor;
    	this.y = this.y / factor;
    	this.z = this.z / factor;
    	return this;
    }
    
    public Vect3D set(Vect3D v2) {
    	this.x = v2.x;
    	this.y = v2.y;
    	this.z = v2.z;
    	return this; 	
    }
    
    public Vect3D set(double x_val, double y_val, double z_val) {
    	this.x = x_val;
    	this.y = y_val;
    	this.z = z_val;
    	return this; 	
    }
    

    // methods
    public String toString() {
        return new String("["+x+", "+y+", "+z+"]");
    }
}