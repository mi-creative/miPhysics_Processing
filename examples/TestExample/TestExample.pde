/*
Model: Hello Mass
Author: James Leonard (james.leonard@gipsa-lab.fr)

A physical equivalent to a Hello World program!

We create a mass, and attach it to six fixed points with spring-dampers.
We then simulate the model, and can trigger forces on the mass by 
hitting the space bar.
*/

import miPhysics.Engine.*;
import miPhysics.Renderer.*;

import peasy.*;
PeasyCam cam;

int displayRate = 90;

float m = 1.0;
float k = 0.001;
float z = 0.01;
float dist = 70;

/*  global physical model object : will contain the model and run calculations. */
PhysicsContext phys;

ModelRenderer renderer;


void setup() {
  frameRate(displayRate);
  size(1000, 700, P3D);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(100);
  cam.setMaximumDistance(500);
  
  phys = new PhysicsContext(300, displayRate);
  
  // Build some top level elements...
  phys.model().addMass("mass", new Mass3D(m, 15, new Vect3D(0., 0., 0.), new Vect3D(0., 0., 0.)));
  phys.model().addMass("ground1", new Ground3D(1, new Vect3D(dist, 0., 0.)));
  phys.model().addMass("ground2", new Ground3D(1, new Vect3D(-dist, 0., 0.)));
  phys.model().addMass("ground3", new Ground3D(1, new Vect3D(0., dist, 0.)));
  phys.model().addMass("ground4", new Ground3D(1, new Vect3D(0., -dist, 0.)));
  phys.model().addMass("ground5", new Ground3D(1, new Vect3D(0., 0., dist)));
  phys.model().addMass("ground6", new Ground3D(1, new Vect3D(0., 0., -dist)));
  phys.model().addInteraction("spring1", new SpringDamper3D(dist, k, z), "mass", "ground1");
  phys.model().addInteraction("spring2", new SpringDamper3D(dist, k*0.9, z), "mass", "ground2");
  phys.model().addInteraction("spring3", new SpringDamper3D(dist, k*2, z), "mass", "ground3");
  phys.model().addInteraction("spring4", new SpringDamper3D(dist, k*2.1, z), "mass", "ground4");
  phys.model().addInteraction("spring5", new SpringDamper3D(dist, k*1.5, z), "mass", "ground5");
  phys.model().addInteraction("spring6", new SpringDamper3D(dist, k*1.2, z), "mass", "ground6");
  phys.model().addInOut("drive",new Driver3D(),"mass");
  
  // Build an encapsulated macro element.
  PhyModel mac = new PhyModel("mac");
  mac.addMass("mass", new Mass3D(m, 15, new Vect3D(50., 50., 0.)));
  mac.addMass("ground", new Ground3D(10, new Vect3D(100., 100., 0.)));
  mac.addInteraction("spring", new SpringDamper3D(50, 0.01, 0.001), "mass", "ground");
  
  // Add the macro element to the top-level physics scene
  phys.model().addPhyModel(mac);
  
  // Now add a connection between the top level model and the encapsulated macro model !
  phys.model().addInteraction("sp", new SpringDamper3D(0,0.001, 0.1), phys.model().getMass("mass"), mac.getMass("mass"));

  
  phys.model().init(); 
  
  renderer = new ModelRenderer(this);
  renderer.setZoomVector(1,1,1);
}

void draw() {
  directionalLight(251, 102, 126, 0, -1, 0);
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
    for(Driver3D driver : phys.model().getDrivers())
      driver.applyFrc(new Vect3D(random(-5,5),random(-5,5),random(-5,5)));
  }
}
