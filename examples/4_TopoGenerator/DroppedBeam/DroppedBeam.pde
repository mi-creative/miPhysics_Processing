/*
Model: Bouncing Cube
Author: James Leonard (james.leonard@gipsa-lab.fr)

A cube of masses and springs, bouncing against a 2D Plane.

Beware, sometimes the cube "folds in" on itself!

Press and release space bar to invert gravity.
Press 'a', 'z', 'e' or 'r' to apply forces to the cube and set it off-axis.
Press 'q' or 's' to toggle between low and high gravity values.
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
  cam.setMaximumDistance(500000);
  
  minim = new Minim(this);
  
  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut(Minim.STEREO, 1024);
  
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
  background(25,25,25);

  directionalLight(126, 126, 126, 100, 0, -1);
  ambientLight(182, 182, 182);
  
  drawPlane(2, -40, 800); 

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




void keyPressed() {
  
  String mass = "mass_" + (dimX/2)+ "_" + (dimY/2) + "_" + (dimZ/2); 
  
  if (key == ' ')
  simUGen.mdl.setGravity(-grav);
  
  if (key == 'a'){
      simUGen.mdl.triggerForceImpulse(mass, 0,1, 0);
  }
  else if (key == 'z'){
      simUGen.mdl.triggerForceImpulse(mass, 0,-1, 0);
      }
  else if (key =='e'){
      simUGen.mdl.triggerForceImpulse(mass, 1,0, 0);

  }
  else if (key =='r'){
      simUGen.mdl.triggerForceImpulse(mass, -1,0, 0);
  }
  else if (key == 'q'){
    grav = 0.001;
    simUGen.mdl.setGravity(grav);
  }
  else if (key=='s'){
    grav = 0.003;
    simUGen.mdl.setGravity(grav);
  }
}

void keyReleased() {
  if (key == ' ')
  simUGen.mdl.setGravity(grav);
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
