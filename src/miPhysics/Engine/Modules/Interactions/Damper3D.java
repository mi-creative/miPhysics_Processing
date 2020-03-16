package miPhysics;

/**
 * Damper interaction: viscous force between two Mass elements.
 * 
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Damper3D extends Interaction {

  public Damper3D(double Z_param) {
    super(0., null, null);
    setType(interType.DAMPER3D);
    m_Z = Z_param;
  }

  public void compute() {
    updateSquaredDist();
    applyForces( - getRelativeVelocity() *  m_Z );
  }


  public int setParam(param p, double val ){
    switch(p){
      case DAMPING:
        this.m_Z = val;
        return 0;
      default:
        System.out.println("Cannot apply param " + val + " for "
                + this + ": no " + p + " parameter");
        return -1;
    }
  }

  public double getParam(param p){
    switch(p){
      case DAMPING:
        return m_Z;
      default:
        System.out.println("No " + p + " parameter found in " + this);
        return 0.;
    }
  }


}