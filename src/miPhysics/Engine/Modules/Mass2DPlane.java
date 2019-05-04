package miPhysics;


/**
 * A regular 2D Mat module (constrained to the XY plane), with a given inertia, subject to potential gravity.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Mass2DPlane extends Mat {

  public Mass2DPlane(double M, Vect3D initPos, Vect3D initPosR, double friction, Vect3D grav) {
    super(M, initPos, initPosR);
    setType(matModuleType.Mass2DPlane);

    // Make sure there is no initial velocity on the Z axis
    m_posR.z = m_pos.z;

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
    m_pos.sub(m_gFrc);

    // Constrain to 2D Plane : keep Z axis value constant
    m_pos.z = tmp.z;

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