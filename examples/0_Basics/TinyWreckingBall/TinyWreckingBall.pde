/*
Model: Tiny Wrecking Ball
Author: James Leonard (james.leonard@gipsa-lab.fr)

A chain of 3 masses attached to a fixed point.
The last mass is heavy and collides with a 2D Plane.
*/

import miPhysics.Engine.*;
import miPhysics.ModelRenderer.*;

import peasy.*;

PeasyCam cam;
PhysicalModel mdl;
ModelRenderer renderer;

Driver3D d;

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

  mdl.setGlobalGravity(0, 0, 0.005);
  mdl.setGlobalFriction(0.005);
  
  mdl.addMass("mass1", new Mass3D(20, 50, initPos, initV));
  mdl.addMass("mass2", new Mass3D(1, 15, initPos2, initV));
  mdl.addMass("mass3", new Mass3D(1, 10, initPos3, initV));
  mdl.addMass("ground1", new Ground3D(5, initPos4));

  mdl.addInteraction("rope1", new Rope3D(90, 0.02, 0.08), "mass1", "mass2");
  mdl.addInteraction("rope2", new Rope3D(90, 0.02, 0.08), "mass2", "mass3");
  mdl.addInteraction("rope3", new Rope3D(90, 0.02, 0.08), "mass3", "ground1");
  
  for(int i = 1; i <=3; i++)
    mdl.addInteraction("plane"+i, new PlaneContact3D(0.1, 0.1, 0, -160),"mass"+i);
    
  d = mdl.addInOut("driver", new Driver3D(), "mass1");

    
  renderer.displayMasses(true);
  renderer.setColor(interType.ROPE3D, 155, 200, 200, 255);
  renderer.setSize(interType.ROPE3D, 3);

  // initialise the model before starting calculations.
  mdl.init();
  
  cam.setDistance(500);  // distance from looked-at point
} 

void draw() {

  mdl.compute();

  if(applyFrc == true)
    d.applyFrc(new Vect3D(1, 0.1, 0));

  Vect3D pos1 = mdl.getMass("mass1").getPos();
  Vect3D pos2 = mdl.getMass("mass2").getPos();
  Vect3D pos3 = mdl.getMass("mass3").getPos();
  Vect3D pos4 = mdl.getMass("ground1").getPos();

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
