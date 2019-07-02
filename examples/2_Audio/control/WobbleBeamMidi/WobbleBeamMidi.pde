
import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;
import themidibus.*; //Import the library

MidiBus myBus; // The MidiBus
int baseFrameRate = 60;

private Object lock = new Object();


PeasyCam cam;

// Audio Output Variables Init
float currAudio = 0;
Minim minim;
PhyUGen simUGen;
Gain gain;
AudioOutput out;
ArrayList<MidiController> midiCtrls = new ArrayList<MidiController>();

ModelRenderer renderer;
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
  gain = new Gain(-10);
  
  // create a physicalModel UGEN
  simUGen = new PhyUGen(44100);
  
  myBus = new MidiBus(this, 0, 1); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.

  
  midiCtrls.add(MidiController.addMidiController(simUGen.mdl,1,0.1,0.4,"spring","stiffness"));
  midiCtrls.add(MidiController.addMidiController(simUGen.mdl,2,0.0001,0.1,"spring","damping"));
  midiCtrls.add(MidiController.addMidiController(simUGen.mdl,3,0.5,5,"spring","dist",0.05));
  midiCtrls.add(MidiController.addMidiController(simUGen.mdl,3,0.5*sqrt(2),5*sqrt(2),"spring_cross","dist",0.05));
  midiCtrls.add(MidiController.addMidiController(simUGen.mdl,3,0.5,5,"mass_f","distX",0.05));
  
  midiCtrls.add(MidiController.addMidiController(simUGen.mdl,4,0.1,0.4,"col","stiffness"));
  midiCtrls.add(MidiController.addMidiController(simUGen.mdl,5,0.0001,0.1,"col","damping"));
 // midiCtrls.add(new MidiController(simUGen.mdl,6,0.2,1,"col","dist"));
  
  
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

  
  //simUGen.mdl.triggerForceImpulse("mass"+(excitationPoint), 0, 1, 0);
  cam.setDistance(500);  // distance from looked-at point
  
  frameRate(baseFrameRate);

  
}

void draw()
{
  background(255,255,255);

  directionalLight(126, 126, 126, 100, 0, -1);
  ambientLight(182, 182, 182);

  renderer.renderModel(simUGen.mdl);

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

void controllerChange(int channel, int number, int value) {
  for (MidiController mc : midiCtrls)
    {
      mc.changeParam(number, value);
    }
}
