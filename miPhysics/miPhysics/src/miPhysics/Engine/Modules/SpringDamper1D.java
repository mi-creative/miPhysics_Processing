package miPhysics;


/* 1D SPRING OBJECT */

/**
 * Spring interaction: elastic interaction between two Mat elements.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class SpringDamper1D extends Link {

	public SpringDamper1D(double distance, double K_param, double Z_param, Mat m1, Mat m2) {
		super(distance, m1, m2);
		setType(linkModuleType.SpringDamper1D);
		m_K = K_param;
		m_Z = Z_param;
	}

	public void compute() {
		m_dist_1D = calcDist1D();
		applyForces1D( (m_dist_1D - m_dRest)* m_K + getVel() *  m_Z );
		m_distR_1D = m_dist_1D;
	}


	public void changeStiffness(double stiff) {
		m_K = stiff;
	}

	public void changeDamping(double damp) {
		m_Z = damp;
	}

	protected void initDistances() {
		m_dist_1D = this.getMat1().getPos().z - this.getMat2().getPos().z;
		m_distR_1D = this.getMat1().getPosR().z - this.getMat2().getPosR().z;
	}

	protected double getVel() {
		return m_dist_1D - m_distR_1D;
	}

	public double m_dist_1D;
	public double m_distR_1D;

	public double m_K;
	public double m_Z;
}