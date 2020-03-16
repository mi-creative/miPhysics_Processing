package miPhysics;



/**
 * Plane Contact: contact interaction between a Mass module and a 2D plane.
 * This module's implementation is a little weird, the physics seem OK though
 *
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */

public class PlaneContact3D extends Interaction {

  /*
  public PlaneContact3D(double K_param, double Z_param, Plane pl){
    super(0, null, null);
    setType(interType.PLANECONTACT3D);
    m_Z = Z_param;
    m_K = K_param;

    m_plane = pl;
  }


  public void compute(){
  }
  */

  public PlaneContact3D(double K_param, double Z_param, int or, double pos) {
    super(0., null, null);
    setType(interType.PLANECONTACT3D);

    m_Z = Z_param;
    m_K = K_param;

    m_position = pos;
    m_orientation = or;
  }

  public void compute() {

    m_dRest = this.getMat1().getParam(param.RADIUS);

    m_dlyPosForPlane = m_posForPlane;

    if (m_orientation == 0)
      m_posForPlane = getMat1().getPos().x;
    else if (m_orientation == 1)
      m_posForPlane = getMat1().getPos().y;
    else if (m_orientation == 2)
      m_posForPlane = getMat1().getPos().z;

    double thresholdPos = m_posForPlane - m_position - m_dRest ;
    double lnkFrc = - thresholdPos *(m_K) - (m_posForPlane - m_dlyPosForPlane) *  m_Z;


    if (thresholdPos < 0) {
      if (m_orientation == 0)
        getMat1().m_frc.x += lnkFrc;
      else if (m_orientation == 1)
        getMat1().m_frc.y += lnkFrc;
      else if (m_orientation == 2)
        getMat1().m_frc.z += lnkFrc;
    }
  }



  public int setParam(param p, double val ){
    switch(p){
      case STIFFNESS:
        this.m_K = val;
        return 0;
      case DAMPING:
        this.m_Z = val;
        return 0;
      case DISTANCE:
        this.changeDRest(val);
        return 0;
      default:
        System.out.println("Cannot apply param " + val + " for "
                + this + ": no " + p + " parameter");
        return -1;
    }
  }

  public double getParam(param p){
    switch(p){
      case STIFFNESS:
        return m_K;
      case DAMPING:
        return m_Z;
      case DISTANCE:
        return m_dRest;
      default:
        System.out.println("No " + p + " parameter found in " + this);
        return 0.;
    }
  }

  public int getOrientation(){return m_orientation;}
  public double getPosition(){return m_position;}

  private double m_position;
  private int m_orientation;

  double m_posForPlane;
  double m_dlyPosForPlane;

  //Plane m_plane;

}
