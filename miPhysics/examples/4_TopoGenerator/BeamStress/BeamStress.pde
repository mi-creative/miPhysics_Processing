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

int displayRate = 90;


int dimX = 2;
int dimY = 2;
int dimZ = 12;
int overlap = 3;



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

  mdl.setGravity(grav);
  mdl.setFriction(0.0001);
  
  TopoGenerator q = new TopoGenerator(mdl, "mass", "spring");
  q.setDim(dimX, dimY, dimZ, overlap);
  q.setParams(1, 0.003, 0.003);
  q.setGeometry(25, 25);
  
  //q.setRotation(0, 2, 0);
  //q.setTranslation(00, 00, 213);
    
  //q.addBoundaryCondition(Bound.X_LEFT);
  //q.addBoundaryCondition(Bound.X_RIGHT);
  //q.addBoundaryCondition(Bound.Y_LEFT);
  //q.addBoundaryCondition(Bound.Y_RIGHT);
  q.addBoundaryCondition(Bound.Z_LEFT);
  //q.addBoundaryCondition(Bound.Z_RIGHT);
  //q.addBoundaryCondition(Bound.FIXED_CORNERS);
  //q.addBoundaryCondition(Bound.FIXED_CENTRE);

  q.generate();
  
  
  for (int i = 0; i < mdl.getNumberOfMats(); i++){
    println(mdl.getMatNameAt(i));
    mdl.addPlaneContact("plane"+i, 0, 0.1, 0.005, 2, 0, mdl.getMatNameAt(i));
  }

  mdl.init();
  
  frameRate(displayRate);

} 

// DRAW: THIS IS WHERE WE RUN THE MODEL SIMULATION AND DISPLAY IT

void draw() {

  mdl.draw_physics();

  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);

  background(255);
  fill(255);
  drawPlane(2, 0, 200); 

  renderModel(mdl, 1);
}




void keyPressed() {
  
  String mass = "mass_" + (dimX/2)+ "_" + (dimY/2) + "_" + (dimZ/2); 
  
  if (key == ' ')
  mdl.setGravity(-grav);
  
  if (key == 'a'){
      mdl.triggerForceImpulse(mass, 0,10, 0);
  }
  else if (key == 'z'){
      mdl.triggerForceImpulse(mass, 0,-10, 0);
      }
  else if (key =='e'){
      mdl.triggerForceImpulse(mass, 10,0, 0);

  }
  else if (key =='r'){
      mdl.triggerForceImpulse(mass, -10,0, 0);
  }
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
