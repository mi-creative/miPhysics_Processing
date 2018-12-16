package physicalModelling;


/**
 * A regular 3D Mat module, with a given inertia, subject to potential gravity.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Mass2DPlane extends Mat {

  public Mass2DPlane(double M, Vect3D initPos, Vect3D initPosR, double friction, Vect3D grav) {   
    super(M, initPos, initPosR);
    setType(matModuleType.Mass2DPlane);
    
    // Make sure there is no initial velocity on the Z axis
    posR.z = pos.z;

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
    pos.sub(g_frc);
    
    // Constrain to 2D Plane : keep Z axis value constant
    pos.z = tmp.z;

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