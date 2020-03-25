

import miPhysics.Engine.*;
import miPhysics.Renderer.*;

import peasy.*;
PeasyCam cam;

int displayRate = 90;

float m = 1.0;
float k = 0.001;
float z = 0.01;
float dist = 70;

PhyModel mac3;

/*  global physical model object : will contain the model and run calculations. */
PhysicsContext phys;

ModelRenderer renderer;


void setup() {
  frameRate(displayRate);
  //size(1000, 700, P3D);
  fullScreen(P3D);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(100);
  cam.setMaximumDistance(5500);
  
  phys = new PhysicsContext(1300, displayRate);
  
  
  
  
  Medium med = new Medium(0.00001, new Vect3D(0, -0.00,0.0));
  
  // Build an encapsulated macro element.
  miString mac = new miString("str1", med, 60, 10, 1, 0.005, 0.01, 10, 0.1);
  mac.changeToFixedPoint("m_0");
  mac.changeToFixedPoint("m_59");
  mac.rotate(0,PI/2,0);
  mac.translate(0, 0, 100);
  mac.addInOut("driver", new Driver3D(), "m_10");
  
  PhyModel miniModel = new PhyModel("extra", med);
  miniModel.addMass("mass", new Mass3D(140, 40, new Vect3D(400,0,20)));
  mac.addPhyModel(miniModel); 
  mac.addInteraction("sp", new SpringDamper3D(60, 0.01, 0.1), mac.getMass("m_35"), miniModel.getMass("mass"));

  miString miniModel2 = new miString("ministr", med, 60, 10, 0.1, 0.005, 0.01, 10, 10);
  miniModel2.rotate(0,PI/2,0);
  miniModel2.translate(400, 0, 20);
  mac.addPhyModel(miniModel2);
  mac.addInteraction("sp2", new SpringDamper3D(20, 0.01, 0.1), miniModel2.getMass("m_0"), miniModel.getMass("mass"));


   PhyModel m = new PhyModel("collider", med);
   m.addMass("mass", new Mass3D(140, 40, new Vect3D(200,0,0)));
   m.addMass("mass2", new Osc3D(140, 40, 0.001, 0.001, new Vect3D(240,0,0)));
   m.addInteraction("sp", new SpringDamper3D(40, 100, 10), "mass", "mass2" );
   
   m.addInOut("driver", new Driver3D(), "mass");

  // Add the macro element to the top-level physics scene
  phys.mdl().addPhyModel(mac);
  phys.mdl().addPhyModel(m);
  
  phys.colEngine().addCollision(mac,m,0.1, 0.01);
  phys.colEngine().addCollision(mac, miniModel2, 0.01, 0.03);
  phys.init(); 
  
  renderer = new ModelRenderer(this);
  renderer.setZoomVector(1,1,1);
}

void draw() {
  directionalLight(251, 102, 126, 0, 1, 0);
  ambientLight(102, 102, 102);
  background(0);
  stroke(255);
  
  /* Calculate Physics */
  phys.compute();
  renderer.renderScene(phys);
  

}

/* Trigger random forces on the mass */
void keyPressed() {
  if (key == ' '){
    for(Driver3D driver : phys.mdl().getPhyModel("str1").getDrivers())
      driver.applyFrc(new Vect3D(random(-1,1),random(-1,1),random(-1,1)));
  }
  if(key == 'a'){
    for(Driver3D driver: phys.mdl().getPhyModel("collider").getDrivers())
      driver.applyFrc(new Vect3D(0, 0, 55));
  }
  if(key == 'z')
    phys.mdl().removeInteraction("sp2");
}
