package physicalModelling;

public class Ground1D extends Mat {
	  
	public Ground1D(Vect3D initPos) {   
		    super(1., initPos, initPos); // the mass parameter is unused.
		    setType(matModuleType.Ground1D);
		  }
		  public void compute() { 
		    frc.set(0., 0., 0.);
		  }
}
