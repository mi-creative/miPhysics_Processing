package miPhysics.Engine;


/**
 * Spring-Damper interaction: viscoelastic interaction between two Mass elements.
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class SpringDamper3D extends Interaction {

    public SpringDamper3D(double distance, double K_param, double Z_param) {
        super(distance, null, null);
        setType(interType.SPRINGDAMPER3D);
        m_K = K_param;
        m_Z = Z_param;
    }



    public int setParam(param p, double val ){
        switch(p){
            case STIFFNESS:
                this.m_K = val;
                return 0;
            case DAMPING:
                this.m_Z = val;
                return 0;
            case DISTANCE:
                this.changeDRest(val);
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
            case DISTANCE:
                return m_dRest;
            default:
                System.out.println("No " + p + " parameter found in " + this);
                return 0.;
        }
    }

    public void compute() {
        m_dist = m_mat1.m_pos.dist(m_mat2.m_pos);
        applyForcesAndShift(-(m_dist - m_dRest) * m_K - (m_dist - m_prevDist) * m_Z);

        //updateSquaredDist();
        //applyForces( -getElongation() * m_K - getRelativeVelocity() *  m_Z );
    }

}