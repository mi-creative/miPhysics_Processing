/*
Model: Flying Mesh
Author: James Leonard (james.leonard@gipsa-lab.fr)

A 2D mesh of masses and springs that just sort of floats through the air,
sometimes folding over itself.

It collides with a 2D Plane.

Press and release space bar to invert gravity.
*/

import miPhysics.Engine.*;
import miPhysics.Renderer.*;

import peasy.*;

PeasyCam cam;

// SOME GLOBAL DECLARATIONS AND REQUIRED ELEMENTS

int displayRate = 90;
boolean BASIC_VISU = false;

/*  "dimension" of the model - number of MAT modules */
int dimX = 80;
int dimY = 80;

/*  global physical model object : will contain the model and run calculations. */
PhysicsContext phys;
ModelRenderer renderer;


// SETUP: THIS IS WHERE WE SETUP AND INITIALISE OUR MODEL

void setup() {

  size(1000, 700, P3D);

  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);
  
  cam.setDistance(1000);

  background(0);

  // instantiate our physical model context
  phys = new PhysicsContext(300, displayRate);
  
  generateVolume(phys.mdl(), dimX, dimY, 1, "mass", "spring", 1., 20, 0.2, 0.06);
    
  phys.setGlobalGravity(0,0, 0.001);
  phys.setGlobalFriction(0.0001);

  for (int i = 0; i <phys.mdl().getNumberOfMasses(); i++)
    phys.mdl().addInteraction("plane"+i, new PlaneContact3D(0.01, 0.01, 2, 0), "mass"+(i+1));

  // initialise the model before starting calculations.
  phys.init();
  
  renderer = new ModelRenderer(this);
  
  
  
  if (BASIC_VISU){
    renderer.displayMasses(false);
    renderer.setColor(interType.SPRINGDAMPER3D, 155, 200, 200, 255);
    renderer.setSize(interType.SPRINGDAMPER3D, 1);
  }
  else{
    renderer.displayMasses(false);
    renderer.setColor(interType.SPRINGDAMPER3D, 100, 20, 10, 255);
    renderer.setSize(interType.SPRINGDAMPER3D, 1);
    renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 0.1);
    renderer.setStrainColor(interType.SPRINGDAMPER3D, 255, 250, 155, 255);
  }
  
  frameRate(displayRate);
} 

// DRAW: THIS IS WHERE WE RUN THE MODEL SIMULATION AND DISPLAY IT

void draw() {

  phys.computeScene();

  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(0);
  drawPlane(2, 0, 800); 

  displayModelInstructions();

  translate(-700,-700,0);
  renderer.renderScene(phys);
}


void keyPressed() {
  if (key == ' ')
    phys.setGlobalGravity(0,0,-0.001);
}

void keyReleased() {
  if (key == ' ')
    phys.setGlobalGravity(0,0,0.001);
}


void drawPlane(int orientation, float position, float size){
  stroke(250);
  fill(0, 0, 110);
  
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
  text("Not much to say about this model...", 10, 30);
  text("The mesh has no auto-collision, so it folds 'into' itself", 10, 55);
  cam.endHUD();

}
