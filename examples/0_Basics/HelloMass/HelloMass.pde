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

PhysicsContext phys;
PhyModel mdl;
ModelRenderer renderer;

boolean showInstructions = true;


void setup() {
  frameRate(displayRate);
  size(1000, 700, P3D);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(100);
  cam.setMaximumDistance(500);
  
  float m = 1.0;
float k = 0.001;
float z = 0.01;
float dist = 70;
  
  // Create a global physics context and get the "top level" physical model from this context.
  phys = new PhysicsContext(300, displayRate);
  mdl = phys.mdl();
  
  /* Create a mass, connected to fixed points via Spring Dampers */
  mdl.addMass("mass", new Mass3D(m, 15, new Vect3D(0., 0., 0.), new Vect3D(0., 0., 0.)));

  //mdl.addMass3D("mass", m, 10, new Vect3D(0., 0., 0.), new Vect3D(0., 0., 1.));
  mdl.addMass("ground1", new Ground3D(1, new Vect3D(dist, 0., 0.)));
  mdl.addMass("ground2", new Ground3D(1, new Vect3D(-dist, 0., 0.)));
  mdl.addMass("ground3", new Ground3D(1, new Vect3D(0., dist, 0.)));
  mdl.addMass("ground4", new Ground3D(1, new Vect3D(0., -dist, 0.)));
  mdl.addMass("ground5", new Ground3D(1, new Vect3D(0., 0., dist)));
  mdl.addMass("ground6", new Ground3D(1, new Vect3D(0., 0., -dist)));

  mdl.addInteraction("spring1", new SpringDamper3D(dist, k, z), "mass", "ground1");
  mdl.addInteraction("spring2", new SpringDamper3D(dist, k*0.9, z), "mass", "ground2");
  mdl.addInteraction("spring3", new SpringDamper3D(dist, k*2, z), "mass", "ground3");
  mdl.addInteraction("spring4", new SpringDamper3D(dist, k*2.1, z), "mass", "ground4");
  mdl.addInteraction("spring5", new SpringDamper3D(dist, k*1.5, z), "mass", "ground5");
  mdl.addInteraction("spring6", new SpringDamper3D(dist, k*1.2, z), "mass", "ground6");
  
  mdl.addInOut("drive",new Driver3D(),"mass");
  
  phys.init(); 
  
  renderer = new ModelRenderer(this);
  renderer.setZoomVector(1,1,1);
  renderer.displayModuleNames(false);
  renderer.setTextSize(6);
  renderer.setForceVectorScale(1000);
}

void draw() {
  directionalLight(251, 102, 126, 0, 1, 0);
  ambientLight(142, 142, 142);
  background(0);
  stroke(255);
  
  if(showInstructions)
    displayModelInstructions();
  
  phys.computeScene();
  renderer.renderScene(phys);

}

/* Trigger random forces on the mass */
void keyPressed() {
  switch(key){
    case ' ':
      for(Driver3D driver : mdl.getDrivers())
        driver.applyFrc(new Vect3D(random(-5,5),random(-5,5),random(-5,5)));
      break;
    case 'i':
      renderer.toggleModuleNameDisplay();
      break;
    case 'f':
      renderer.toggleForceDisplay();
      break;
    case 'h':
      showInstructions = !showInstructions;
      break;    
    default:
      break;
  }
}



void displayModelInstructions(){
  cam.beginHUD();
  textMode(MODEL);
  textSize(16);
  fill(255, 255, 255);
  text("Press the space bar to trigger random forces on the mass", 10, 30);
  text("Press 'i' to toggle module name display", 10, 55);
  text("Press 'f' to toggle force display", 10, 80);
  text("Press 'h' to hide instructions", 10, 110);

  cam.endHUD();
}
