package physicalModelling;


class Contact3D extends Link {

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

  public double K;
  public double Z;
}