package miPhysics;

/**
 * Damper interaction: viscous force between two Mat elements.
 * 
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Damper3D extends Link {

  public Damper3D(double Z_param, Mat m1, Mat m2) {
    super(0., m1, m2);
    setType(linkModuleType.Damper3D);
    m_Z = Z_param;
  }

  public void compute() {
    updateEuclidDist();
    applyForces( - getVel() *  m_Z );
  }
  
  public boolean changeStiffness(double stiff) {
    // stiffness is unused in this module...
    this.m_K = 0;
    return false;
  }

}