/*
Model: Sphere Coil Rope
Author: Jérôme Villeneuve

An extremely long rope, initially coiled up as a sphere.

Hit the space bar to pull at random masses and undo the coils!
*/

import miPhysics.Engine.*;
import miPhysics.ModelRenderer.*;

import peasy.*;

PeasyCam cam;

// SOME GLOBAL DECLARATIONS AND REQUIRED ELEMENTS

int displayRate = 60;
boolean BASIC_VISU = false;


float rot = 0.01;

/*  global physical model object : will contain the model and run calculations. */
PhysicalModel mdl;
ModelRenderer renderer;

Driver3D d;


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

  mdl.setGlobalGravity(0,0,0);
  mdl.setGlobalFriction(0.000);
 
  generatePinSphere(mdl, "osc", "spring", 1., 5, 0., 0.0, 0.1, 0.1);
  
  d = mdl.addInOut("driver", new Driver3D(), "osc0");


  // initialise the model before starting calculations.
  mdl.init();
  
  renderer = new ModelRenderer(this);
  
  if (BASIC_VISU){
    renderer.displayMasses(false);
    renderer.setColor(interType.SPRINGDAMPER3D, 155, 200, 200, 255);
    renderer.setSize(interType.SPRINGDAMPER3D, 1);
  }
  else{
    renderer.displayMasses(false);
    renderer.setColor(interType.SPRINGDAMPER3D, 180, 10, 10, 100);
    renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 0.1);
    renderer.setStrainColor(interType.SPRINGDAMPER3D, 255, 250, 255, 255);
  }  
  
  
  frameRate(displayRate);
} 

// DRAW: THIS IS WHERE WE RUN THE MODEL SIMULATION AND DISPLAY IT

void draw() {
  mdl.compute();

  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);
  cam.rotateY(rot);

  background(0);

  // Drawing style
  pushMatrix();  
  renderer.renderModel(mdl);
  popMatrix();
}


void fExt(){
  String matName = "osc" + floor(random(19000));
  d.moveDriver(mdl.getMass(matName));
  d.applyFrc(new Vect3D(random(100) , random(100), random(500)));
}


void keyPressed() {
  if(key == 'a')
    rot = 0;
  if (key == ' ')
      fExt();

}

void keyReleased() {
    if(key == 'a')
    rot = 0.01;
  if (key == ' ');
}
