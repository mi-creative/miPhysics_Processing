package miPhysics;
import processing.core.PVector;

/**
 * Abstract class defining Material points.
 * 
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public abstract class Mat {


/**
 * Constructor method.
 * 
 * @param M mass value.
 * @param initPos initial position.
 * @param initPosR delayed initial position.
 */
public Mat(double M, Vect3D initPos, Vect3D initPosR) {
    pos = new Vect3D(0., 0., 0.);
    posR = new Vect3D(0., 0., 0.);
    frc = new Vect3D(0., 0., 0.);
    tmp = new Vect3D();

    type = matModuleType.UNDEFINED;

    setMass(M);
    pos.set(initPos);
    posR.set(initPosR);

    frc.set(0., 0., 0.);
  }

/**
 * Initialise the Mat module.
 * @param X initial position.
 * @param XR initial delayed position.
 */
protected void init(Vect3D X, Vect3D XR) { 
    this.pos = X; 
    this.posR = XR;
  }

/**
 * Compute the physics of the Mat module.
 * 
 */
public abstract void compute(); 
  
/**
 * Apply external force to this Mat module.
 * @param force force to apply.
 */
protected void applyExtForce(Vect3D force){
    frc.add(force);
  }

/**
 * Get the current position of this Mat module.
 * @return the module position.
 */
protected Vect3D getPos() { 
	  //PVector tmp =  new PVector((float)pos.x,(float)pos.y,(float)pos.z);
    return pos;
  }

/**
 * Set the current position of this Mat module.
 * @param newPos the target position to set.
 * @return the module position.
 */
protected void setPos(Vect3D newPos) { 
	pos.set(newPos);
	posR.set(newPos);
  }


  
/**
 * Get the current position of this Mat module (in a PVector format).
 * @return the module position.
 */
protected PVector getPosVector() {
	  PVector tmp =  new PVector((float)pos.x,(float)pos.y,(float)pos.z);
	  return tmp;
  }
  
/**
 * Get the delayed position of the module.
 * @return the delayed position.
 */
protected Vect3D getPosR() { 
    return posR;
  }

/**
 * Get the value in the force buffer.
 * @return force value.
 */
protected Vect3D getFrc() { 
    return frc;
  }

/**
 * Set the mass parameter.
 * @param M mass value.
 */
public void setMass (double M) { 
    invMass = 1 / M;
  }
  
  
/**
 * Get the type of this Mat module.
 * @return the type of the current Mat module.
 */
protected matModuleType getType(){
    return type;
  }
  
/**
 * Set the module type for this Mat module.
 * @param t the Mat type module to set.
 */
protected void setType(matModuleType t){
    type = t;
  }

  /* Class attributes */

protected Vect3D pos;
protected Vect3D posR;
protected Vect3D frc;
private matModuleType type;
public double invMass;
Vect3D tmp;
  
}
