/*

String model excited with negative damping!
Place the excitation point somewhere along the string to inject energy, much like an eBow.
Model derived from the plucked string example by Olivier Tache.

*/

import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;

int baseFrameRate = 50;
float currAudio = 0;

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
  cam.setMaximumDistance(10000);
  cam.setDistance(500);  // distance from looked-at point

  minim = new Minim(this);
  
  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut();
  
  recorder = minim.createRecorder(out, "myrecording.wav");
  
  gain = new Gain(0);
  
  simUGen = new PhyUGen(44100);
  simUGen.patch(gain).patch(out);
  
  renderer = new ModelRenderer(this);
  
  renderer.setZoomVector(100,100,100);
  
  renderer.displayMasses(true);
  renderer.setColor(massType.MASS2DPLANE, 120, 0, 140);
  renderer.setColor(massType.GROUND3D, 30, 100, 100);
  renderer.setColor(interType.SPRINGDAMPER3D, 135, 70, 70, 255);
  renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 0.1);
  renderer.setStrainColor(interType.SPRINGDAMPER3D, 105, 100, 200, 255);
  
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
