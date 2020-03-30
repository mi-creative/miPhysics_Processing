import peasy.*;

import miPhysics.Renderer.*;
import miPhysics.Engine.*;
import miPhysics.Engine.Sound.*;

/* Phyiscal parameters for the model */
float m = 1.0;
float k = 0.4;
float z = 0.01;
float l0 = 0.01;
float dist = 0.1;
float fric = 0.00003;
float grav = 0.;

float c_k = 0.01;
float c_z = 0.001;

int nbmass = 340;
int baseFrameRate = 60;
float currAudio = 0;

boolean showInstructions = true;

PeasyCam cam;

PhysicsContext phys; 
Observer3D listener;
PosInput3D input;
ModelRenderer renderer;

miPhyAudioClient audioStreamHandler;

float audioOut = 0;
int smoothing = 1000;

///////////////////////////////////////

void setup()
{
  //size(1000, 700, P3D);
  fullScreen(P3D,1);
  cam = new PeasyCam(this, 1000);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(5500);

  Medium med = new Medium(0.00001, new Vect3D(0, 0., 0.0));

  phys = new PhysicsContext(44100, baseFrameRate);

  miString string = new miString("string", med, 100, 0.2, 1, 0.4, 0.01, 0.1, 0.01, "2D");
  string.rotate(0, PI/2, 0);
  string.translate(-8,0,0);
  string.changeToFixedPoint("m_0");
  string.changeToFixedPoint("m_99");
  
  
  miString string2 = new miString("string2", med, 100, 0.2, 1, 0.4, 0.01, 0.1, 0.05, "2D");
  string2.rotate(0, PI/2, 0);
  string2.translate(-1, 2, 0);
  string2.changeToFixedPoint("m_0");
  string2.changeToFixedPoint("m_99");
  
  
  PhyModel perc = new PhyModel("pluck", med);

  input = perc.addMass("input", new PosInput3D(0.5, new Vect3D(-30, -30, 0), 100));

  phys.mdl().addPhyModel(string);
  phys.mdl().addPhyModel(string2);

  phys.mdl().addPhyModel(perc);

  phys.mdl().addInOut("listener1", new Observer3D(filterType.HIGH_PASS), phys.mdl().getPhyModel("string").getMass("m_10"));
  phys.mdl().addInOut("listener2", new Observer3D(filterType.HIGH_PASS), phys.mdl().getPhyModel("string2").getMass("m_40"));


  phys.colEngine().addCollision(string, perc, 0.05, 0.01);
  phys.colEngine().addCollision(string2, perc, 0.05, 0.01);
  phys.colEngine().addCollision(string, string2, 0.1, 0.01);

  phys.init();

  renderer = new ModelRenderer(this);  
  renderer.setZoomVector(100, 100, 100);  
  renderer.displayMasses(true);  
  renderer.setColor(massType.MASS2DPLANE, 120, 160, 240);
  renderer.setColor(interType.SPRINGDAMPER3D, 135, 70, 70, 255);
  renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 0.1);
  renderer.setStrainColor(interType.SPRINGDAMPER3D, 105, 100, 200, 255);

  audioStreamHandler = miPhyAudioClient.miPhyClassic(44100, 512, 0, 2, phys);
  audioStreamHandler.setListenerAxis(listenerAxis.Y);
  audioStreamHandler.setGain(0.3);
  audioStreamHandler.start();

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
  text("Use the red Position Input mass to pluck the strings with the mouse", 10, 30);
  text("Press 'o' to toggle object volumes display", 10, 55);
  text("Press 'v' to toggle intersection volumes display", 10, 80);
  text("Press 'h' to hide help", 10, 105);
  text("FrameRate : " + frameRate, 10, 130);
  cam.endHUD();
}
