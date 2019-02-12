package miPhysics;


/**
 * A regular 3D Mat module, with a given inertia, subject to potential gravity.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Mass3DSimple extends Mat {

  public Mass3DSimple(double M, Vect3D initPos, Vect3D initPosR) {
    super(M, initPos, initPosR);
    setType(matModuleType.Mass3DSimple);

  }

  public void compute() {
    tmp.set(m_pos);

    // Calculate the update of the mass's position
    m_frc.mult(m_invMass);
    m_pos.mult(2);
    m_pos.sub(m_posR);
    m_pos.add(m_frc);

    // Bring old position to delayed position and reset force buffer
    m_posR.set(tmp);
    m_frc.set(0., 0., 0.);
  }

  public void updateGravity(Vect3D grav) {
    // nothing here
  }
  public void updateFriction(double fric) {
    // nothing here
  }

}