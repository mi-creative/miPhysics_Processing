package miPhysics.Engine;


/**
 * A 3D Mass Spring Oscillator with a given inertia, stiffness and damping, subject to potential gravity.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Osc3D extends Mass {

  public Osc3D(double M, double size, double K_param, double Z_param, Vect3D initPos, Vect3D initPosR) {
    super(M, size, initPos, initPosR);
    setType(massType.OSC3D);
    m_pRest = new Vect3D();
    m_pRest.set(initPos);

    m_K = K_param;
    m_Z = Z_param;

  }

  public Osc3D(double M, double size, double K_param, double Z_param, Vect3D initPos) {
    this(M, size, K_param, Z_param, initPos, new Vect3D(0,0,0));
  }


//  protected void recalcCoeffs(){
//    double fric = m_medium.getMediumFriction();
//    m_A = 2. - m_invMass * m_K - m_invMass * (m_Z + fric) ;
//    m_B = 1. -m_invMass * (fric + m_Z) ;
//  }


  public void compute() { 
    tmp.set(m_pos);
    
    // Remove the position offset of the module (calculate the oscillator around zero)
    m_pos.x -= m_pRest.x;
    m_pos.y -= m_pRest.y;
    m_pos.z -= m_pRest.z;
    m_posR.x -= m_pRest.x;
    m_posR.y -= m_pRest.y;
    m_posR.z -= m_pRest.z;

    double fric = m_medium.getMediumFriction();
    double A = 2. - m_invMass * m_K - m_invMass * (m_Z + fric) ;
    double B = 1. - m_invMass * (fric + m_Z) ;

    // Calculate the oscillator algorithm, centered around zero.
    m_frc.mult(m_invMass);
    m_pos.mult(A);
    m_posR.mult(B);
    m_pos.sub(m_posR);
    m_pos.add(m_frc);

    // Add gravitational force.
    m_pos.sub(m_medium.getGravity());
    
    // Restore the offset of the module
    m_pos.x += m_pRest.x;
    m_pos.y += m_pRest.y;
    m_pos.z += m_pRest.z;

    // Bring old position to delayed position and reset force buffer
    m_posR.set(tmp);
    m_frc.set(0., 0., 0.);
  }

  public double getElongation(){
    return this.m_pos.dist(m_pRest);
  }


  public int setParam(param p, double val ){
    switch(p){
      case MASS:
        this.m_invMass = 1./val;
        return 0;
      case RADIUS:
        this.m_size = val;
        return 0;
      case STIFFNESS:
        this.m_K = val;
        return 0;
      case DAMPING:
        this.m_Z = val;
        return 0;
      default:
        System.out.println("Cannot apply param " + val + " for "
                + this + ": no " + p + " parameter");
        return -1;
    }
  }

  public double getParam(param p){
    switch(p){
      case MASS:
        return 1./this.m_invMass;
      case RADIUS:
        return this.m_size;
      case STIFFNESS:
        return this.m_K;
      case DAMPING:
        return this.m_Z;
      default:
        System.out.println("No " + p + " parameter found in " + this);
        return 0.;
    }
  }
  
  private double m_K;
  private double m_Z;

  
  private Vect3D m_pRest;
}
