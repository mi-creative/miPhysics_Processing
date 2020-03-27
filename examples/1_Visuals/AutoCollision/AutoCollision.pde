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

int displayRate = 60;

PhysicsContext phys;
PhyModel mdl;
ModelRenderer renderer;

boolean showInstructions = true;

boolean AUTOCOLLIDER = true;


void setup() {
  frameRate(displayRate);
  //size(1000, 700, P3D);
  fullScreen(P3D);
  cam = new PeasyCam(this, 250);
  cam.setMinimumDistance(100);
  cam.setMaximumDistance(500);
  
  // Create a global physics context and get the "top level" physical model from this context.
  phys = new PhysicsContext(300, displayRate);
  mdl = phys.mdl();
  
  phys.setGlobalFriction(0.005);
  phys.setGlobalGravity(0, -0.01, 0.);
  
  double bubbleRadius = 100;
  int nbMass = 500;
  
  /* Create a mass, connected to fixed points via Spring Dampers */
  mdl.addMass("ground", new Ground3D(1, new Vect3D(0., 0., 0.)));
  
  // Create a bunch of masses with randomised spherical coordinates
  for(int i = 0; i < nbMass; i++){
    float rR = random(100.);
    float rThe = random(2.*PI);
    float rPhi = random(2.*PI);
    
    mdl.addMass("mass"+i, new Mass3D(1, 6, 
    new Vect3D(rR * sin(rThe)*cos(rPhi), rR * sin(rThe)*sin(rPhi), rR * cos(rThe)), 
    new Vect3D(0., 0., 0.)));
    
    // Add enclosing "Bubble" interaction to keep masses inside a sphere
    mdl.addInteraction("bub"+i, new Bubble3D(bubbleRadius, 0.1, 0.01), "ground", "mass"+i);
    
    // set a driver for each mass in the system
    mdl.addInOut("drive"+i,new Driver3D(),"mass"+i);

  }
  
  if(AUTOCOLLIDER)
    phys.colEngine().addAutoCollision(phys.mdl(),30,20,0.01,0.01);
  else{
  for(int i = 0; i < nbMass; i++)
    for(int j = i; j < nbMass; j++)
      mdl.addInteraction("cnt"+i+"_"+j, new Contact3D(0.01, 0.01), "mass"+i, "mass"+j);
  }  
  
  phys.init(); 
  
  renderer = new ModelRenderer(this);
  renderer.setZoomVector(1,1,1);
  renderer.displayModuleNames(false);
  renderer.setTextSize(6);
  renderer.setForceVectorScale(500);
  renderer.displayAutoCollisionVolumes(false);
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
        driver.applyFrc(new Vect3D(random(-2,2),random(-2,2),random(-2,2)));
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
    case 'a':
      renderer.toggleAutoCollisonVolumesDisplay();
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
  text("Press the space bar to trigger random forces on the masses", 10, 30);
  text("Press 'i' to toggle module name display", 10, 55);
  text("Press 'f' to toggle Force display", 10, 80);
  text("Press 'a' to toggle Auto-Collision boxes display", 10, 105);
  text("FrameRate : " + frameRate, 10, 130);
  text("Press 'h' to hide instructions", 10, 155);

  cam.endHUD();
}
