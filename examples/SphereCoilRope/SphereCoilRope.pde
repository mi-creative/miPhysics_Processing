import physicalModelling.*;
import peasy.*;

PeasyCam cam;


// SOME GLOBAL DECLARATIONS AND REQUIRED ELEMENTS

int displayRate = 25;

/*  "dimension" of the model - number of MAT modules */

int dimX = 20;
int dimY = 20;
int dimZ = 20;


/*  global physical model object : will contain the model and run calculations. */
PhysicalModel mdl;

/* elements to calculate the number of steps to simulate in each draw() method */
float simDisplay_factor;
int nbSteps;
float residue = 0;

/* control dessin */
int mouseDragged = 0;


// SETUP: THIS IS WHERE WE SETUP AND INITIALISE OUR MODEL

void setup() {
  frameRate(displayRate);
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
  mdl = new PhysicalModel(250);

  mdl.setGravity(0.000);
  mdl.setFriction(0.000);
 
  generatePinSphere(mdl, dimX, dimY, dimZ, "osc", "spring", 1., 5, 0., 0.0, 0.1, 0.1);

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


void mousePressed() {

}

void mouseReleased() {
  
}



void keyPressed() {
  if (key == ' ')
      fExt();

}

void keyReleased() {
  if (key == ' ');
}