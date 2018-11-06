package physicalModelling;


/**
 * TAG: EXPERIMENTAL
 * Non Orthonormal Contact interaction: collision between two Mat elements.
 * The contact zones between both Mat modules are not necessarily spherical (axes can be compressed).
 * This means that the contact threshold distance varies depending on the orientation of the distance vector.
 * When the distance is lower than the dynamically calculated threshold distance, a visco-elastic force is applied.
 * 
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class NonOrthContact3D extends Link {

  /**
 * @param distance
 * @param K_param
 * @param Z_param
 * @param m1
 * @param m2
 */
public NonOrthContact3D(double m1_r, double m2_r, double K_param, double Z_param, Mat m1, Mat m2) {
    super((m1_r+m2_r), m1, m2);
    setType(linkModuleType.NonOrthContact3D);
    this.K = K_param;
    this.Z = Z_param;
    
    this.m1_radius = m1_r;
    this.m2_radius = m2_r;
    
    this.mat1_shape = new Vect3D(1.,1.,1.);
    this.mat2_shape = new Vect3D(1.,1.,1.);
    
    this.orientation= new Vect3D(0.,0.,0.);
    
  }

public void compute() {
    double d = calcNewEuclidDist();
    
    /* now to use the orientation vector between both modules
     * and the contact shapes to calculate the intersection threshold along this axis...
     */
    
    // Create the normalised orientation vector between Mat modules
    this.orientation.set(this.getMat1().getPos());
    this.orientation.sub(this.getMat2().getPos());
    this.orientation.div(d);
    
    // now create the distances along the orientation vector for the first and second Mat...
    this.m1_projDist = Math.sqrt(Math.pow((this.orientation.x*this.mat1_shape.x),2) +
    				   Math.pow((this.orientation.y*this.mat1_shape.y),2) +
    				   Math.pow((this.orientation.z*this.mat1_shape.z),2));
    this.m1_projDist *= m1_radius;
    
    // now create the distances along the orientation vector...
    this.m2_projDist = Math.sqrt(Math.pow((this.orientation.x*this.mat2_shape.x),2) +
    				   Math.pow((this.orientation.y*this.mat2_shape.y),2) +
    				   Math.pow((this.orientation.z*this.mat2_shape.z),2));
    this.m2_projDist *= m2_radius;
    
    // Add them together to obtain the dynamic threshold value for the collision interaction !
    this.dRest = m1_projDist + m2_projDist;
        
    // Regular collision algorithm
    if (d < dRest) {
      double lnkFrc = -(d-dRest)*(K) - getSpeed() *  Z;
      this.applyForces(lnkFrc);
    }
  }
  
public void setContactShapeMat1(double x, double y, double z) {
	this.mat1_shape.x = x;
	this.mat1_shape.y = y;
	this.mat1_shape.z = z;
}

public void setContactShapeMat2(double x, double y, double z) {
	this.mat2_shape.x = x;
	this.mat2_shape.y = y;
	this.mat2_shape.z = z;
}

public void changeStiffness(double stiff) {
	  this.K = stiff;
  }

public void changeDamping(double damp) {
	  this.Z = damp;
  }
  
public double K;
public double Z;

private double m1_radius;
private double m2_radius;

private double m1_projDist;
private double m2_projDist;

private Vect3D mat1_shape;
private Vect3D mat2_shape;

private Vect3D orientation;

}