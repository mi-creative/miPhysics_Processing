package physicalModelling;


/*************************************************/
/*          THIS MODULE IS A MESS !!             */
/*************************************************/


class PlaneContact extends Link {


  public PlaneContact(double dist, double K_param, double Z_param, Mat m1, Mat m2, int or, double pos) {
    super(0., m1, m2);
    setType(linkModuleType.PlaneContact3D);

    Z = Z_param;
    K = K_param;
    dRest = dist;
    position = pos;
    orientation = or;
  }

  public void compute() {

    dlyPosForPlane = posForPlane;

    if (orientation == 0)
      posForPlane = getMat1().getPos().x;
    else if (orientation == 1)
      posForPlane = getMat1().getPos().y;
    else if (orientation == 2)
      posForPlane = getMat1().getPos().z;

    double thresholdPos = posForPlane - position -dRest ;
    double lnkFrc = - thresholdPos *(K) - (posForPlane - dlyPosForPlane) *  Z;

    if (thresholdPos < 0) {
      //println("Plane Interaction active");

      if (orientation == 0)
        getMat1().frc.x += lnkFrc;
      else if (orientation == 1)
        getMat1().frc.y += lnkFrc;
      else if (orientation == 2)
        getMat1().frc.z += lnkFrc;
    }
  }

  Mat fakePlaneMat;
  private double K;
  private double Z;

  private double dRest;
  private double position;
  private int orientation;

  double posForPlane;
  double dlyPosForPlane;
}