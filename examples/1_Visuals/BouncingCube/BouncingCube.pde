/*
Model: Bouncing Cube
Author: James Leonard (james.leonard@gipsa-lab.fr)

A cubic mesh of masses and springs, bouncing against a 2D Plane.

Beware, sometimes the cube "folds in" on itself!

*/

import peasy.*;

import miPhysics.Engine.*;
import miPhysics.Renderer.*;

int displayRate = 60;
boolean BASIC_VISU = false;

PeasyCam cam;

PhysicsContext phys;
Driver3D drive;
ModelRenderer renderer;


double grav = 0.001;
boolean showInstructions = true;

void setup() {

  size(1000, 700, P3D);

  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);
  cam.rotateX(radians(-80));
  cam.setDistance(750);

  background(0);

  phys = new PhysicsContext(1050, displayRate);

  phys.setGlobalGravity(0, 0, 0.001);
  phys.setGlobalFriction(0.000);
  
  generateVolume(phys.mdl(), 10, 10, 10, "mass", "spring", 1., 25, 0.03, 0.03);
  
  for(int i = 0; i < phys.mdl().getNumberOfMasses(); i++)
    phys.mdl().addInteraction("plane"+i, new PlaneContact3D(0.1, 0.005, 2, -40), "mass"+(i+1));

  drive = phys.mdl().addInOut("drive", new Driver3D(),"mass"+(10*10));


  phys.init();
  
  renderer = new ModelRenderer(this);
  if (BASIC_VISU){
    renderer.displayMasses(false);
    renderer.setColor(interType.SPRINGDAMPER3D, 155, 200, 200, 255);
    renderer.setSize(interType.SPRINGDAMPER3D, 1);
  }
  else{
    renderer.displayMasses(true);
    renderer.setColor(interType.SPRINGDAMPER3D, 0, 50, 255, 255);
    renderer.setSize(interType.SPRINGDAMPER3D, 1);
    renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 0.02);
    renderer.setStrainColor(interType.SPRINGDAMPER3D, 150, 150, 255, 255);
  }
  
  frameRate(displayRate);

} 



void draw() {
  
  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(0);
  drawPlane(2, -40, 800); 
  
  if(showInstructions)
    displayModelInstructions();
  
  phys.computeScene();
  renderer.renderScene(phys);
  
  println(frameRate);
}


void keyPressed() {
  switch(key){
    case ' ':
      phys.setGlobalGravity(0, 0, -grav);
      break;      
    case 'a':
      grav = 0.001;
      phys.setGlobalGravity(0,0,grav);
      break;
    case 'z':
      grav = 0.003;
      phys.setGlobalGravity(0,0,grav);
      break;
    case 'w':
      rebuildModel(10,10,10);
      break;
    case 'x':
      rebuildModel(2,7,30);
      break;
    case 'c':
      rebuildModel(2,2,50);
      break;
    case 'h':
      showInstructions = !showInstructions;
    default:
      break;
  }
  
  switch(keyCode){
    case UP:
      drive.applyFrc(new Vect3D(0,1, 0));
      break;
    case DOWN:
      drive.applyFrc(new Vect3D(0,-1, 0));
      break;
    case LEFT:
      drive.applyFrc(new Vect3D(1,0, 0));
      break;
    case RIGHT:
      drive.applyFrc(new Vect3D(-1,0, 0));
      break;
    default:
      break;
  }
}

void keyReleased() {
  if (key == ' ')
  phys.setGlobalGravity(0,0,grav);
}


void rebuildModel(int dimX, int dimY, int dimZ){
      // Synchonized is IMPORTANT : Make sure that nothing runs concurrently while we break and recreate the model !
      synchronized(phys.getLock()){
        phys.clearModel();
        
        generateVolume(phys.mdl(), dimX, dimY, dimZ, "mass", "spring", 1., 25, 0.03, 0.03);
        for(int i = 0; i < phys.mdl().getNumberOfMasses(); i++)
          phys.mdl().addInteraction("plane"+i, new PlaneContact3D(0.1, 0.005, 2, -40), "mass"+(i+1));
        drive = phys.mdl().addInOut("drive", new Driver3D(),"mass"+(dimY*dimZ));
        
        phys.init();
      }
}


void drawPlane(int orientation, float position, float size){
  stroke(255);
  fill(50);
  
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
  text("Press and release the space bar to invert gravity", 10, 30);
  text("Use arrows to send force impulses", 10, 55);
  text("Use 'a' and 'z' to set gravity amount", 10, 80);
  text("Use 'w', 'x' and 'c' to reconfigure the model !", 10, 105);
  text("FrameRate: " + frameRate, 10, 130);
  text("Press 'h' to hide instructions", 10, 160);

  cam.endHUD();
}
