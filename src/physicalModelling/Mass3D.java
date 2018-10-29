package physicalModelling;


/**
 * A regular 3D Mat module, with a given inertia, subject to potential gravity.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Mass3D extends Mat {

  public Mass3D(double M, Vect3D initPos, Vect3D initPosR, double friction, Vect3D grav) {   
    super(M, initPos, initPosR);
    setType(matModuleType.Mass3D);

    fricZ = friction;
    g_frc = new Vect3D();
    g_frc.set(grav);
  }

  public void compute() { 
    tmp.set(pos);
    // Calculate the update of the mass's position
    frc.mult(invMass);
    pos.mult(2 - invMass * fricZ);
    posR.mult(1 -invMass * fricZ);
    pos.sub(posR);
    pos.add(frc);

    // Add gravitational force.
    pos.sub(g_frc);

    // Bring old position to delayed position and reset force buffer
    posR.set(tmp);
    frc.set(0., 0., 0.);
  }

  public void updateGravity(Vect3D grav) { 
    g_frc.set(grav);
  }
  public void updateFriction(double fric) { 
    fricZ= fric;
  }

  /* Class attributes */
  private double fricZ;
  private Vect3D g_frc;
}