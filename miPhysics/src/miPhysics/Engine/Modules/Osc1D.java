package miPhysics;

public class Osc1D extends Mat {

	  public Osc1D(double M, double K_param, double Z_param, Vect3D initPos, Vect3D initPosR, double friction, Vect3D grav) {   
	    super(M, initPos, initPosR);
	    setType(matModuleType.Osc1D);
	    
	    p_Rest = initPos.z;
	    
	    K = K_param;
	    Z = Z_param;
	    fricZ = friction;
	    g_frc = new Vect3D();
	    g_frc.set(grav);
	  }

	  public void compute() { 
		  
		pos.z -= p_Rest;
		posR.z -= p_Rest;
		
		newPos = (2 - invMass * (K + Z +fricZ)) * pos.z - (1 -invMass * (Z + fricZ)) * posR.z + frc.z*invMass;
		posR.z = pos.z;
		pos.z = newPos;
		frc.set(0., 0., 0.);	  
		
		pos.z += p_Rest;
		posR.z += p_Rest;

	  }

	  public void updateGravity(Vect3D grav) { 
	    g_frc.set(grav);
	  }
	  public void updateFriction(double fric) { 
	    fricZ= fric;
	  }
	  
	  public double distRest() {  // AJOUT JV Permet de sortir le DeltaX relatif entre mas et sol d'une cel
		    return (this.pos.z - p_Rest); 
		  }

	  /* Class attributes */
	  
	  private double K;
	  private double Z;
	  private double fricZ;
	  private Vect3D g_frc;
	  	  
	  double p_Rest;
	  double newPos;
	}
