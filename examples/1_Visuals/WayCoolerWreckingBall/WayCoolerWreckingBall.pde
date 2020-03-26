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
PhyModel mdl;
ModelRenderer renderer;

Driver3D d;

boolean applyFrc = true;

int displayRate = 60;

void setup() {
  frameRate(displayRate);
  
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(3500);
  cam.rotateX(radians(-90));
  cam.setDistance(500);  // distance from looked-at point

  //size(900, 850, P3D);
  fullScreen(P3D);
  background(0);

  // instantiate our physical model context
  phys = new PhysicsContext(550, displayRate);
  mdl = phys.mdl();
  renderer = new ModelRenderer(this);

  phys.setGlobalGravity(0, 0, 0.00);
  phys.setGlobalFriction(0.0001);
  
  phys.mdl().addPhyModel(buildWreckingBall("ball", phys.getGlobalMedium()));
  phys.mdl().addPhyModel(buildPyramid("pyramid", phys.getGlobalMedium(),10, 30, 10));
  
  phys.colEngine().addCollision(phys.mdl().getPhyModel("pyramid"), phys.mdl().getPhyModel("ball"), 0.1, 0.01);
  phys.colEngine().addAutoCollision(phys.mdl().getPhyModel("pyramid"),100,30,0.1,0.1);
    
  renderer.displayMasses(true);
  renderer.setColor(interType.ROPE3D, 155, 200, 200, 255);
  renderer.setSize(interType.ROPE3D, 3);
  renderer.displayModuleNames(false);
  renderer.setTextSize(30);
  renderer.setTextRotation(-PI/2,0,0);
  renderer.setForceVectorScale(500);
  
  renderer.displayObjectVolumes(true);
  renderer.displayIntersectionVolumes(true);
  renderer.displayAutoCollisionVolumes(true);

  // initialise the model before starting calculations.
  phys.init();
  
} 

void draw() {
  
  directionalLight(251, 182, 126, 0, -1, 0);
  ambientLight(152, 152, 152);
  background(0);
  strokeWeight(1);
  drawPlane(2, 0, 1600); 
  
  displayModelInstructions();

  phys.computeScene();
  renderer.renderScene(phys);

  println(frameRate);
}



/* Trigger random forces on the mass */
void keyPressed() {
  switch(key){
    case ' ':
      phys.setGlobalGravity(0, 0, 0.005);
      break;
    case 'i':
      renderer.toggleModuleNameDisplay();
      break;
    case 'f':
      renderer.toggleForceDisplay();
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
  fill(170, 255, 200, 100);
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
  text("Press the space bar to enable gravity and wreck the pyramid !", 10, 30);
  cam.endHUD();
}
