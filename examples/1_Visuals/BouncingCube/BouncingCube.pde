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

import miPhysics.Engine.*;
import miPhysics.ModelRenderer.*;

int displayRate = 50;
boolean BASIC_VISU = false;

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
Driver3D drive;

ModelRenderer renderer;


double grav = 0.001;

void setup() {

  size(1000, 700, P3D);

  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);
  cam.rotateX(radians(-80));
  
  cam.setDistance(750);

  background(0);

  mdl = new PhysicalModel(1050, displayRate);
  renderer = new ModelRenderer(this);

  mdl.setGlobalGravity(0, 0, 0.001);
  mdl.setGlobalFriction(0.000);
  
  generateVolume(mdl, dimX, dimY, dimZ, "mass", "spring", 1., 25, 0.03, 0.03);
  
  for(int i = 0; i < mdl.getNumberOfMasses(); i++)
    mdl.addInteraction("plane"+i, new PlaneContact3D(0.1, 0.005, 2, -40), "mass"+(i+1));

  drive = mdl.addInOut("drive", new Driver3D(),"mass"+(dimY*dimZ));


  mdl.init();
  
  if (BASIC_VISU){
    renderer.displayMasses(false);
    renderer.setColor(interType.SPRINGDAMPER3D, 155, 200, 200, 255);
    renderer.setSize(interType.SPRINGDAMPER3D, 1);
  }
  else{
    renderer.displayMasses(true);
    renderer.setColor(interType.SPRINGDAMPER3D, 0, 50, 255, 255);
    renderer.setSize(interType.SPRINGDAMPER3D, 1);
    renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 0.02);
    renderer.setStrainColor(interType.SPRINGDAMPER3D, 150, 150, 255, 255);
  }
  
  frameRate(displayRate);

} 

// DRAW: THIS IS WHERE WE RUN THE MODEL SIMULATION AND DISPLAY IT

void draw() {

  mdl.compute();

  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);

  background(0);
  drawPlane(2, -40, 800); 

  renderer.renderModel(mdl);
}




void keyPressed() {
  if (key == ' ')
    mdl.setGlobalGravity(0, 0, -grav);
    
  
  if (key == 'a')
      drive.applyFrc(new Vect3D(0,1, 0));
  else if (key == 'z')
        drive.applyFrc(new Vect3D(0,-1, 0));
  else if (key =='e')
        drive.applyFrc(new Vect3D(1,0, 0));
  else if (key =='r')
        drive.applyFrc(new Vect3D(-1,0, 0));
  else if (key == 'q'){
    grav = 0.001;
    mdl.setGlobalGravity(0,0,grav);
  }
  else if (key=='s'){
    grav = 0.003;
    mdl.setGlobalGravity(0,0,grav);
  }
}

void keyReleased() {
  if (key == ' ')
  mdl.setGlobalGravity(0,0,grav);
}


void drawPlane(int orientation, float position, float size){
  stroke(255);
  fill(50);
  
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
