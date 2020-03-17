package miPhysics.Engine;


/**
 * A regular 3D Mass module, with a given inertia, subject to potential gravity.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Mass3D extends Mass {

  public Mass3D(double M, double size, Vect3D initPos, Vect3D initPosR) {
    super(M, size, initPos, initPosR);
    setType(massType.MASS3D);
  }

  public Mass3D(double M, double size, Vect3D initPos) {
    this(M, size, initPos, new Vect3D(0,0,0));
  }

  public void compute() {
    double fric = this.getMedium().getMediumFriction();

    tmp.set(m_pos);

    // Calculate the update of the mass's position
    m_frc.mult(m_invMass);
    m_pos.mult(2 - m_invMass * fric);
    m_posR.mult(1 -m_invMass * fric);
    m_pos.sub(m_posR);
    m_pos.add(m_frc);

    // Add gravitational force.
    m_pos.sub(this.getMedium().getGravity());

    // Bring old position to delayed position and reset force buffer
    m_posR.set(tmp);
    m_frc.set(0., 0., 0.);
  }

  public void massSpecificMethod(){

  }


  public int setParam(param p, double val ){
    switch(p){
      case MASS:
        this.m_invMass = 1./val;
        return 0;
      case RADIUS:
        this.m_size = val;
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
      default:
        System.out.println("No " + p + " parameter found in " + this);
        return 0.;
    }
  }
}