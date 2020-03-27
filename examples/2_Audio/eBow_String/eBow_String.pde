import peasy.*;

import miPhysics.Renderer.*;
import miPhysics.Engine.*;
import miPhysics.Engine.Sound.*;

import java.math.RoundingMode;
import java.text.DecimalFormat;

/* Phyiscal parameters for the model */

int baseFrameRate = 60;
float currAudio = 0;

PeasyCam cam;

PhysicsContext phys; 
Observer3D listener;
PosInput3D input;
ModelRenderer renderer;

miPhyAudioClient audioStreamHandler;

int smoothing = 100;

boolean showInstructions = true;

///////////////////////////////////////

void setup()
{
  //size(1000, 700, P3D);
  fullScreen(P3D,1);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(5500);

  Medium med = new Medium(0.00001, new Vect3D(0, -0.00, 0.0));

  phys = new PhysicsContext(44100);

  double dist = 0.1;
  int nbMass = 240;

  miString string = new miString("string", med, nbMass, 0.1, 1, 0.4, 0.01, 0.1, 0.02, "2D");
  string.rotate(0, PI/2, 0);
  string.translate((float)-dist*nbMass/2, 0, 0);
  string.changeToFixedPoint(string.getFirstMass());
  string.changeToFixedPoint(string.getLastMass());
  
  
  PhyModel perc = new PhyModel("pluck", med);
  input = perc.addMass("input", new PosInput3D(1, new Vect3D(3, -4, 0), 100));

  phys.mdl().addPhyModel(string);
  phys.mdl().addPhyModel(perc);

  listener = phys.mdl().addInOut("listener1", new Observer3D(filterType.HIGH_PASS), phys.mdl().getPhyModel("string").getMass("m_10"));
  phys.mdl().addInOut("listener2", new Observer3D(filterType.HIGH_PASS), phys.mdl().getPhyModel("string").getMass("m_100"));

  phys.colEngine().addCollision(string, perc, 0.0002, -0.001);

  phys.init();

  renderer = new ModelRenderer(this);  
  renderer.setZoomVector(100, 100, 100);  
  renderer.displayMasses(true);  
  renderer.setColor(massType.MASS2DPLANE, 140, 140, 40);
  renderer.setColor(interType.SPRINGDAMPER3D, 135, 70, 70, 255);
  renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 0.1);
  renderer.setStrainColor(interType.SPRINGDAMPER3D, 105, 100, 200, 255);
  
  renderer.displayIntersectionVolumes(true);
  renderer.displayForceVectors(false);

  audioStreamHandler = miPhyAudioClient.miPhyClassic(44100, 128, 0, 2, phys);
  audioStreamHandler.setListenerAxis(listenerAxis.Y);
  audioStreamHandler.setGain(0.5);
  audioStreamHandler.start();

  cam.setDistance(500);  // distance from looked-at point

  frameRate(baseFrameRate);
}

void draw()
{
  noCursor();
  background(0, 0, 25);
  directionalLight(126, 126, 126, 100, 0, -1);
  ambientLight(182, 182, 182);

  float x = 40 * (float)mouseX / width - 20;
  float y = 30 * (float)mouseY / height - 15;
  input.drivePosition(new Vect3D(x, y, 0));

  if(showInstructions)
    displayModelInstructions();

  renderer.renderScene(phys);
}

void keyPressed(){
  switch(key){
    case 'o':
      renderer.toggleObjectVolumesDisplay();
      break;
    case 'v':
      renderer.toggleIntersectionVolumesDisplay();
      break;
    case 'h':
      showInstructions = !showInstructions;
  
  }
}


void displayModelInstructions(){
  cam.beginHUD();
  textMode(MODEL);
  textSize(16);
  fill(255, 255, 255);
  text("Hover the mouse over the string to trigger and eBow-style excitation.", 10, 30);
  text("Press 'o' to toggle object volumes display", 10, 55);
  text("Press 'v' to toggle intersection volumes display", 10, 80);
  text("Press 'h' to hide help", 10, 105);
  text("FrameRate : " + frameRate, 10, 130);
  DecimalFormat df = new DecimalFormat("#.####");
  df.setRoundingMode(RoundingMode.CEILING);
  text("Curr Audio: " + df.format(listener.observePos().y), 10, 155);
  cam.endHUD();
}
