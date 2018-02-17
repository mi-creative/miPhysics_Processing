package physicalModelling;
 

/* LINK abstract class */

abstract class Link {

  public Link(double distance, Mat m1, Mat m2) {
    dRest = distance;
    mat1 = m1;
    mat2 = m2;    
    type = linkModuleType.UNDEFINED;
  }

  public abstract void compute(); 

  public void connect (Mat m1, Mat m2) {
    mat1 = m1;
    mat2 = m2;
  }

  public Mat getMat1() { 
    return mat1;
  }
  public Mat getMat2() { 
    return mat2;
  }
  
 public linkModuleType getType(){
    return type;
  }
  
  public void setType(linkModuleType t){
    type = t;
  }

  public void initDistances() {
    dist = mat1.getPos().dist(mat2.getPos());
    distR = mat1.getPosR().dist(mat2.getPosR());
  }

  public double calcNewEuclidDist() {
    distR = dist;
    dist = mat1.getPos().dist(mat2.getPos());
    return dist;
  }

  public void updateDistManual(double d) {
    distR = dist;
    dist = d;
  }
  
  public void changeDRest(double d) {
	  dRest = d;
  }

  public double getSpeed() { 
    return dist-distR;
  }

  public void applyForces(double lnkFrc) {

    double x_proj = (getMat1().pos.x - getMat2().pos.x) / dist;
    double y_proj = (getMat1().pos.y - getMat2().pos.y) / dist;
    double z_proj = (getMat1().pos.z - getMat2().pos.z) / dist;

    getMat1().frc.x += lnkFrc * x_proj;
    getMat1().frc.y += lnkFrc * y_proj;
    getMat1().frc.z += lnkFrc * z_proj;

    getMat2().frc.x -= lnkFrc * x_proj;
    getMat2().frc.y -= lnkFrc * y_proj;
    getMat2().frc.z -= lnkFrc * z_proj;
  }

  /* Class attributes */
  private linkModuleType type;
  private Mat mat1;
  private Mat mat2;

  private double dist;
  private double distR;
  public double dRest;
}