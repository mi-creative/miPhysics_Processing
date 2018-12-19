package miPhysics;


/**
 * Contact interaction: collision between two Mat elements.
 * When the distance is lower than the threshold distance, a viscoelastic force is applied.
 * 
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Contact3D extends Link {

  /**
 * @param distance
 * @param K_param
 * @param Z_param
 * @param m1
 * @param m2
 */
public Contact3D(double distance, double K_param, double Z_param, Mat m1, Mat m2) {
    super(distance, m1, m2);
    setType(linkModuleType.Contact3D);
    K = K_param;
    Z = Z_param;
  }

public void compute() {
    double d = calcNewEuclidDist();
    if (d < dRest) {
      double lnkFrc = -(d-dRest)*(K) - getSpeed() *  Z;
      this.applyForces(lnkFrc);
    }
  }
  
  
public void changeStiffness(double stiff) {
	  K = stiff;
  }

public void changeDamping(double damp) {
	  Z = damp;
  }
  
public double K;
public double Z;
}