import miPhysics.Engine.*;
import miPhysics.Renderer.*;

import peasy.*;
PeasyCam cam;

int displayRate = 60;

PhysicsContext phys;
ModelRenderer renderer;

boolean showInstructions = true;
LineDrawer[] ld;
int nbMass;
float rotY = 0.;
float rotX = 0.;

int RENDERER_SWITCH = 0;

void setup() {
  frameRate(displayRate);
  fullScreen(P3D);

  cam = new PeasyCam(this, 250);
  cam.setMinimumDistance(100);
  cam.setMaximumDistance(1500);
  cam.rotateX(-PI/2);
  
  buildModel(0);
  
  renderer = new ModelRenderer(this);
  renderer.setZoomVector(1,1,1);
  renderer.displayModuleNames(false);
  renderer.displayMasses(false);
  renderer.displayInteractions(false);
  renderer.setTextSize(6);
  renderer.setForceVectorScale(500);
  renderer.displayAutoCollisionVolumes(false);
}



void draw() {
  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(142, 142, 142);
  cam.rotateY(rotY);
  cam.rotateX(rotX);
  
  background(0, 10);
  
  if(showInstructions)
    displayModelInstructions();
  
  phys.computeScene();
  
  
  renderer.renderScene(phys);
  
  switch(RENDERER_SWITCH){
    case 0:
      int cpt = 0;
      for(Mass m : phys.mdl().getMassList()){
        ld[cpt].addPoint(m.getPos());
        ld[cpt].drawLines();
        cpt++;
      }
      break;
   case 1:
     customRenderer(phys.mdl());
     break;
  }
}




/* Trigger random forces on the mass */
void keyPressed() {
  switch(key){
    case ' ':
      for(Driver3D driver : phys.mdl().getDrivers())
        driver.applyFrc(new Vect3D(random(-2,2),random(-2,2),random(-2,2)));
      break;
    case 'w':
      RENDERER_SWITCH = 0;
      renderer.displayMasses(false);
      break;
    case 'x':
      RENDERER_SWITCH = 1;
      renderer.displayMasses(false);
      break;
    case 'c':
      RENDERER_SWITCH = 2;
      renderer.displayMasses(true);
      break;
    case 'r':
      if(rotY == 0){
        rotY = 0.005;
        rotX = 0.006;
      }
      else{
        rotY = 0;
        rotX = 0;
      }
      break;
    case 'h':
      showInstructions = !showInstructions;
      break;
    case 'q':
      synchronized(phys.getLock()){
        phys.clearModel();
        buildModel(0);
      }
      break;
    case 's':
      synchronized(phys.getLock()){
        phys.clearModel();
        buildModel(1);
      }
      break;
    case 'd':
      synchronized(phys.getLock()){
        phys.clearModel();
        buildModel(2);
      }
      break;
    case 'a':
      renderer.toggleAutoCollisonVolumesDisplay();
      break;
    default:
      break;
  }
}



void displayModelInstructions(){
  cam.beginHUD();
  textMode(MODEL);
  textSize(16);
  fill(255, 255, 255);
  text("Press the space bar to trigger random forces on the masses", 10, 30);
  text("Press 'r' to toggle scene rotation", 10, 55);
  
  text("- 'q' : model with auto-collision engine", 10, 80);
  text("- 's' : model with brute force collision engine", 10, 105);
  text("- 'd' : larger model with  no collision engine", 10, 130);

  text("- 'w' : trajectory line trace view", 10, 160);
  text("- 'x' : point-based view", 10, 185);
  text("- 'c' : standard renderer view", 10, 210);


  text("Press 'a' to toggle Auto-Collision boxes display", 10, 240);
  text("FrameRate : " + frameRate, 10, 270);
  text("Press 'h' to hide instructions", 10, 300);

  cam.endHUD();
}
