package miPhysics;


/**
 * A 3D Mass Spring Oscillator with a given inertia, stiffness and damping, subject to potential gravity.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Osc3D extends Mat {

  public Osc3D(double M, double K_param, double Z_param, Vect3D initPos, Vect3D initPosR, double friction, Vect3D grav) {   
    super(M, initPos, initPosR);
    setType(matModuleType.Osc3D);
    m_pRest = new Vect3D();
    m_pRest.set(initPos);

    m_K = K_param;
    m_Z = Z_param;

    m_A = 2. - m_invMass * m_K - m_invMass * (m_Z+m_fricZ) ;
    m_B = 1. -m_invMass * (m_fricZ + m_Z) ;

    m_fricZ = friction;
    m_gFrc = new Vect3D();
    m_gFrc.set(grav);
  }

  public void compute() { 
    tmp.set(m_pos);
    
    // Remove the position offset of the module (calculate the oscillator around zero)
    m_pos.x -= m_pRest.x;
    m_pos.y -= m_pRest.y;
    m_pos.z -= m_pRest.z;
    m_posR.x -= m_pRest.x;
    m_posR.y -= m_pRest.y;
    m_posR.z -= m_pRest.z;

    // Calculate the oscillator algorithm, centered around zero.
    m_frc.mult(m_invMass);
    m_pos.mult(m_A);
    m_posR.mult(m_B);
    m_pos.sub(m_posR);
    m_pos.add(m_frc);

    // Add gravitational force.
    m_pos.sub(m_gFrc);
    
    // Restore the offset of the module
    m_pos.x += m_pRest.x;
    m_pos.y += m_pRest.y;
    m_pos.z += m_pRest.z;

    // Bring old position to delayed position and reset force buffer
    m_posR.set(tmp);
    m_frc.set(0., 0., 0.);
  }

  public void updateGravity(Vect3D grav) { 
    m_gFrc.set(grav);
  }
  public void updateFriction(double fric) { 
    m_fricZ= fric;

    m_A = 2. - m_invMass * m_K - m_invMass * (m_Z+m_fricZ) ;
    m_B = 1. -m_invMass * (m_fricZ + m_Z) ;
  }
  
  public double distRest() {  // AJOUT JV Permet de sortir le DeltaX relatif entre mas et sol d'une cel
	    return m_pos.dist(m_pRest); 
	  }

  /* Class attributes */
  
  private double m_A;
  private double m_B;
  
  private double m_K;
  private double m_Z;
  private double m_fricZ;
  private Vect3D m_gFrc;
  
  private Vect3D m_pRest;
}
