/* TODO: cleanup this example, and write instructions ! */


import peasy.*;
import themidibus.*; //Import the library

MidiBus myBus; // The MidiBus

import miPhysics.Renderer.*;
import miPhysics.Engine.*;
import miPhysics.Engine.Sound.*;
import miPhysics.Control.*;

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

PeasyCam cam;

PhysicsContext phys; 
PosInput3D input;
Driver3D d;



ModelRenderer renderer;

miPhyAudioClient audioStreamHandler;

ArrayList<MidiController> midiCtrls = new ArrayList<MidiController>();
ArrayList<midiNote> midiNotes = new ArrayList<midiNote>();

float audioOut = 0;
int smoothing = 100;

///////////////////////////////////////

void setup()
{
  //size(1000, 700, P3D);
  fullScreen(P3D,1);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(5500);

  Medium med = new Medium(0.00001, new Vect3D(0, -0.00, 0.0));

  phys = new PhysicsContext(44100);
  
  phys.createMassSubset("masses");
  phys.createInteractionSubset("springs");


  miTopoCreator string = new miTopoCreator("string", med);
  string.setDim(300,1,1,1);
  string.setGeometry(0.1,0.001);
  string.setParams(1,0.4,0.01);
  string.setMassRadius(0.3);
  string.set2DPlane(true);
  string.addBoundaryCondition(Bound.X_LEFT);
  string.addBoundaryCondition(Bound.X_RIGHT);
  string.generate();
  string.translate(-0.1*150, 0, 0);
  
  for(Mass m : string.getMassList()){
    phys.addMassToSubset(m,"masses");
    println(m.getName());
  }
  for(Interaction i : string.getInteractionList())
    phys.addInteractionToSubset(i,"springs");  
    
  
  PhyModel perc = new PhyModel("pluck", med);

  input = perc.addMass("input", new PosInput3D(1, new Vect3D(-30, -30, 0), 100));

  phys.mdl().addPhyModel(string);
  phys.mdl().addPhyModel(perc);
  
  
  d = phys.mdl().addInOut("driver", new Driver3D(), "string/m_10_0_0");

  phys.mdl().addInOut("listener1", new Observer3D(filterType.HIGH_PASS), "string/m_10_0_0");
  phys.mdl().addInOut("listener2", new Observer3D(filterType.HIGH_PASS), "string/m_30_0_0");


  phys.colEngine().addCollision(string, perc, 0.005, 0.001);

  phys.init();

  renderer = new ModelRenderer(this);  
  renderer.setZoomVector(100, 100, 100);  
  renderer.displayMasses(true);  
  renderer.setColor(massType.MASS2DPLANE, 140, 140, 40);
  renderer.setColor(interType.SPRINGDAMPER3D, 135, 70, 70, 255);
  renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 0.1);
  renderer.setStrainColor(interType.SPRINGDAMPER3D, 105, 100, 200, 255);
  
  renderer.displayIntersectionVolumes(true);
  renderer.displayForceVectors(false);
  //renderer.setForceVectorScale(1000);
  
  
  
    //Adjust this to your settings using 
   MidiBus.list();  
  // Knowing that first integer paramater below is the input MIDI device and the second the output MIDI device
  myBus = new MidiBus(this, 0, 1); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
  
  
  // !! The previous param control modifier is currently broken...
  midiCtrls.add(MidiController.addMidiController(phys,1, 0.01, 0.3, "sprd", "stiffness",0.05));
  midiCtrls.add(MidiController.addMidiController(phys,2, 0.0001, 0.1, "sprd", "damping",0.05));
  midiCtrls.add(MidiController.addMidiController(phys,3, 0.5, 1.5, "str", "mass",0.05));
  midiCtrls.add(MidiController.addMidiController(phys,4, 20, 100, "gnd", "distX",0.05));

  midiNotes.add(new midiNote(0, 1, string, "impulse"));
  

  audioStreamHandler = miPhyAudioClient.miPhyClassic(44100, 128, 0, 2, phys);
  audioStreamHandler.setListenerAxis(listenerAxis.Y);
  audioStreamHandler.start();

  cam.setDistance(500);  // distance from looked-at point

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
  input.drivePosition(new Vect3D(x, y, 0.01));

  renderer.renderScene(phys);

  cam.beginHUD();
  stroke(125, 125, 255);
  strokeWeight(2);
  fill(0, 0, 60, 220);
  rect(0, 0, 250, 50);
  textSize(16);
  fill(255, 255, 255);
  text("Curr Audio: " + currAudio, 10, 30);
  cam.endHUD();

  //println(frameRate);
}


void keyPressed(){
  switch(key){
    case 'a':
      phys.setParamForMassSubset("masses", param.MASS, 10);
      break;
    case 'z':
      phys.setParamForInteractionSubset("springs", param.STIFFNESS, 0.3);
      break;
    default:
      phys.setParamForMassSubset("masses", param.MASS, 1);
      phys.setParamForInteractionSubset("springs", param.STIFFNESS, 0.4);
      break;
  }
}


void controllerChange(int channel, int number, int value) {
  println("controller : " + channel + " " + number + " " + value);
  synchronized(phys.getLock())
  {
    if(number == 74)
      phys.setParamForMassSubset("masses", param.MASS, value+1);
    /*
    for (MidiController mc : midiCtrls)
    {
      mc.changeParam(number, value);
    }
    */
  }
}

void noteOn(int channel, int pitch, int velocity) {
  synchronized(phys.getLock())
  {
  for (midiNote mn : midiNotes)
  {
    mn.on(pitch, velocity);
  }
  }
}

void noteOff(int channel,int pitch,int velocity)
{
  synchronized(phys.getLock())
  {
  for (midiNote mn : midiNotes)
  {
    mn.off(pitch, velocity);
  }
  }
}
