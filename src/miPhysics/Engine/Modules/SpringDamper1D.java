package miPhysics;


/* 1D SPRING OBJECT */

/**
 * Spring interaction: elastic interaction between two Mat elements.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class SpringDamper1D extends Link {

	  public SpringDamper1D(double distance, double K_param, double Z_param, Mat m1, Mat m2) {
	    super(distance, m1, m2);
	    setType(linkModuleType.SpringDamper1D);
	    K = K_param;
	    Z = Z_param;
	  }

	  public void compute() {
	    dist_1D = calcDist1D();
	    double lnkFrc = (dist_1D-dRest)*(K) + getSpeed() *  Z;
	    this.applyForces1D(lnkFrc);
	    distR_1D = dist_1D;
	  }
	  
	  
	  public void changeStiffness(double stiff) {
		  K = stiff;
	  }
	  
	  public void changeDamping(double damp) {
		  Z = damp;
	  }
	  
	  protected void initDistances() {
		  dist_1D = this.getMat1().getPos().z - this.getMat2().getPos().z;
		  distR_1D = this.getMat1().getPosR().z - this.getMat2().getPosR().z;
		  }
	  
	  protected double getSpeed() { 
		    return dist_1D-distR_1D;
		  }

	  public double dist_1D;
	  public double distR_1D;
	  
	  public double K;
	  public double Z;
	}