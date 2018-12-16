package physicalModelling;

public class Mass1D extends Mat {

	  public Mass1D(double M, Vect3D initPos, Vect3D initPosR, double friction, Vect3D grav) {   
	    super(M, initPos, initPosR);
	    setType(matModuleType.Mass1D);
	    
	    fricZ = friction;
	    g_frc = new Vect3D();
	    g_frc.set(grav);
	  }

	  public void compute() { 
		newPos = (2 - invMass * fricZ) * pos.z - (1 -invMass * fricZ) * posR.z + frc.z*invMass;
		posR.z = pos.z;
		pos.z = newPos;
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
	  
	  private double newPos;
	}