/*
Model: Multiple strings
Author: James Leonard (james.leonard@gipsa-lab.fr)

6 strings, play with 'azerty' keys
start recording with 'w', stop with 'x'
*/

import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;

int baseFrameRate = 60;

import peasy.*;
import miPhysics.*;

private Object lock = new Object();

float currAudio = 0;
float gainVal = 1.;

float audioRamp = 0;

PeasyCam cam;

Minim minim;
PhyUGen simUGen;
Gain gain;

AudioOutput out;

boolean recording;
AudioRecorder recorder;

float[] frc = {0,0,0,0,0,0,0,0,0,0};
float[] frcRate = {0,0,0,0,0,0,0,0,0,0};
float[] forcePeak = {0,0,0,0,0,0,0,0,0,0};
boolean[] triggerForceRamp = {false,false,false,false,false,false,false,false,false,false};

///////////////////////////////////////

void setup()
{
  size(1000, 700, P3D);
  //fullScreen(P3D,2);
    cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(500000);
  
  minim = new Minim(this);
  
  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut(Minim.STEREO, 2048);
  
  recorder = minim.createRecorder(out, "myrecording.wav");
  
    // start the Gain at 0 dB, which means no change in amplitude
  gain = new Gain(0);
  
  // create a physicalModel UGEN
  simUGen = new PhyUGen(44100);
  // patch the Oscil to the output
  simUGen.patch(gain).patch(out);
  
  //createShapeArray(simUGen.mdl);
  
  cam.setDistance(500);  // distance from looked-at point
  
  frameRate(baseFrameRate);

}

void draw()
{
  background(25,25,25);

  directionalLight(126, 126, 126, 100, 0, -1);
  ambientLight(182, 182, 182);

  renderModelShapes(simUGen.mdl);

  cam.beginHUD();
  stroke(125,125,255);
  strokeWeight(2);
  fill(0,0,60, 220);
  rect(0,0, 290, 50);
  textSize(16);
  fill(255, 255, 255);
  text("Curr Audio: " + currAudio, 10, 30);
  if (recorder.isRecording()){
    stroke(255);
    fill(255, 0, 0);
    ellipse(255, 25, 25, 25);
  }
  cam.endHUD();

}




void keyPressed() {
  
  float speed = 0.8;
  if (key == ' ')
  simUGen.mdl.setGravity(-grav);
  
  if (key == 'a'){
      startForceTrigger(0, speed);
  }
  else if (key == 'z'){
      startForceTrigger(1, speed);
      }
  else if (key =='e'){
      startForceTrigger(2, speed);
  }
  else if (key =='r'){
      startForceTrigger(3, speed);
  }
  else if (key == 't'){
      startForceTrigger(4, speed);
  }
  else if (key == 'y'){
      startForceTrigger(5, speed);
      }
  else if (key =='u'){
      startForceTrigger(6, speed);
  }
  else if (key =='i'){
      startForceTrigger(7, speed);
  }
  
  else if (key == 'q'){
    grav = 0.001;
    simUGen.mdl.setGravity(grav);
  }
  else if (key=='s'){
    grav = 0.003;
    simUGen.mdl.setGravity(grav);
  }
  else if (key =='w')
      recorder.beginRecord();
  else if (key == 'x')
    recorder.endRecord();
}

void startForceTrigger(int chan, float speed){
      frcRate[chan] = speed;
      forcePeak[chan] = 4;
      triggerForceRamp[chan] = true;
}
