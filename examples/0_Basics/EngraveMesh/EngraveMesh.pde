/*
Model: Engrave Mesh
 Author: James Leonard (james.leonard@gipsa-lab.fr)
 
 Draw a 2D Mesh of Osc modules (mass-spring-ground systems).
 
 Drag the mouse across the surface to apply forces and create ripples.
 Use UP and DOWN keys to add/decrease air friction in the model.
 */

import miPhysics.Engine.*;
import miPhysics.Renderer.*;

import peasy.*;
PeasyCam cam;

// SOME GLOBAL DECLARATIONS AND REQUIRED ELEMENTS

int displayRate = 60;
boolean BASIC_VISU = false;

/*  "dimension" of the model - number of MAT modules */

int dimX = 80;
int dimY = 80;

/*  global physical model object : will contain the model and run calculations. */
PhysicsContext phys;
ModelRenderer renderer;


/* control dessin */
int mouseDragged = 0;

int gridSpacing = 1;
int xOffset= 0;
int yOffset= 0;

float fric = 0.001;

Driver3D d;


// SETUP: THIS IS WHERE WE SETUP AND INITIALISE OUR MODEL

void setup() {

  fullScreen(P3D);
  background(0);

  // instantiate our physical model context
  phys = new PhysicsContext(550, displayRate, paramSystem.ALGO_UNITS);
  renderer = new ModelRenderer(this);
  

  phys.setGlobalGravity(new Vect3D(0, 0, 0));
  phys.setGlobalFriction(fric);
  gridSpacing = height/dimX;
  generateMesh(phys.mdl(), dimX, dimY, "osc", "spring", 1., 1., gridSpacing, 0.0002, 0.0, 0.06, 0.1);

  d = phys.mdl().addInOut("driver", new Driver3D(), "osc0_0");


  // initialise the model before starting calculations.
  phys.init();

  if (BASIC_VISU) {
    renderer.displayMasses(false);
    renderer.setColor(interType.SPRINGDAMPER3D, 155, 200, 200, 255);
    renderer.setSize(interType.SPRINGDAMPER3D, 1);
  } else {
    renderer.displayMasses(false);
    renderer.setColor(interType.SPRINGDAMPER3D, 255, 50, 50, 0);
    renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 0.1);
    renderer.setStrainColor(interType.SPRINGDAMPER3D, 255, 100, 255, 255);
  }


  frameRate(displayRate);

  xOffset = height/2;
  yOffset = 50;
} 

// DRAW: THIS IS WHERE WE RUN THE MODEL SIMULATION AND DISPLAY IT

void draw() {
  
  noCursor();
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2, height/2.0, 0, 0, 1, 0);

  phys.computeScene();

  background(0);

  pushMatrix();
  translate(xOffset, yOffset, 0.);
  renderer.renderScene(phys);
  popMatrix();

  println("FrameRate:" + frameRate);

  displayModelInstructions();
  
  
  if (mouseDragged == 1) {
    if ((mouseX) < (dimX*gridSpacing+xOffset) & (mouseY) < (dimY*gridSpacing+yOffset) & mouseX>xOffset & mouseY > yOffset) { // Garde fou pour ne pas sortir des limites du pinScreen
      println(mouseX, mouseY);
      engrave(mouseX-xOffset, mouseY - yOffset);
    }
  }
}

void engrave(float mX, float mY) {
  String matName = "osc" + floor(mX/ gridSpacing)+"_"+floor(mY/ gridSpacing);
  
  d.moveDriver(phys.mdl().getMass(matName));
  d.applyFrc(new Vect3D(0., 0., 15.));
}


void mouseDragged() {
  mouseDragged = 1;
}

void mouseReleased() {
  mouseDragged = 0;
}

void keyPressed() {

  if(keyCode == UP){
    fric += 0.001;
    phys.setGlobalFriction(fric);
    println(fric);

  }
  else if (keyCode == DOWN){
    fric -= 0.001;
    fric = max(fric, 0);
    phys.setGlobalFriction(fric);
    println(fric);
  }
}


void generateMesh(PhyModel mdl, int dimX, int dimY, String mName, String lName, double masValue, double radius, double dist, double K_osc, double Z_osc, double K, double Z) {

  String masName;
  Vect3D X0, V0;

  for (int i = 0; i < dimY; i++) {
    for (int j = 0; j < dimX; j++) {
      masName = mName + j +"_"+ i;
      X0 = new Vect3D((float)j*dist, (float)i*dist, 0.);
      V0 = new Vect3D(0., 0., 0.);

      mdl.addMass(masName, new Osc3D(masValue, radius, K_osc, Z_osc, X0, V0));
    }
  }


  // add the spring to the model: length, stiffness, connected mats
  String masName1, masName2;

  for (int i = 0; i < dimX; i++) {
    for (int j = 0; j < dimY-1; j++) {
      masName1 = mName + i +"_"+ j;
      masName2 = mName + i +"_"+ str(j+1);
      mdl.addInteraction(lName + "1_" +i+"_"+j, new SpringDamper3D(dist, K, Z), masName1, masName2);
    }
  }

  for (int i = 0; i < dimX-1; i++) {
    for (int j = 0; j < dimY; j++) {
      masName1 = mName + i +"_"+ j;
      masName2 = mName + str(i+1) +"_"+ j;
      mdl.addInteraction(lName + "2_" +i+"_"+j, new SpringDamper3D(dist, K, Z), masName1, masName2);
    }
  }
}



void displayModelInstructions(){
  textMode(MODEL);
  textSize(16);
  fill(255, 255, 255);
  text("Drag mouse along the mesh !", 10, 30);
  text("Use up and down arrows to modify global air friction", 10, 50);
  text("Current air friction: " + fric, 10, 75);
}
