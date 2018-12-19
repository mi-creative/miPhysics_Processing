package miPhysics;

/**
 * Bubble interaction: one Mat is enclosed within a certain radius of another Mat.
 * When the distance is greater than the radius, a viscoelastic force is applied.
 * 
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Bubble3D extends Link {

/**
 * Create the Bubble Link.
 * @param distance distance (radius) between both Mats.
 * @param K_param stiffness parameter.
 * @param Z_param damping parameter.
 * @param m1 first (enclosed) Mat module.
 * @param m2 second (enclosing) Mat module.
 */
public Bubble3D(double distance, double K_param, double Z_param, Mat m1, Mat m2) {
    super(distance, m1, m2);
    setType(linkModuleType.Bubble3D);
    K = K_param;
    Z = Z_param;
  }

/* (non-Javadoc)
 * Bubble interaction force algorithm.
 * @see physicalModelling.Link#compute()
 */
public void compute() {
    double d = calcNewEuclidDist();
    if (d > dRest) {
      double lnkFrc = -(d-dRest)*(K) - getSpeed() *  Z;
      this.applyForces(lnkFrc);
    }
  }
  
  /* (non-Javadoc)
 * @see physicalModelling.Link#changeStiffness(double)
 */
public void changeStiffness(double stiff) {
	  K = stiff;
  }
  /* (non-Javadoc)
 * @see physicalModelling.Link#changeDamping(double)
 */
public void changeDamping(double damp) {
	  Z = damp;
  }

public double K;
public double Z;
}