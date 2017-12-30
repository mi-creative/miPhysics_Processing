package physicalModelling;


class SpringDamper3D extends Link {

  public SpringDamper3D(double distance, double K_param, double Z_param, Mat m1, Mat m2) {
    super(distance, m1, m2);
    setType(linkModuleType.SpringDamper3D);
    K = K_param;
    Z = Z_param;
  }

  public void compute() {
    double d = calcNewEuclidDist();
    double lnkFrc = -(d-dRest)*(K) - getSpeed() *  Z;
    this.applyForces(lnkFrc);
  }

  public double K;
  public double Z;
}