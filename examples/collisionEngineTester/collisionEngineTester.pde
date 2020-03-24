

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
  
  
  
  
  Medium med = new Medium(0.000001, new Vect3D(0, -0.00,0.0));
  
  // Build an encapsulated macro element.
  miString mac = new miString("str1", med, 60, 10, 1, 0.005, 0.01, 10, 0.1);
  mac.changeToFixedPoint("m_0");
  mac.changeToFixedPoint("m_59");
  mac.rotate(0,PI/2,0);
  mac.translate(0, 0, 100);
  mac.addInOut("driver", new Driver3D(), "m_10");

   PhyModel m = new PhyModel("collider", med);
   //miString m = new miString("str2", med, 3, 10, 1, 0.005, 0.01, 10, 10);
   //m.rotate(0, PI/2, 00);
   //   m.translate(-50, 0, -50);

   m.addMass("mass", new Mass3D(140, 40, new Vect3D(100,0,0)));
   m.addMass("mass2", new Mass3D(140, 40, new Vect3D(140,0,0)));
   m.addInteraction("sp", new SpringDamper3D(40, 100, 10), "mass", "mass2" );
   
   m.addInOut("driver", new Driver3D(), "mass");

  // Add the macro element to the top-level physics scene
  phys.mdl().addPhyModel(mac);
  phys.mdl().addPhyModel(m);
  
  phys.colEngine().addCollision(mac,m,0.1);
  
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
      driver.applyFrc(new Vect3D(0, 0, 35));
  }
  if(key == 'z')
    phys.mdl().removeInteraction("sp2");
}
