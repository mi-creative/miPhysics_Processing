/*
Model: Tiny Wrecking Ball
Author: James Leonard (james.leonard@gipsa-lab.fr)

A chain of 3 masses attached to a fixed point.
The last mass is heavy and collides with a 2D Plane.
*/

import miPhysics.Engine.*;
import miPhysics.Renderer.*;

import peasy.*;

PeasyCam cam;
PhysicsContext phys;
ModelRenderer renderer;

Driver3D d;

boolean applyFrc = false;
boolean showInstructions = true;

int displayRate = 60;

void setup() {
  frameRate(displayRate);
  
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(1500);
  cam.rotateX(radians(-90));
  cam.setDistance(500);  // distance from looked-at point

  size(900, 850, P3D);
  background(0);

  // instantiate our physical model context
  phys = new PhysicsContext(1050, displayRate);
  renderer = new ModelRenderer(this);


  // some initial coordinates for the modules.
  Vect3D initPos = new Vect3D(270., 0., 200.);
  Vect3D initPos2 = new Vect3D(180., 0., 200.);
  Vect3D initPos3 = new Vect3D(90., 0., 200.);
  Vect3D initPos4 = new Vect3D(0., 0., 200.);
  Vect3D initV = new Vect3D(0., 0., 0.);

  phys.setGlobalGravity(0, 0, 0.005);
  phys.setGlobalFriction(0.005);
  
  phys.mdl().addMass("mass1", new Mass3D(20, 50, initPos, initV));
  phys.mdl().addMass("mass2", new Mass3D(1, 15, initPos2, initV));
  phys.mdl().addMass("mass3", new Mass3D(1, 10, initPos3, initV));
  phys.mdl().addMass("ground1", new Ground3D(5, initPos4));

  phys.mdl().addInteraction("rope1", new Rope3D(90, 0.02, 0.08), "mass1", "mass2");
  phys.mdl().addInteraction("rope2", new Rope3D(90, 0.02, 0.08), "mass2", "mass3");
  phys.mdl().addInteraction("rope3", new Rope3D(90, 0.02, 0.08), "mass3", "ground1");
  
  for(int i = 1; i <=3; i++)
    phys.mdl().addInteraction("plane"+i, new PlaneContact3D(0.1, 0.1, 0, -160),"mass"+i);
    
  d = phys.mdl().addInOut("driver", new Driver3D(), "mass1");

    
  renderer.displayMasses(true);
  renderer.setColor(interType.ROPE3D, 155, 200, 200, 255);
  renderer.setSize(interType.ROPE3D, 3);
  renderer.displayModuleNames(false);
  renderer.setTextSize(30);
  renderer.setTextRotation(-PI/2,0,0);
  renderer.setForceVectorScale(500);

  // initialise the model before starting calculations.
  phys.init();
  
} 

void draw() {
  
  directionalLight(251, 182, 126, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(0);
  strokeWeight(1);
  drawPlane(0, -160, 160); 
  
  if(showInstructions)
    displayModelInstructions();

  phys.computeScene();
  renderer.renderScene(phys);

  if(applyFrc == true)
    d.applyFrc(new Vect3D(1, 0.1, 0));

  Vect3D pos1 = phys.mdl().getMass("mass1").getPos();
  Vect3D pos2 = phys.mdl().getMass("mass2").getPos();
  Vect3D pos3 = phys.mdl().getMass("mass3").getPos();

  println("Mass 1 position: " + pos1);
  println("Mass 2 position: " + pos2);
  println("Mass 3 position: " + pos3);
  
}



/* Trigger random forces on the mass */
void keyPressed() {
  switch(key){
    case ' ':
      applyFrc = true;
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



void keyReleased(){
  switch(key){
    case ' ':
      applyFrc = false;
      break;
    default:
      break;
  }
}



void drawPlane(int orientation, float position, float size){
  fill(0, 255, 100, 100);
  stroke(255);
  
  beginShape();
  if(orientation ==2){
    vertex(-size, -size, position);
    vertex( size, -size, position);
    vertex( size, size, position);
    vertex(-size, size, position);
  } else if (orientation == 1) {
    vertex(-size,position, -size);
    vertex( size,position, -size);
    vertex( size,position, size);
    vertex(-size,position, size);  
  } else if (orientation ==0) {
    vertex(position, -size, -size);
    vertex(position, size, -size);
    vertex(position, size, size);
    vertex(position,-size, size);
  }
  endShape(CLOSE);
}


void displayModelInstructions(){
  cam.beginHUD();
  textMode(MODEL);
  textSize(16);
  fill(255, 255, 255);
  text("Maintain the space bar to pull mass back, release to unleash it", 10, 30);
  text("Press 'i' to toggle module name display", 10, 55);
  text("Press 'f' to toggle force display", 10, 80);
  text("Press 'h' to hide instructions", 10, 110);

  cam.endHUD();
}
