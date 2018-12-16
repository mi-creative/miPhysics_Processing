package physicalModelling;


/**
 * Spring-Damper interaction: viscoelastic interaction between two Mat elements.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class SpringDamper3D extends Link {

  public SpringDamper3D(double distance, double K_param, double Z_param, Mat m1, Mat m2) {
    super(distance, m1, m2);
    setType(linkModuleType.SpringDamper3D);
    K = K_param;
    Z = Z_param;
    
    // for experimental implementation
    PrevD = calcDelayedDistance();
  }
/*
  public void compute() {
    double d = calcNewEuclidDist();
    double lnkFrc = -(d-dRest)*(K) - getSpeed() *  Z;
    this.applyForces(lnkFrc);
  }*/
  
  public void compute() {
	    d = calcNewEuclidDist();
	    double invD = 1./d;
	    double f_algo = -K * (1 - dRest*invD) - Z * (1 - PrevD*invD);
	    this.applyForces(new Vect3D(f_algo*getDx(), f_algo*getDy(), f_algo*getDz()));		
	    PrevD = d;
	  }
  
  public void changeStiffness(double stiff) {
	  K = stiff;
  }
  
  public void changeDamping(double damp) {
	  Z = damp;
  }

  public double K;
  public double Z;
  double d;
  public double PrevD;
}