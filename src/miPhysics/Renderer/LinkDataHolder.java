package miPhysics.Renderer;

import miPhysics.Engine.Vect3D;
import miPhysics.Engine.interType;
import miPhysics.Engine.Interaction;
import miPhysics.Engine.param;
import processing.core.PVector;

public class LinkDataHolder{

    public LinkDataHolder(){
        this.m_p1 = new PVector();
        this.m_p2 = new PVector();

        this.m_elong = 0;

        this.m_type = interType.UNDEFINED;
    }

    public LinkDataHolder(Interaction element){
        double dist = 0;
        if(element.getType() == interType.SPRINGDAMPER1D)
            dist = element.calcDist1D();
        else if(element.getType() == interType.CONTACT3D)
            dist = 0;
        else if(element.getType() == interType.PLANECONTACT3D)
            dist = 0;
        else
            dist = element.getElongation() / element.getParam(param.DISTANCE);

        this.m_p1 = element.getMat1().getPos().toPVector();
        this.m_p2 = element.getMat2().getPos().toPVector();
        this.setElongation(dist);
        this.setType(element.getType());
        this.setName(element.getName());
    }

    public LinkDataHolder(Vect3D p1, Vect3D p2, double elong, interType t){
        this.m_p1 = p1.toPVector();
        this.m_p2 = p2.toPVector();
        this.setElongation(elong);
        this.setType(t);
    }


    public void setP1(Vect3D p){
        this.m_p1 = p.toPVector();
    }

    public void setP2(Vect3D p){
        this.m_p2 = p.toPVector();
    }

    public void setElongation(double m){
        this.m_elong = m;
    }

    public void setType(interType t){
        this.m_type = t;
    }

    public PVector getP1(){return this.m_p1;}
    public PVector getP2(){return this.m_p2;}
    public double getElongation(){return this.m_elong;}
    public interType getType(){return this.m_type;}

    public void setName(String n){
        m_name = n;
    }
    public String getName(){
        return m_name;
    }

    private PVector m_p1;
    private PVector m_p2;

    private double m_elong;
    private String m_name;

    private interType m_type;

}