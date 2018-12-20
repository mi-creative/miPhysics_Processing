/*
Model: Flying Mesh
Author: James Leonard (james.leonard@gipsa-lab.fr)

A 2D mesh of masses and springs that just sort of floats through the air,
sometimes folding over itself.

It collides with a 2D Plane.

Press and release space bar to invert gravity.
*/

import miPhysics.*;
import peasy.*;

PeasyCam cam;

// SOME GLOBAL DECLARATIONS AND REQUIRED ELEMENTS

int displayRate = 90;

/*  "dimension" of the model - number of MAT modules */
int dimX = 80;
int dimY = 80;

/*  global physical model object : will contain the model and run calculations. */
PhysicalModel mdl;


// SETUP: THIS IS WHERE WE SETUP AND INITIALISE OUR MODEL

void setup() {

  size(1000, 700, P3D);

  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);

  background(0);

  // instantiate our physical model context
  mdl = new PhysicalModel(300, displayRate);
  
  generateVolume(mdl, dimX, dimY, 1, "mass", "spring", 1., 20, 0.2, 0.06);
  
  mdl.setGravity(0.0001);
  mdl.setFriction(0.0001);

  for (int i = 1; i <=mdl.getNumberOfMats(); i++)
    mdl.addPlaneInteraction("plane"+i, 0, 0.01, 0.01, 2, -160, "mass"+i);

  // initialise the model before starting calculations.
  mdl.init();
  
  frameRate(displayRate);
} 

// DRAW: THIS IS WHERE WE RUN THE MODEL SIMULATION AND DISPLAY IT

void draw() {

  mdl.draw_physics();

  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);

  background(0);

  // Drawing style
  drawPlane(2, -160, 800); 

  translate(-700,-700,0);
  renderModelLinks(mdl);
}


void keyPressed() {
  if (key == ' ')
    mdl.setGravity(-0.001);
}

void keyReleased() {
  if (key == ' ')
    mdl.setGravity(0.001);
}