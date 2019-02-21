
import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;

int baseFrameRate = 60;

int mouseDragged = 0;

int gridSpacing = 2;
int xOffset= 0;
int yOffset= 0;

private Object lock = new Object();

float currAudio = 0;
float gainVal = 1.;


PeasyCam cam;

float percsize = 200;

Minim minim;
PhyUGen simUGen;
Gain gain;

AudioOutput out;
AudioRecorder recorder;


float speed = 0;
float pos = 100;


///////////////////////////////////////

void setup()
{
  //size(1000, 700, P3D);
  fullScreen(P3D,2);
    cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);
  
  minim = new Minim(this);
  
  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut();
  
  recorder = minim.createRecorder(out, "myrecording.wav");
  
    // start the Gain at 0 dB, which means no change in amplitude
  gain = new Gain(0);
  
  // create a physicalModel UGEN
  simUGen = new PhyUGen(44100);
  // patch the Oscil to the output
  simUGen.patch(gain).patch(out);
  
  createShapeArray(simUGen.mdl);
  
  //simUGen.mdl.triggerForceImpulse("mass"+(excitationPoint), 0, 1, 0);
  cam.setDistance(500);  // distance from looked-at point
  
  frameRate(baseFrameRate);

}

void draw()
{
  background(0,0,25);

  directionalLight(126, 126, 126, 100, 0, -1);
  ambientLight(182, 182, 182);

  renderModelShapes(simUGen.mdl);

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


void mouseDragged() {
  mouseDragged = 1;
  
}

void mouseReleased() {
  mouseDragged = 0;
}


void keyPressed() {

  if(keyCode ==UP){
    simUGen.mdl.triggerForceImpulse("guideM1",0,-10000,0);
    simUGen.mdl.triggerForceImpulse("guideM2",0,-10000,0);
    simUGen.mdl.triggerForceImpulse("guideM3",0,-10000,0);
  }
  else if (keyCode ==DOWN){
    simUGen.mdl.triggerForceImpulse("guideM1",0,10000,0);
    simUGen.mdl.triggerForceImpulse("guideM2",0,10000,0);
    simUGen.mdl.triggerForceImpulse("guideM3",0,10000,0);
  }
  else if(keyCode ==LEFT){
    simUGen.mdl.triggerForceImpulse("guideM1",-5000,0,0);
    simUGen.mdl.triggerForceImpulse("guideM2",-5000,0,0);
    simUGen.mdl.triggerForceImpulse("guideM3",-5000,0,0);
  }
  else if (keyCode ==RIGHT){
    simUGen.mdl.triggerForceImpulse("guideM1",5000,0,0);
    simUGen.mdl.triggerForceImpulse("guideM2",5000,0,0);
    simUGen.mdl.triggerForceImpulse("guideM3",5000,0,0);
  }
}

void keyReleased() {
  if (key == ' ')
  simUGen.mdl.setGravity(0.000);
}
