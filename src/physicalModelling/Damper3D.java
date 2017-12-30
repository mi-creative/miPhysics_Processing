package physicalModelling;

class Damper3D extends Link {

  public Damper3D(double Z_param, Mat m1, Mat m2) {
    super(0., m1, m2);
    setType(linkModuleType.Damper3D);
    Z = Z_param;
  }

  public void compute() {
    calcNewEuclidDist();
    double lnkFrc = - getSpeed() *  Z;
    this.applyForces(lnkFrc);
  }

  public double Z;
}