package miPhysics;


/**
 * Spring-Damper interaction: viscoelastic interaction between two Mat elements.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class SpringDamper3D extends Link {

    public SpringDamper3D(double distance, double K_param, double Z_param, Mat m1, Mat m2) {
        super(distance, m1, m2);
        setType(linkModuleType.SpringDamper3D);
        m_K = K_param;
        m_Z = Z_param;

        // for experimental implementation
        m_PrevD = calcDelayedDistance();
    }

    public void compute() {
        updateEuclidDist();
        applyForces( -(m_dist-m_dRest)*(m_K) - getVel() *  m_Z );
    }
  
  /*public void compute() {
	    d = updateEuclidDist();
	    double invD = 1./d;
	    double f_algo = -K * (1 - dRest*invD) - Z * (1 - PrevD*invD);
	    this.applyForces(new Vect3D(f_algo*getDx(), f_algo*getDy(), f_algo*getDz()));		
	    PrevD = d;
	  }*/

    public void changeStiffness(double stiff) {
        m_K = stiff;
    }

    public void changeDamping(double damp) {
        m_Z = damp;
    }

    public double m_K;
    public double m_Z;
    public double m_PrevD;
}