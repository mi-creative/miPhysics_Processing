package miPhysics;

public class Osc1D extends Mass {

	public Osc1D(double M, double size, double K_param, double Z_param, Vect3D initPos, Vect3D initPosR) {
		super(M, size, initPos, initPosR);
		setType(massType.OSC1D);

		m_pRest = initPos.z;

		m_K = K_param;
		m_Z = Z_param;

		//this.recalcCoeffs();
	}

	public Osc1D(double M, double size, double K_param, double Z_param, Vect3D initPos) {
		this(M, size, K_param, Z_param, initPos, new Vect3D(0,0,0));
	}

	public void compute() {

		m_pos.z -= m_pRest;
		m_posR.z -= m_pRest;

		double fric = m_medium.getMediumFriction();
		double A = 2. - m_invMass * m_K - m_invMass * (m_Z + fric) ;
		double B = 1. - m_invMass * (fric + m_Z) ;


		newPos = A * m_pos.z - B * m_posR.z + m_frc.z * m_invMass;
		newPos -= this.getMedium().getGravity().z;

		m_posR.z = m_pos.z;
		m_pos.z = newPos;
		m_frc.set(0., 0., 0.);

		m_pos.z += m_pRest;
		m_posR.z += m_pRest;

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



	public double distRest() {  // AJOUT JV Permet de sortir le DeltaX relatif entre mas et sol d'une cel
		return (m_pos.z - m_pRest);
	}

	private double m_K;
	private double m_Z;

	double m_pRest;
	double newPos;
}
