package miPhysics;


/**
 * A regular 3D Mat module, with a given inertia, subject to potential gravity.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Mass3D extends Mat {

  public Mass3D(double M, Vect3D initPos, Vect3D initPosR, double friction, Vect3D grav) {
    super(M, initPos, initPosR);
    setType(matModuleType.Mass3D);

    m_fricZ = friction;
    m_gFrc = new Vect3D();
    m_gFrc.set(grav);
  }

  public void compute() {
    tmp.set(m_pos);

    // Calculate the update of the mass's position
    m_frc.mult(m_invMass);
    m_pos.mult(2 - m_invMass * m_fricZ);
    m_posR.mult(1 -m_invMass * m_fricZ);
    m_pos.sub(m_posR);
    m_pos.add(m_frc);

    // Add gravitational force.
    m_pos.sub(m_gFrc);

    // Bring old position to delayed position and reset force buffer
    m_posR.set(tmp);
    m_frc.set(0., 0., 0.);
  }

  public void updateGravity(Vect3D grav) {
    m_gFrc.set(grav);
  }
  public void updateFriction(double fric) {
    m_fricZ= fric;
  }

  /* Class attributes */
  private double m_fricZ;
  private Vect3D m_gFrc;
}