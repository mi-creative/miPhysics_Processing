/*
Model: Bouncing Cube
Author: James Leonard (james.leonard@gipsa-lab.fr)

A cube of masses and springs, bouncing against a 2D Plane.

Beware, sometimes the cube "folds in" on itself!

Press and release space bar to invert gravity.
Press 'a', 'z', 'e' or 'r' to apply forces to the cube and set it off-axis.
Press 'q' or 's' to toggle between low and high gravity values.
*/

import peasy.*;
import miPhysics.*;

int displayRate = 50;

// TRY THESE DIFFERENT CONFIGURATIONS !

// Regular Cube:
int dimX = 10;
int dimY = 10;
int dimZ = 10;

// Bouncy Plank:
//int dimX = 2;
//int dimY = 7;
//int dimZ = 30;

// Snake Like Bar/String:
//int dimX = 2;
//int dimY = 2;
//int dimZ = 50;

PeasyCam cam;
PhysicalModel mdl;

double grav = 0.001;

void setup() {

  size(1000, 700, P3D);

  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);

  background(0);

  mdl = new PhysicalModel(1050, displayRate);

  mdl.setGravity(0.001);
  mdl.setFriction(0.000);
  
  generateVolume(mdl, dimX, dimY, dimZ, "mass", "spring", 1., 25, 0.03, 0.03);

  for (int i = 1; i <=mdl.getNumberOfMats(); i++)
    mdl.addPlaneInteraction("plane"+i, 0, 0.1, 0.005, 2, -40, "mass"+i);

  mdl.init();
  
  frameRate(displayRate);

} 

// DRAW: THIS IS WHERE WE RUN THE MODEL SIMULATION AND DISPLAY IT

void draw() {

  mdl.draw_physics();

  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);

  background(0);
  drawPlane(2, -40, 800); 

  renderModelEllipse(mdl, 1);
}




void keyPressed() {
  if (key == ' ')
  mdl.setGravity(-grav);
  
  if (key == 'a')
      mdl.triggerForceImpulse("mass"+(dimY*dimZ), 0,1, 0);
  else if (key == 'z')
      mdl.triggerForceImpulse("mass"+(dimY*dimZ), 0,-1, 0);
  else if (key =='e')
    mdl.triggerForceImpulse("mass"+(dimZ), 1,0, 0);
  else if (key =='r')
    mdl.triggerForceImpulse("mass"+(dimZ), -1,0, 0);
  else if (key == 'q'){
    grav = 0.001;
    mdl.setGravity(grav);
  }
  else if (key=='s'){
    grav = 0.003;
    mdl.setGravity(grav);
  }
}

void keyReleased() {
  if (key == ' ')
  mdl.setGravity(grav);
}