package miPhysics;

public class Mass1D extends Mat {

	public Mass1D(double M, Vect3D initPos, Vect3D initPosR, double friction, Vect3D grav) {
		super(M, initPos, initPosR);
		setType(matModuleType.Mass1D);

		m_fricZ = friction;
		m_gFrc = new Vect3D();
		m_gFrc.set(grav);
	}

	public void compute() {
		newPos = (2 - m_invMass * m_fricZ) * m_pos.z - (1 - m_invMass * m_fricZ) * m_posR.z + m_frc.z * m_invMass;
		m_posR.z = m_pos.z;
		m_pos.z = newPos;
		m_frc.set(0., 0., 0.);
	}

	public void updateGravity(Vect3D grav) {
		m_gFrc.set(grav);
	}
	public void updateFriction(double fric) {
		m_fricZ= fric;
	}

	/* Class attributes */
	private double m_fricZ;
	private Vect3D m_gFrc;

	private double newPos;
}