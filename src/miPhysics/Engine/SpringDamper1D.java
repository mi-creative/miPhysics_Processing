package miPhysics.Engine;


/* 1D SPRING OBJECT */

/**
 * Spring interaction: elastic interaction between two Mass elements.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class SpringDamper1D extends Interaction {

	public SpringDamper1D(double distance, double K_param, double Z_param) {
		super(distance, null, null);
		setType(interType.SPRINGDAMPER1D);
		m_K = K_param;
		m_Z = Z_param;
	}

	public void compute() {
		m_dist_1D = calcDist1D();
		applyForces1D( (m_dist_1D - m_dRest)* m_K + getVel() *  m_Z );
		m_distR_1D = m_dist_1D;
	}


	protected void initDistances() {
		m_dist_1D = this.getMat1().getPos().z - this.getMat2().getPos().z;
		m_distR_1D = this.getMat1().getPosR().z - this.getMat2().getPosR().z;
	}


	public int setParam(param p, double val ){
		switch(p){
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
			case STIFFNESS:
				return m_K;
			case DAMPING:
				return m_Z;
			default:
				System.out.println("No " + p + " parameter found in " + this);
				return 0.;
		}
	}

	protected double getVel() {
		return m_dist_1D - m_distR_1D;
	}

	public double m_dist_1D;
	public double m_distR_1D;

}