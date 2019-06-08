package miPhysics;

public class MatDataHolder{

    public MatDataHolder(){
        this.m_pos = new Vect3D();
        this.m_mass = 1.;
        this.m_type = matModuleType.UNDEFINED;
    }

    public MatDataHolder(Mat element){
        this.setPos(element.getPos());
        this.m_mass = element.getMass();
        this.m_type = element.getType();
    }

    public MatDataHolder(Vect3D p, double m, matModuleType t){
        this.m_pos = new Vect3D();
        this.setPos(p);
        this.setMass(m);
        this.setType(t);
    }


    public void setPos(Vect3D p){
        this.m_pos.set(p);
    }

    public void setMass(double m){
        this.m_mass = m;
    }

    public void setType(matModuleType t){
        this.m_type = t;
    }

    public Vect3D getPos(){return this.m_pos;}
    public double getMass(){return this.m_mass;}
    public matModuleType getType(){return this.m_type;}

    private Vect3D m_pos;
    private double m_mass;
    private matModuleType m_type;

}