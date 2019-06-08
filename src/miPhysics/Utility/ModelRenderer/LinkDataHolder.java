package miPhysics;

public class LinkDataHolder{

    public LinkDataHolder(){
        this.m_p1 = new Vect3D();
        this.m_p2 = new Vect3D();

        this.m_elong = 0;

        this.m_type = linkModuleType.UNDEFINED;
    }


    public LinkDataHolder(Vect3D p1, Vect3D p2, double elong, linkModuleType t){
        this.m_p1 = new Vect3D(p1);
        this.m_p2 = new Vect3D(p2);
        this.setElongation(elong);
        this.setType(t);
    }


    public void setP1(Vect3D p){
        this.m_p1.set(p);
    }

    public void setP2(Vect3D p){
        this.m_p2.set(p);
    }

    public void setElongation(double m){
        this.m_elong = m;
    }

    public void setType(linkModuleType t){
        this.m_type = t;
    }

    public Vect3D getP1(){return this.m_p1;}
    public Vect3D getP2(){return this.m_p2;}
    public double getElongation(){return this.m_elong;}
    public linkModuleType getType(){return this.m_type;}

    private Vect3D m_p1;
    private Vect3D m_p2;

    private double m_elong;

    private linkModuleType m_type;

}