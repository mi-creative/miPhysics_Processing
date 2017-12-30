package physicalModelling;


class Osc3D extends Mat {

  public Osc3D(double M, double K_param, double Z_param, Vect3D initPos, Vect3D initPosR, double friction, Vect3D grav) {   
    super(M, initPos, initPosR);
    setType(matModuleType.Osc3D);
    p_Rest = new Vect3D();
    p_Rest.set(initPos);
    K = K_param;
    Z = Z_param;
    fricZ = friction;
    g_frc = new Vect3D();
    g_frc.set(grav);
  }

  public void compute() { 
    tmp.set(pos);
    
    // Remove the position offset of the module
    pos.x -= p_Rest.x;
    pos.y -= p_Rest.y;
    pos.z -= p_Rest.z;
    posR.x -= p_Rest.x;
    posR.y -= p_Rest.y;
    posR.z -= p_Rest.z;

    // Calculate the oscillator algorithm, centered around zero.
    frc.mult(invMass);
    pos.mult(2 - invMass * K - invMass * (Z+fricZ));
    posR.mult(1 -invMass * (fricZ + Z));
    pos.sub(posR);
    pos.add(frc);

    // Add gravitational force.
    pos.sub(g_frc);
    
    // Restore the offset of the module
    pos.x += p_Rest.x;
    pos.y += p_Rest.y;
    pos.z += p_Rest.z;
    //posR.x -= p_Rest.x;
    //posR.y -= p_Rest.y;
    //posR.z -= p_Rest.z;

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
  
  public double distRest() {  // AJOUT JV Permet de sortir le DeltaX relatif entre mas et sol d'une cel
	    return this.pos.dist(p_Rest); 
	  }

  /* Class attributes */
  
  private double K;
  private double Z;
  private double fricZ;
  private Vect3D g_frc;
  
  private Vect3D p_Rest;
  private Vect3D calcPos;
}
