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

float currAudio = 0;
float gainVal = 1.;

float audioRamp = 0;

PeasyCam cam;


Minim minim;
PhyUGen simUGen;
Gain gain;

AudioOutput out;
AudioRecorder recorder;


ModelRenderer renderer;

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
    
  cam.setDistance(500);  // distance from looked-at point
  
  renderer = new ModelRenderer(this);
  renderer.setSize(matModuleType.Mass3D, 5);
  
  frameRate(baseFrameRate);

}

void draw()
{
  background(25,25,25);

  directionalLight(126, 126, 126, 100, 0, -1);
  ambientLight(182, 182, 182);
  
  pushMatrix();
  rotateX(PI/2);
  
  PVector test = new PVector();
  
  synchronized(simUGen.mdl.getLock()){
    test = simUGen.mdl.getMatPVector("gnd").copy();
  }
  
  translate(test.x,test.z,test.y);
  drawHemisphere(1000., 0xEE660000, 50);
  drawHemisphere(1003., 0xFFFFFFAA, 50);
  popMatrix();

  strokeWeight(1);
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



void drawHemisphere(float rho, int col, float div){
  
  float factor = TWO_PI / div;
  float x, y, z;
  
  noStroke();
  fill(col);
  
  for(float phi = 0.0; phi < HALF_PI/2; phi += factor/2) {
    beginShape(QUAD_STRIP);
    for(float theta = 0.0; theta < TWO_PI + factor; theta += factor) {
      x = rho * sin(phi) * cos(theta);
      z = rho * sin(phi) * sin(theta);
      y = -rho * cos(phi);
 
      vertex(x, y, z);
 
      x = rho * sin(phi + factor) * cos(theta);
      z = rho * sin(phi + factor) * sin(theta);
      y = -rho * cos(phi + factor);
 
      vertex(x, y, z);
    }
    endShape(CLOSE);
  }

}



void keyPressed() {
    
  if (key == ' ')
  simUGen.mdl.setGravity(-grav);
  
  if (key == 'a'){
      simUGen.mdl.triggerForceImpulse("pebbleA_1_1_0", 0, 0.1, 0.1);
  }
  else if (key == 'z'){
      simUGen.mdl.triggerForceImpulse("pebbleB_1_2_0", 0,-0.1, 0.1);
      }
  else if (key =='e'){
      simUGen.mdl.triggerForceImpulse("pebbleA_1_1_0", 0.1,0, 0.1);

  }
  else if (key =='r'){
      simUGen.mdl.triggerForceImpulse("pebbleB_1_2_0", -0.1,0, 0.1);
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
      simUGen.mdl.triggerForceImpulse("gnd", 0,0, random(10,30));
}

void keyReleased() {
  if (key == ' ')
  simUGen.mdl.setGravity(grav);
}
