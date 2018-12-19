package miPhysics;

/**
 * A 3D Haptic Input Mat module. Position received from outside world, force send to outside world.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class HapticInput3D extends Mat {

  public HapticInput3D(Vect3D initPos, int smoothingFactor) {   
    super(1., initPos, initPos);
    setType(matModuleType.HapticInput3D);
    
    directPos = new Vect3D(initPos);
    
    smooth = 1./(float)smoothingFactor;

  }

  public void compute() { 
	  
	  /* 
	   * smooth the position input value according to factor
	   * (Exponentially weighted moving average)
	   */
	  
	  this.pos.x = smooth * directPos.x + (1-smooth) * this.pos.x;
	  this.pos.y = smooth * directPos.y + (1-smooth) * this.pos.y;
	  this.pos.z = smooth * directPos.z + (1-smooth) * this.pos.z;
	  
      /* 
       * The haptic input is probably low rate:
       * The force needs to accumulate in the force buffer during high rate steps,
       * The haptic input will reset the force once it has consumed it.
       */
	  //frc.set(0., 0., 0.);
  }
  
  
  public void applyInputPosition(Vect3D outsidePos) {
	  this.directPos.x = outsidePos.x;
	  this.directPos.y = outsidePos.y;
	  this.directPos.z = outsidePos.z;
  }
  
  public Vect3D applyOutputForce() {
	  /*
	   * Consume the force accumulation buffer value 
	   * (send it to device), and reset it to zero.
	   */
	  Vect3D outFrc = new Vect3D(this.frc.x, this.frc.y, this.frc.z);
	  frc.set(0,0,0);
	  return outFrc;
  }
  

  /* Class attributes */
  private double fricZ;
  private Vect3D g_frc;
  
  private double smooth;
  private Vect3D directPos;
}