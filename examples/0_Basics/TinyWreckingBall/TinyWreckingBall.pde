/*
Model: Tiny Wrecking Ball
Author: James Leonard (james.leonard@gipsa-lab.fr)

A chain of 3 masses attached to a fixed point.
The last mass is heavy and collides with a 2D Plane.
*/

import miPhysics.*;
import peasy.*;

PeasyCam cam;
PhysicalModel mdl;
ModelRenderer renderer;

boolean applyFrc = false;

int displayRate = 60;

void setup() {
  frameRate(displayRate);
  
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(500);
  cam.rotateX(radians(-90));

  size(900, 850, P3D);
  background(0);

  // instantiate our physical model context
  mdl = new PhysicalModel(1050, displayRate);
  renderer = new ModelRenderer(this);


  // some initial coordinates for the modules.
  Vect3D initPos = new Vect3D(270., 0., 200.);
  Vect3D initPos2 = new Vect3D(180., 0., 200.);
  Vect3D initPos3 = new Vect3D(90., 0., 200.);
  Vect3D initPos4 = new Vect3D(0., 0., 200.);
  Vect3D initV = new Vect3D(0., 0., 0.);

  mdl.setGravity(0.005);
  mdl.setFriction(0.005);

  mdl.addMass3D("mass1", 20.0, initPos, initV);
  mdl.addMass3D("mass2", 1.0, initPos2, initV);
  mdl.addMass3D("mass3", 1.0, initPos3, initV);
  mdl.addGround3D("ground1", initPos4);

  mdl.addRope3D("rope1", 90.0, 0.02,0.08, "mass1", "mass2");
  mdl.addRope3D("rope2", 90.0, 0.02,0.08, "mass2", "mass3");
  mdl.addRope3D("rope3", 90.0, 0.02,0.08, "mass3", "ground1");

  for(int i = 1; i <=3; i++)
    mdl.addPlaneContact("plane"+i, 50, 0.01, 0.1, 0, -160, "mass"+i);
    
  renderer.displayMats(true);
  renderer.setScaling(matModuleType.Mass3D, 1);
  renderer.setColor(linkModuleType.Rope3D, 155, 200, 200, 255);
  renderer.setSize(linkModuleType.Rope3D, 3);

  // initialise the model before starting calculations.
  mdl.init();
  
  cam.setDistance(500);  // distance from looked-at point
} 

void draw() {

  mdl.draw_physics();

  if(applyFrc == true){
    mdl.triggerForceImpulse("mass1", 1, 0.1, 0);
  }

  Vect3D pos1 = mdl.getMatPosition("mass1");
  Vect3D pos2 = mdl.getMatPosition("mass2");
  Vect3D pos3 = mdl.getMatPosition("mass3");
  Vect3D pos4 = mdl.getMatPosition("ground1");

  println("Mass 1 position: " + pos1);
  println("Mass 2 position: " + pos2);
  println("Mass 3 position: " + pos3);

  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);

  background(0);

  strokeWeight(1);
  drawGrid(40, 4);
  drawPlane(0, -160, 160); 
  
  renderer.renderModel(mdl);
}

void keyPressed(){
  if(keyCode == ' ')
    applyFrc = true;
}

void keyReleased(){
  if(keyCode == ' ')
    applyFrc = false;
}

//****************************************************************************//

void drawPlane(int orientation, float position, float size){
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


void drawGrid(int gridSize, int nbBlocks) {
  strokeWeight(1);
  stroke(100, 100, 100, 100); 
  int range = gridSize * nbBlocks;

  for (int j = -range; j <= range; j+=gridSize) {
    for (int k = -range; k <= range; k += gridSize) {
      line(-range, j, k, range, j, k);
      line(j, -range, k, j, range, k);
      line(j, k, -range, j, k, range);
    }
  }
}
