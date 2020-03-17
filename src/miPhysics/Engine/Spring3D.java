package miPhysics.Engine;


/* 3D SPRING OBJECT */

/**
 * Spring interaction: elastic interaction between two Mass elements.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Spring3D extends Interaction {

  public Spring3D(double distance, double K_param) {
    super(distance, null, null);
    setType(interType.SPRING3D);
    m_K = K_param;
  }

  public void compute() {
    updateSquaredDist();
    applyForces( - getElongation() * m_K );
  }

  public int setParam(param p, double val ){
    switch(p){
      case STIFFNESS:
        this.m_K = val;
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
      case DISTANCE:
        return m_dRest;
      default:
        System.out.println("No " + p + " parameter found in " + this);
        return 0.;
    }
  }


  //public double m_K;
}