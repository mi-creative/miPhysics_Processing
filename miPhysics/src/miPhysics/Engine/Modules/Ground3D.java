package miPhysics;

/**
 * Fixed point Mat module.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Ground3D extends Mat {
	  public Ground3D(Vect3D initPos) {   
	    super(1., initPos, initPos); // the mass parameter is unused.
	    setType(matModuleType.Ground3D);
	  }
	  public void compute() { 
	    frc.set(0., 0., 0.);
	  }
	}
