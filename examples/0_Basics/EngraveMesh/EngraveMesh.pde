/*
Model: Engrave Mesh
Author: James Leonard (james.leonard@gipsa-lab.fr)

Draw a 2D Mesh of Osc modules (mass-spring-ground systems).

Drag the mouse across the surface to apply forces and create ripples.
Use UP and DOWN keys to add/decrease air friction in the model.
*/

import miPhysics.*;
import peasy.*;
PeasyCam cam;

// SOME GLOBAL DECLARATIONS AND REQUIRED ELEMENTS

int displayRate = 60;
boolean BASIC_VISU = false;

/*  "dimension" of the model - number of MAT modules */

int dimX = 100;
int dimY = 100;

/*  global physical model object : will contain the model and run calculations. */
PhysicalModel mdl;
ModelRenderer renderer;

/* elements to calculate the number of steps to simulate in each draw() method */
float simDisplay_factor;
int nbSteps;
float residue = 0;

/* control dessin */
int mouseDragged = 0;

int gridSpacing = 1;
int xOffset= 0;
int yOffset= 0;

float fric = 0.001;


// SETUP: THIS IS WHERE WE SETUP AND INITIALISE OUR MODEL

void setup() {
  
  //size(700, 700, P3D);
  fullScreen(P3D);
  background(0);

  // instantiate our physical model context
  mdl = new PhysicalModel(550);
  renderer = new ModelRenderer(this);
  
  
  mdl.setGravity(0.000);
  mdl.setFriction(fric);
  gridSpacing = height/dimX;
  
  generatePinScreen(mdl, dimX, dimY, "osc", "spring", 1., gridSpacing, 0.0002, 0.0, 0.06, 0.1);

  // initialise the model before starting calculations.
  mdl.init();

  if (BASIC_VISU){
    renderer.displayMats(false);
    renderer.setColor(linkModuleType.SpringDamper3D, 155, 200, 200, 255);
    renderer.setSize(linkModuleType.SpringDamper3D, 1);
  }
  else{
    renderer.displayMats(false);
    renderer.setColor(linkModuleType.SpringDamper3D, 255, 50, 50, 0);
    renderer.setStrainGradient(linkModuleType.SpringDamper3D, true, 0.1);
    renderer.setStrainColor(linkModuleType.SpringDamper3D, 255, 100, 255, 255);
  }
  
  
  frameRate(displayRate);

  simDisplay_factor = (float) mdl.getSimRate() / (float) displayRate;
  println("The simulation/display factor is :" + simDisplay_factor);
  
  xOffset = height/2;
  yOffset = 50;
} 

// DRAW: THIS IS WHERE WE RUN THE MODEL SIMULATION AND DISPLAY IT

void draw() {

  float  floatingFramestoSim = simDisplay_factor + residue;
  nbSteps = floor(floatingFramestoSim);
  residue = floatingFramestoSim - nbSteps;
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2, height/2.0, 0, 0, 1, 0);

  //println(" NbSteps: "+ nbSteps + ", residue: " + residue);

  mdl.computeNSteps(nbSteps);

  background(0);

  pushMatrix();
  translate(xOffset,yOffset, 0.);
  renderer.renderModel(mdl);
  popMatrix();
  
  fill(255);
  textSize(10); 

  text("Friction: " + fric, 50, 50, 50);

  if (mousePressed == true){
    //fExt();
  }
  
  if (mouseDragged == 1){
    if((mouseX) < (dimX*gridSpacing+xOffset) & (mouseY) < (dimY*gridSpacing+yOffset) & mouseX>xOffset & mouseY > yOffset){ // Garde fou pour ne pas sortir des limites du pinScreen
      println(mouseX, mouseY);
      engrave(mouseX-xOffset, mouseY - yOffset);
    }
  }  
}


void fExt(){
  String matName = "osc" + floor(random(dimX))+"_"+ floor(random(dimY));
  mdl.triggerForceImpulse(matName, random(100) , random(100), random(500));
}

void engrave(float mX, float mY){
  String matName = "osc" + floor(mX/ gridSpacing)+"_"+floor(mY/ gridSpacing);
  mdl.triggerForceImpulse(matName, 0. , 0., 15.);
}


void mouseDragged() {
  mouseDragged = 1;
  
}

void mouseReleased() {
  mouseDragged = 0;
}

void keyPressed() {
  if (key == ' ')
  mdl.setGravity(-0.001);
  if(keyCode == UP){
    fric += 0.001;
    mdl.setFriction(fric);
    println(fric);

  }
  else if (keyCode == DOWN){
    fric -= 0.001;
    fric = max(fric, 0);
    mdl.setFriction(fric);
    println(fric);
  }
}

void keyReleased() {
  if (key == ' ')
  mdl.setGravity(0.000);
}




void generatePinScreen(PhysicalModel mdl, int dimX, int dimY, String mName, String lName, double masValue, double dist, double K_osc, double Z_osc, double K, double Z) {

  String masName;
  Vect3D X0, V0;

  for (int i = 0; i < dimY; i++) {
    for (int j = 0; j < dimX; j++) {
      masName = mName + j +"_"+ i;
      X0 = new Vect3D((float)j*dist,(float)i*dist, 0.);
      V0 = new Vect3D(0., 0., 0.);
      mdl.addOsc3D(masName, masValue, K_osc, Z_osc, X0, V0);
    }
  }


  // add the spring to the model: length, stiffness, connected mats
  String masName1, masName2;

    for (int i = 0; i < dimX; i++) {
      for (int j = 0; j < dimY-1; j++) {
        masName1 = mName + i +"_"+ j;
        masName2 = mName + i +"_"+ str(j+1);
        mdl.addSpringDamper3D(lName + "1_" +i+j, dist, K, Z, masName1, masName2);
      }
    }
    
    for (int i = 0; i < dimX-1; i++) {
      for (int j = 0; j < dimY; j++) {
        masName1 = mName + i +"_"+ j;
        masName2 = mName + str(i+1) +"_"+ j;
        mdl.addSpringDamper3D(lName + "1_" +i+j, dist, K, Z, masName1, masName2);
      }
    }
}
