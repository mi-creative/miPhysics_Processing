package physicalModelling;
 

/* LINK abstract class */

/**
 * Abstract Link class.
 * Defines generic structure and behavior for all possible Links.
 * 
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public abstract class Link {

/**
 * Constructor method.
 * @param distance resting distance of the Link.
 * @param m1 connected Mat at one end.
 * @param m2 connected Mat at other end.
 */
public Link(double distance, Mat m1, Mat m2) {
    dRest = distance;
    mat1 = m1;
    mat2 = m2;    
    type = linkModuleType.UNDEFINED;
  }

/**
 * Compute behavior of the Link (depends on the concrete implementation of concerned module).
 * 
 */
public abstract void compute(); 

/**
 * Connect the Link to two Mat modules.
 * @param m1 connected Mat at one end.
 * @param m2 connected Mat at other end.
 */
public void connect (Mat m1, Mat m2) {
    mat1 = m1;
    mat2 = m2;
  }

/**
 * Access the first Mat connected to this Link.
 * @return the first Mat module.
 */
public Mat getMat1() { 
    return mat1;
  }

/**
 * Access the second Mat connected to this Link.
 * @return the second Mat module.
 */
public Mat getMat2() { 
    return mat2;
  }

/**
 * Get the type of the Link module.
 * @return the Link module type.
 */
protected linkModuleType getType(){
    return type;
  }
  

/**
 * Set the type of the Link module.
 * @param t the Link module type.
 */
protected void setType(linkModuleType t){
    type = t;
  }

/**
 * Initialise distance and delayed distance for this Link.
 */
protected void initDistances() {
    dist = mat1.getPos().dist(mat2.getPos());
    distR = mat1.getPosR().dist(mat2.getPosR());
  }

/**
 * Calculate the euclidian distance between both Mats connected to this Link.
 * @return
 */
protected double calcNewEuclidDist() {
    distR = dist;
    dist = mat1.getPos().dist(mat2.getPos());
    return dist;
  }


/**
 * Set the distance stored inside the link (and apply previous one to delayed distance).
 * @param d distance to apply.
 */
protected void updateDistManual(double d) {
    distR = dist;
    dist = d;
  }
  
/**
 * Change resting distance for this Link.
 * @param d new resting distance.
 */
public void changeDRest(double d) {
	  dRest = d;
  }
  
/**
 * Change the stiffness of this Link.
 * @param k stiffness value.
 */
public abstract void changeStiffness(double k);

/**
 * Change the damping of this Link.
 * @param z the damping value.
 */
public abstract void changeDamping(double z);  

/**
 * Get speed (per sample) between the two connected Mat modules
 * @return per sample speed value.
 */
protected double getSpeed() { 
    return dist-distR;
  }

/**
 * Apply forces to the connected Mat modules
 * @param lnkFrc force to apply symetrically.
 */
protected void applyForces(double lnkFrc) {

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
  protected double dRest;
}