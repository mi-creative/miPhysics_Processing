package physicalModelling;

import processing.core.PVector;


/* MAT Abstract class */


abstract class Mat {


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

  public void init(Vect3D X, Vect3D XR) { 
    this.pos = X; 
    this.posR = XR;
  }

  public abstract void compute(); 
  
  public void applyExtForce(Vect3D force){
    frc.add(force);
  }

  protected Vect3D getPos() { 
	  //PVector tmp =  new PVector((float)pos.x,(float)pos.y,(float)pos.z);
    return pos;
  }
  
  public PVector getPosVector() {
	  PVector tmp =  new PVector((float)pos.x,(float)pos.y,(float)pos.z);
	  return tmp;
  }
  
  protected Vect3D getPosR() { 
    return posR;
  }
  protected Vect3D getFrc() { 
    return frc;
  }

  public void setMass (double M) { 
    invMass = 1 / M;
  }
  
  
  public matModuleType getType(){
    return type;
  }
  
  public void setType(matModuleType t){
    type = t;
  }

  /* Class attributes */
  public Vect3D pos;
  public Vect3D posR;
  public Vect3D frc;

  private matModuleType type;
  public double invMass;
  Vect3D tmp;
  }
