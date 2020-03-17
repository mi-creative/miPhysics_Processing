package miPhysics.Engine;

public class Mass1D extends Mass {

	public Mass1D(double M, double size, Vect3D initPos, Vect3D initPosR) {
		super(M, size, initPos, initPosR);
		setType(massType.MASS1D);
	}

	public Mass1D(double M, double size, Vect3D initPos) {
		this(M, size, initPos, new Vect3D(0,0,0));
	}

	public void compute() {
		double fric = this.getMedium().getMediumFriction();

		newPos = (2 - m_invMass * fric) * m_pos.z - (1 - m_invMass * fric) * m_posR.z + m_frc.z * m_invMass;
		// Check that this is OK
		newPos -= this.getMedium().getGravity().z;

		m_posR.z = m_pos.z;
		m_pos.z = newPos;
		m_frc.set(0., 0., 0.);
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


	private double newPos;
}