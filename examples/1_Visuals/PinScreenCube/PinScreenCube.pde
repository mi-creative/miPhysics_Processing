/*
Model: PinScreen Cube
Author: Jérôme Villeneuve

A 3D mesh of oscillators (mass-spring-ground).

Hit the space bar to excite random oscillators inside the cube,
and see how the energy propagates, how the cube comes back to its form.

Lots of different parameter spaces to explore, see in code below!
*/

import miPhysics.Engine.*;

import peasy.*;

PeasyCam cam;

// SOME GLOBAL DECLARATIONS AND REQUIRED ELEMENTS

int displayRate = 50;

/*  "dimension" of the model - number of MAT modules */

int dimX = 20;
int dimY = 20;
int dimZ = 20;

boolean showInstructions = true;


/*  global physical model object : will contain the model and run calculations. */
PhysicsContext phys;
Driver3D d;


/* control dessin */
int mouseDragged = 0;


/* Quick class to handle different parameter sets... */
class ParamSet{
  String m_name;
  double m_mass;
  double m_dist;
  double m_Ko;
  double m_Zo;
  double m_K;
  double m_Z;
  
  ParamSet(String name, double mass, double dist, double Ko, double Zo, double K, double Z){
    m_name = name;
    m_mass = mass;
    m_dist = dist;
    m_Ko = Ko;
    m_Zo = Zo;
    m_K = K;
    m_Z = Z;
  }
}

// An array list of parameter sets and a current index to navigate through parameters
int curParamSet = 8;
ArrayList<ParamSet> paramSetList = new ArrayList<ParamSet>();


// SETUP: THIS IS WHERE WE SETUP AND INITIALISE OUR MODEL

void setup() {
  size(1000, 700, P3D);

  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);

  background(0);

  // instantiate our physical model context
  phys = new PhysicsContext(250, displayRate);

  phys.setGlobalFriction(0.006);
  
  //A bunch of different physical conditions for the PinScreenCube 
  paramSetList.add(new ParamSet("Glue", 1., 5, 0.0001, 0.05, 0.005, 0.0001));
  paramSetList.add(new ParamSet("Slow Return", 1., 5, 0.00001, 0.05, 0.00005, 0.00001));
  paramSetList.add(new ParamSet("FireWorks", 1., 5, 0.01, 0.1, 0.1, 0.001));
  paramSetList.add(new ParamSet("Pushing Cube", 1., 5, 0.0001, 0.05, 0.1, 0.0));
  paramSetList.add(new ParamSet("Sublimation", 1., 5, 0.0001, -0.05, 0.001, 0.005));
  paramSetList.add(new ParamSet("All Around", 1., 5, 0.0001, -0.005, 0.001, 0.005));
  paramSetList.add(new ParamSet("Jelly Cube", 1., 5, 0.0001, -0.0005, 0.001, 0.005));
  paramSetList.add(new ParamSet("Trapped Oscillators", 1., 5, 0.001, -0.0000005, 0.001, 0.05));
  paramSetList.add(new ParamSet("Shockwaves", 1., 5, 0.001, -0.00000005, 0.01, 0.1));
  paramSetList.add(new ParamSet("Beating Cube", 1., 5, 0.001, -0.00000005, 0.1, 0.1));
  paramSetList.add(new ParamSet("Gas Cube", 1., 5, 0.3, 0.0, 0.1, 0.0));
  paramSetList.add(new ParamSet("Sculpt Inwards", 1., 5, 0., 0.1, 0.1, 0.1));
  paramSetList.add(new ParamSet("Scupt Outwards", 1., 5, 0., 0.1, 0.0, 0.1));
  paramSetList.add(new ParamSet("Cut it free v1", 1., 5, 0., 0.0, 0.1, 0.1));
  paramSetList.add(new ParamSet("Cut it free v2", 1., 5, 0., 0.1, 0.005, 0.1));
 

  generateWithParamSet(paramSetList.get(curParamSet));

  
  frameRate(displayRate);
} 

// DRAW: THIS IS WHERE WE RUN THE MODEL SIMULATION AND DISPLAY IT

void draw() {

  phys.computeScene();

  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);

  background(0);
  
  if(showInstructions)
    displayModelInstructions();

  pushMatrix();
  translate(-dimX*5./2., -dimY*5./2., -dimY*5./2.); // les 5. est supposé être la variable dist envoyée dans les fonction de génération de modle
  
  renderModelPnScrn3D(phys.mdl(), 1);

  popMatrix();
  
}


void fExt(){
  synchronized(phys.getLock()){
  String matName = "osc" + floor(random(dimX))+"_"+ floor(random(dimY))+"_"+ floor(random(dimZ));
  d.moveDriver(phys.mdl().getMass(matName));
  d.applyFrc(new Vect3D(random(100) , random(100), random(500)));
  }
}


void keyPressed() {
  switch(key){
    case ' ':
      fExt();
      break;
    case 'h':
      showInstructions = !showInstructions;
    default:
      break;
  }
  switch(keyCode){
    case LEFT:
      curParamSet = (curParamSet + paramSetList.size()-1) % paramSetList.size();
      generateWithParamSet(paramSetList.get(curParamSet));
      break;
    case RIGHT:
      curParamSet = (curParamSet + 1) % paramSetList.size();
      generateWithParamSet(paramSetList.get(curParamSet));
      break;
  }
  if (key == ' ')
      fExt();

}


void generateWithParamSet(ParamSet p){
  synchronized(phys.getLock()){
    phys.clearModel();
    generatePinScreen3D(phys.mdl(),dimX,dimY,dimZ,"osc","spring", p.m_mass, p.m_dist, p.m_Ko, p.m_Zo, p.m_K, p.m_Z);
    d = phys.mdl().addInOut("driver", new Driver3D(), "osc0_0_0");
    phys.init();
  }
}

void displayModelInstructions(){
  cam.beginHUD();
  textMode(MODEL);
  textSize(16);
  fill(255, 255, 255);
  text("Press the space bar to trigger force impulses", 10, 30);
  text("Use LEFT and RIGHT to switch between settings", 10, 55);
  text("Current Setting : " + paramSetList.get(curParamSet).m_name, 10, 80);
  text("Press 'h' to hide instructions", 10, 110);

  cam.endHUD();
}
