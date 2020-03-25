package miPhysics.Renderer;

import miPhysics.Engine.Mass;
import miPhysics.Engine.Vect3D;
import miPhysics.Engine.massType;
import miPhysics.Engine.param;
import processing.core.PVector;

public class MatDataHolder{

    public MatDataHolder(){
        this.m_pos = new PVector();
        this.m_mass = 1.;
        this.m_type = massType.UNDEFINED;
        this.m_radius = 1;
    }

    public MatDataHolder(Mass element){
        this.m_pos = element.getPos().toPVector(); //new PVector(element.getPos().toPVector());
        this.m_mass = 1; //element.getParam(param.MASS);
        this.m_type = element.getType();
        this.m_radius = element.getParam(param.RADIUS);
        this.m_frc = element.getFrc().toPVector();
    }

    public MatDataHolder(Vect3D p, double m, double radius, massType t){
        //this.m_pos = new PVector();
        this.m_pos = p.toPVector();
        this.setMass(m);
        this.setType(t);
        this.setRadius(radius);
    }


    public void setPos(Vect3D p){
        this.m_pos = p.toPVector();
    }

    public void setMass(double m){
        this.m_mass = m;
    }

    public void setType(massType t){
        this.m_type = t;
    }

    public void setRadius(double radius){
        this.m_radius = radius;
    }

    public PVector getPos(){return this.m_pos;}
    public double getMass(){return this.m_mass;}
    public massType getType(){return this.m_type;}
    public double getRadius(){return this.m_radius;}

    public PVector getFrc(){return this.m_frc;}


    private PVector m_pos;
    private double m_mass;
    private massType m_type;
    private double m_radius;
    private PVector m_frc;
    private String m_name;

}