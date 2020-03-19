
import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;

import miPhysics.Engine.*;
import miPhysics.Renderer.*;
import miPhysics.Engine.Sound.*;

int baseFrameRate = 60;

int mouseDragged = 0;

/* Phyiscal parameters for the model */
float m = 1.0;
float k = 0.2;
float z = 0.0001;

// slight pre-strain on the beam by using a shorter l0
float l0 = 20;

// spacing between the masses, imposed by the fixed points at each end
float dist = 25;

float fric = 0.00001;
float grav = 0.;

int dimX = 45;
int dimY = 2;
int dimZ = 2;

boolean triggerForceRamp = false;
float forcePeak = 10;


float frc = 0;
float frcRate = 0.01;

float currAudio = 0;

PeasyCam cam;


PhysicalModel mdl;
ModelRenderer renderer;
miPhyAudioClient audioStreamHandler;



///////////////////////////////////////

void setup()
{
  fullScreen(P3D,2);

  // Setup PeasyCam
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(500000);
    cam.setDistance(500);  // distance from looked-at point

  // Setup the Physical Model
  mdl = new PhysicalModel(44100, (int)baseFrameRate);
    mdl.setGlobalGravity(0,0,grav);
    mdl.setGlobalFriction(fric);
    generateVolume(mdl, dimX, dimY, dimZ, "mass", "spring", m, 1, l0, dist, k, z);
    
    mdl.addInOut("driver", new Driver3D(), "mass5");
    mdl.addInOut("listener", new Observer3D(filterType.HIGH_PASS), "mass85");
    mdl.init();
  
  // Setup the renderer
  renderer = new ModelRenderer(this);
  renderer.displayMasses(true);
  renderer.setColor(massType.MASS3D, 50, 255, 200);
  renderer.setColor(massType.GROUND3D, 120, 200, 100);
  renderer.setColor(interType.SPRINGDAMPER3D, 135, 70, 70, 255);
  renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 0.5);
  renderer.setStrainColor(interType.SPRINGDAMPER3D, 105, 100, 200, 255);
 
    
  // Setup the simulation / audio stream
  audioStreamHandler = miPhyAudioClient.miPhyClassic(44100, 128, 0, 2, mdl);
  audioStreamHandler.start();
  
  frameRate(baseFrameRate);




}

void draw()
{
  background(0,0,25);

  directionalLight(126, 126, 126, 100, 0, -1);
  ambientLight(182, 182, 182);

  renderer.renderModel(simUGen.mdl);

  cam.beginHUD();
  stroke(125,125,255);
  strokeWeight(2);
  fill(0,0,60, 220);
  rect(0,0, 250, 50);
  textSize(16);
  fill(255, 255, 255);
  text("Curr Audio: " + currAudio, 10, 30);
  cam.endHUD();

}

void keyPressed() {
    if (key =='a'){
      forcePeak = 0.1;
      triggerForceRamp = true;
    }
    if (key =='z'){
      forcePeak = 0.5;
      triggerForceRamp = true;
    }
    if (key =='e'){
      forcePeak = 1;
      triggerForceRamp = true;
    }
    if (key =='r'){
      forcePeak = 2;
      triggerForceRamp = true;
    }
    if (key =='t'){
      forcePeak = 3;
      triggerForceRamp = true;
    }
  
}
