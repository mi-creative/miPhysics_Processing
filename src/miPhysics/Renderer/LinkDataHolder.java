package miPhysics.Renderer;

import miPhysics.Engine.Vect3D;
import miPhysics.Engine.interType;
import processing.core.PVector;

public class LinkDataHolder{

    public LinkDataHolder(){
        this.m_p1 = new PVector();
        this.m_p2 = new PVector();

        this.m_elong = 0;

        this.m_type = interType.UNDEFINED;
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

    private PVector m_p1;
    private PVector m_p2;

    private double m_elong;

    private interType m_type;

}