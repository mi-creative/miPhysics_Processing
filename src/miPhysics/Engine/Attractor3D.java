package miPhysics.Engine;


/**
 * Attraction interaction: distant pull between two Mass elements.
 * Experimental implementation !
 *
 * @author James Leonard / james.leonard@gipsa-lab.fr
 *
 */
public class Attractor3D extends Interaction {

    /**
     * Attractor module
     * @param limitDist threshold distance below which the attraction force is null.
     * @param attrFactor the attraction force factor.
     */
    public Attractor3D(double limitDist, double attrFactor) {
        super(limitDist, null, null);
        m_attrFactor = attrFactor;
    }


    public void compute() {

        updateSquaredDist();
        if(m_distSquared > m_dRsquared)
            this.applyForces(-m_attrFactor / (this.getDsquared()));
    }

    public int setParam(param p, double val ){
        switch(p){
            case ATTRACTION:
                this.m_attrFactor = val;
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
            case ATTRACTION:
                return m_attrFactor;
            case DISTANCE:
                return m_dRest;
            default:
                System.out.println("No " + p + " parameter found in " + this);
                return 0.;
        }
    }


    private double m_attrFactor;
}