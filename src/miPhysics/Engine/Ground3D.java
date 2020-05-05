package miPhysics.Engine;

/**
 * 3D Fixed point Mass module.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Ground3D extends Mass {

	/**
	 * @param size radius of the module.
	 * @param initPos initial position.
	 */
	public Ground3D(double size, Vect3D initPos) {
		super(1., size,  initPos, initPos); // the mass parameter is unused.
		setType(massType.GROUND3D);
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
