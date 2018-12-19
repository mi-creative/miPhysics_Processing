package miPhysics;


/**
 * A simplified 3D Mat module, with a given inertia, and no gravity.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Mass3DSimple extends Mat {

  public Mass3DSimple(double M, Vect3D initPos, Vect3D initPosR) {   
    super(M, initPos, initPosR);
    setType(matModuleType.Mass3DSimple);
  }

  public void compute() { 
    tmp.set(pos);
    // Calculate the update of the masse's position
    frc.mult(invMass);
    pos.mult(2);
    pos.sub(posR);
    pos.add(frc);
    // Bring old position to delayed position and reset force buffer
    posR.set(tmp);
    frc.set(0., 0., 0.);
  }
}