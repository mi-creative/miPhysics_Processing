
import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;
import miPhysics.*;

import themidibus.*; //Import the library

MidiBus myBus; // The MidiBus
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

ModelRenderer renderer;

float speed = 0;
float pos = 100;

ArrayList<MidiControler> midiCtrls = new ArrayList<MidiControler>();
ArrayList<midiNote> midiNotes = new ArrayList<midiNote>();
///////////////////////////////////////

void setup()
{
  size(1000, 700, P3D);
  //fullScreen(P3D, 2);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);

  minim = new Minim(this);

  // use the getLineOut method of the Minim object to get an AudioOutput object
  //out = minim.getLineOut();
  out = minim.getLineOut(Minim.STEREO, 1024,22050,16);

  recorder = minim.createRecorder(out, "myrecording.wav");

  // start the Gain at 0 dB, which means no change in amplitude
  gain = new Gain(0);

  // create a physicalModel UGEN
  simUGen = new PhyUGen(22050); //<>//
  
  //Adjust this to your settings using 
   MidiBus.list();  
  // Knowing that first integer paramater below is the input MIDI device and the second the output MIDI device
  myBus = new MidiBus(this, 0, 1); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.


  midiCtrls.add(MidiControler.addMidiControler(simUGen.mdl,1, 0.01, 0.3, "sprd", "stiffness",0.05));
  midiCtrls.add(MidiControler.addMidiControler(simUGen.mdl,2, 0.0001, 0.1, "sprd", "damping",0.05));
  midiCtrls.add(MidiControler.addMidiControler(simUGen.mdl,3, 0.5, 1.5, "str", "mass",0.05));
  midiCtrls.add(MidiControler.addMidiControler(simUGen.mdl,4, 20, 100, "gnd", "distX",0.05));

  //midiNotes.add(new midiNote(0.01, 0.9, "str",0,simUGen.nbmass - 1,"Y","impulse"));
  midiNotes.add(new midiNote(0.1, 10, "str",0,simUGen.nbmass - 1,"Y","pluck"));
  
  // patch the Oscil to the output
  simUGen.patch(gain).patch(out);

  renderer = new ModelRenderer(this);
  
  renderer.setZoomVector(100,100,100);
  
  renderer.displayMats(true);
  renderer.setSize(matModuleType.Mass3D, 40);
  renderer.setColor(matModuleType.Mass3D, 140, 140, 40);
  renderer.setSize(matModuleType.Mass2DPlane, 10);
  renderer.setColor(matModuleType.Mass2DPlane, 120, 0, 140);
  renderer.setSize(matModuleType.Ground3D, 25);
  renderer.setColor(matModuleType.Ground3D, 30, 100, 100);
  
  renderer.setColor(linkModuleType.SpringDamper3D, 135, 70, 70, 255);
  renderer.setStrainGradient(linkModuleType.SpringDamper3D, true, 0.1);
  renderer.setStrainColor(linkModuleType.SpringDamper3D, 105, 100, 200, 255);
  cam.setDistance(500);  // distance from looked-at point

  frameRate(baseFrameRate);
  
}

void draw()
{
  background(0, 0, 25);

  directionalLight(126, 126, 126, 100, 0, -1);
  ambientLight(182, 182, 182);

  renderer.renderModel(simUGen.mdl);
 // simUGen.

  cam.beginHUD();
  stroke(125, 125, 255);
  strokeWeight(2);
  fill(0, 0, 60, 220);
  rect(0, 0, 250, 50);
  textSize(16);
  fill(255, 255, 255);
  text("Curr Audio: " + currAudio, 10, 30);
  text("stiffness: " + simUGen.mdl.getParamValueOfSubset("sprd","stiffness"),10,50);
  text("damping: " + simUGen.mdl.getParamValueOfSubset("sprd","damping"),10,70);
  text("mass: " + simUGen.mdl.getParamValueOfSubset("str","mass"),10,90);
  cam.endHUD();
}


void mouseDragged() {
  mouseDragged = 1;
}

void mouseReleased() {
  mouseDragged = 0;
}


void keyPressed() {

  if (keyCode ==UP) {
    simUGen.mdl.triggerForceImpulse("guideM1", 0, -10000, 0);
    simUGen.mdl.triggerForceImpulse("guideM2", 0, -10000, 0);
    simUGen.mdl.triggerForceImpulse("guideM3", 0, -10000, 0);
  } else if (keyCode ==DOWN) {
    simUGen.mdl.triggerForceImpulse("guideM1", 0, 10000, 0);
    simUGen.mdl.triggerForceImpulse("guideM2", 0, 10000, 0);
    simUGen.mdl.triggerForceImpulse("guideM3", 0, 10000, 0);
  } else if (keyCode ==LEFT) {
    simUGen.mdl.triggerForceImpulse("guideM1", -5000, 0, 0);
    simUGen.mdl.triggerForceImpulse("guideM2", -5000, 0, 0);
    simUGen.mdl.triggerForceImpulse("guideM3", -5000, 0, 0);
  } else if (keyCode ==RIGHT) {
    simUGen.mdl.triggerForceImpulse("guideM1", 5000, 0, 0);
    simUGen.mdl.triggerForceImpulse("guideM2", 5000, 0, 0);
    simUGen.mdl.triggerForceImpulse("guideM3", 5000, 0, 0);
  }
}

void keyReleased() {
  if (key == ' ')
    simUGen.mdl.setGravity(0.000);
}

void controllerChange(int channel, int number, int value) {
  synchronized(lock)
  {
    for (MidiControler mc : midiCtrls)
    {
      mc.changeParam(number, value);
    }
  }
}

void noteOn(int channel, int pitch, int velocity) {
  synchronized(lock)
  {
  for (midiNote mn : midiNotes)
  {
    mn.on(pitch, velocity);
  }
  }
}

void noteOff(int channel,int pitch,int velocity)
{
  synchronized(lock)
  {
  for (midiNote mn : midiNotes)
  {
    mn.off(pitch, velocity);
  }
  }
}
