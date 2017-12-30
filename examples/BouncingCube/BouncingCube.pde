import peasy.*;
import physicalModelling.*;


int displayRate = 25;

/*  "dimension" of the model - number of MAT modules */

int dimX = 15;
int dimY = 15;
int dimZ = 15;

PeasyCam cam;

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
  mdl = new PhysicalModel(1050);

  mdl.setGravity(0.001);
  mdl.setFriction(0.000);
  
  generateVolume(mdl, dimX, dimY, dimZ, "mass", "spring", 1., 20, 0.005, 0.003);

  for (int i = 1; i <=mdl.getNumberOfMats(); i++)
    mdl.addPlaneInteraction("plane"+i, 0, 0.1, 0.005, 2, -40, "mass"+i);

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
  drawPlane(2, -40, 800); 

  renderModelEllipse(mdl, 1);
}




void keyPressed() {
  if (key == ' ')
  mdl.setGravity(-0.001);
}

void keyReleased() {
  if (key == ' ')
  mdl.setGravity(0.001);
}