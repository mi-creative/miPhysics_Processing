package miPhysics;

public class Ground1D extends Mass {

	public Ground1D(double size, Vect3D initPos) {
		super(1., size, initPos, initPos); // the mass parameter is unused.
		setType(massType.GROUND1D);
	}

	public int setParam(param p, double val ){
		switch(p){
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
			case RADIUS:
				return this.m_size;
			default:
				System.out.println("No " + p + " parameter found in " + this);
				return 0.;
		}
	}

	public void compute() {
		m_frc.set(0., 0., 0.);
	}
}
