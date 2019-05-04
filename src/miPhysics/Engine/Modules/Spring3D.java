package miPhysics;


/* 3D SPRING OBJECT */

/**
 * Spring interaction: elastic interaction between two Mat elements.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Spring3D extends Link {

  public Spring3D(double distance, double K_param, Mat m1, Mat m2) {
    super(distance, m1, m2);
    setType(linkModuleType.Spring3D);
    m_K = K_param;
  }

  public void compute() {
    updateEuclidDist();
    applyForces( -(m_dist - m_dRest) * m_K );
  }

  
  public boolean changeDamping(double damp) {
      // damping is unused in this module...
      this.m_Z = 0;
      return false;
  }

  //public double m_K;
}