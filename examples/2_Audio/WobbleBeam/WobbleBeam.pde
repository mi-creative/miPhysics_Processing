
import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;

int baseFrameRate = 60;

private Object lock = new Object();


PeasyCam cam;

// Audio Output Variables Init
float currAudio = 0;
Minim minim;
PhyUGen simUGen;
Gain gain;
AudioOutput out;

///////////////////////////////////////

void setup()
{
  size(1000, 700, P3D); //   Fullscreen option
  //fullScreen(P3D,2); //    Or window option
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(5000);
  
  minim = new Minim(this);
  
  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut();
  
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
  background(255,255,255);

  directionalLight(126, 126, 126, 100, 0, -1);
  ambientLight(182, 182, 182);

  renderModelShapes(simUGen.mdl);

  cam.beginHUD();
  /* Visualzie Output Signal Info
  stroke(125,125,255);
  strokeWeight(2);
  fill(0,0,60, 220);
  rect(0,0, 250, 50);
  textSize(16);
  fill(255, 255, 255);
  text("Curr Audio: " + currAudio, 10, 30);
  */
  cam.endHUD();
}


void keyPressed() {
  
}

void keyReleased() {
  if (key == ' ')
  saveFrame("line-######.png");
}
