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

  size(1000, 700, P3D);

  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);

  background(0);

  // instantiate our physical model context
  mdl = new PhysicalModel(250);

  mdl.setGravity(0.000);
  mdl.setFriction(0.006);

  //generateMembrane(mdl, dimX, dimY, "mass", "spring", 1., 20, 0.1, 0.1);
  
  //generateVolume(mdl, dimX, dimY, dimZ, "mass", "spring", 1., 20, 0.005, 0.003);
  
  
  //SERIE DE TEST POUR ECRAN EPINGLE 3D
  
  //Engluer
  //generatePinScreen3D(mdl, dimX, dimY, dimZ, "osc", "spring", 1., 5, 0.0001, 0.05, 0.005, 0.0001);

  //Marquer la matière (proche amortissement critique)
  //generatePinScreen3D(mdl, dimX, dimY, dimZ, "osc", "spring", 1., 5, 0.00001, 0.05, 0.00005, 0.00001);
  
  //Fireworks
  //generatePinScreen3D(mdl, dimX, dimY, dimZ, "osc", "spring", 1., 5, 0.01, 0.1, 0.1, 0.001);
  
  //Punshing Cube
  //generatePinScreen3D(mdl, dimX, dimY, dimZ, "osc", "spring", 1., 5, 0.0001, 0.05, 0.1, 0.0);
  
  //Sublimation
  //generatePinScreen3D(mdl, dimX, dimY, dimZ, "osc", "spring", 1., 5, 0.0001, -0.05, 0.001, 0.005);
  
  //All Around
  //generatePinScreen3D(mdl, dimX, dimY, dimZ, "osc", "spring", 1., 5, 0.0001, -0.005, 0.001, 0.005);
  
  //Jelly Cube
  //generatePinScreen3D(mdl, dimX, dimY, dimZ, "osc", "spring", 1., 5, 0.0001, -0.0005, 0.001, 0.005);
  
  //Trapped Oscillators
  //generatePinScreen3D(mdl, dimX, dimY, dimZ, "osc", "spring", 1., 5, 0.001, -0.0000005, 0.001, 0.05);
  
  //Shockwaves
  generatePinScreen3D(mdl, dimX, dimY, dimZ, "osc", "spring", 1., 5, 0.001, -0.00000005, 0.01, 0.1);
  
  //Beating Cube
  //generatePinScreen3D(mdl, dimX, dimY, dimZ, "osc", "spring", 1., 5, 0.001, -0.00000005, 0.1, 0.1);
  
  //Gaz Cube
  //generatePinScreen3D(mdl, dimX, dimY, dimZ, "osc", "spring", 1., 5, 0.3, 0.0, 0.1, 0.0);
  
  //Sculpt it in
  //generatePinScreen3D(mdl, dimX, dimY, dimZ, "osc", "spring", 1., 5, 0., 0.1, 0.1, 0.1);
  
  //Sculpt it out
  //generatePinScreen3D(mdl, dimX, dimY, dimZ, "osc", "spring", 1., 5, 0., 0.1, 0.0, 0.1);
  
  //Cut it free
  //generatePinScreen3D(mdl, dimX, dimY, dimZ, "osc", "spring", 1., 5, 0., 0.0, 0.1, 0.1);
  
  //Cut it free
  //generatePinScreen3D(mdl, dimX, dimY, dimZ, "osc", "spring", 1., 5, 0., 0.1, 0.005, 0.1);
  
  
  
  
  //for (int i = 1; i <=mdl.getNumberOfMats(); i++)
  //  mdl.addPlaneInteraction("plane"+i, 0, 0.1, 0.005, 2, -40, "mass"+i);

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
  //drawPlane(2, -40, 800); 
  pushMatrix();
  translate(-dimX*5./2., -dimY*5./2., -dimY*5./2.); // les 5. est supposé être la variable dist envoyée dans les fonction de génération de modle
  
  renderModelPnScrn3D(mdl, 1);

  popMatrix();
  
  
  if (mousePressed == true){
    //fExt();
  }

  
  
}


void fExt(){
  //Vect3D frc = new Vect3D(random(100) , random(100), random(500));
  String matName = "osc" + floor(random(dimX))+"_"+ floor(random(dimY))+"_"+ floor(random(dimZ));
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