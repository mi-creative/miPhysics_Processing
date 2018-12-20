/*
Model: Sphere Coil Rope
Author: Jérôme Villeneuve

An extremely long rope, initially coiled up as a sphere.

Hit the space bar to pull at random masses and undo the coils!
*/

import miPhysics.*;
import peasy.*;

PeasyCam cam;

// SOME GLOBAL DECLARATIONS AND REQUIRED ELEMENTS

int displayRate = 50;

/*  "dimension" of the model - number of MAT modules */
int dimX = 20;
int dimY = 20;
int dimZ = 20;

/*  global physical model object : will contain the model and run calculations. */
PhysicalModel mdl;

/* control dessin */
int mouseDragged = 0;


// SETUP: THIS IS WHERE WE SETUP AND INITIALISE OUR MODEL

void setup() {

  fullScreen(P3D);
  //size(1000, 700, P3D);

  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);
  cam.rotateY(180);
  cam.rotateX(120);
  cam.setDistance(400);

  background(0);

  // instantiate our physical model context
  mdl = new PhysicalModel(250, displayRate);

  mdl.setGravity(0.000);
  mdl.setFriction(0.000);
 
  generatePinSphere(mdl, dimX, dimY, dimZ, "osc", "spring", 1., 5, 0., 0.0, 0.1, 0.1);

  // initialise the model before starting calculations.
  mdl.init();
  frameRate(displayRate);
} 

// DRAW: THIS IS WHERE WE RUN THE MODEL SIMULATION AND DISPLAY IT

void draw() {
  mdl.draw_physics();

  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);
  cam.rotateY(0.01);

  background(0);

  // Drawing style
  pushMatrix();  
  renderModelPnScrn3D(mdl, 1);
  popMatrix();
  
  if (mousePressed == true){
    //fExt();
  }
}


void fExt(){
  String matName = "osc" + floor(random(19000));
  mdl.triggerForceImpulse(matName, random(100) , random(100), random(500));
}


void keyPressed() {
  if (key == ' ')
      fExt();

}

void keyReleased() {
  if (key == ' ');
}