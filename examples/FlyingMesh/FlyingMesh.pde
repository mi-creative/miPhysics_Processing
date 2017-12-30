import physicalModelling.*;
import peasy.*;

PeasyCam cam;


// SOME GLOBAL DECLARATIONS AND REQUIRED ELEMENTS

int displayRate = 60;

/*  "dimension" of the model - number of MAT modules */

int dimX = 80;
int dimY = 80;

/*  global physical model object : will contain the model and run calculations. */
PhysicalModel mdl;

/* elements to calculate the number of steps to simulate in each draw() method */
float simDisplay_factor;
int nbSteps;
float residue = 0;


// SETUP: THIS IS WHERE WE SETUP AND INITIALISE OUR MODEL

void setup() {
  frameRate(displayRate);

  size(1000, 700, P3D);

  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);

  background(0);

  // instantiate our physical model context
  mdl = new PhysicalModel(300);
  
  generateVolume(mdl, dimX, dimY, 1, "mass", "spring", 1., 20, 0.2, 0.06);
  
  mdl.setGravity(0.0001);
  mdl.setFriction(0.0000);


  for (int i = 1; i <=mdl.getNumberOfMats(); i++)
    mdl.addPlaneInteraction("plane"+i, 50, 0.01, 0.01, 2, -160, "mass"+i);

  // initialise the model before starting calculations.
  mdl.init();

  simDisplay_factor = (float) mdl.getSimRate() / (float) displayRate;
  println("The simulation/display factor is :" + simDisplay_factor);
} 

// DRAW: THIS IS WHERE WE RUN THE MODEL SIMULATION AND DISPLAY IT

void draw() {

  float  floatingFramestoSim = simDisplay_factor + residue;
  nbSteps = floor(floatingFramestoSim);
  residue = floatingFramestoSim - nbSteps;

  //println(" NbSteps: "+ nbSteps + ", residue: " + residue);

  mdl.computeNSteps(nbSteps);

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