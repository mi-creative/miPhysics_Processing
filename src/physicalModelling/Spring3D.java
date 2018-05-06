package physicalModelling;


/* 3D SPRING OBJECT */

class Spring3D extends Link {

  public Spring3D(double distance, double K_param, Mat m1, Mat m2) {
    super(distance, m1, m2);
    setType(linkModuleType.Spring3D);
    K = K_param;
  }

  public void compute() {
    double d = calcNewEuclidDist();
    double lnkFrc = -(d-dRest)*(K);
    this.applyForces(lnkFrc);
  }
  
  public void changeStiffness(double stiff) {
	  K = stiff;
  }
  
  public void changeDamping(double damp) {
	  // no operation here
  }

  public double K;
}