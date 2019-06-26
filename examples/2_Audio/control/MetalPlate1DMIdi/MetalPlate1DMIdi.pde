
import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;
import themidibus.*; //Import the library
import miPhysics.*;

MidiBus myBus; // The MidiBus
int displayRate = 60;

int mouseDragged = 0;

int gridSpacing = 2;
int xOffset= 0;
int yOffset= 0;

private Object lock = new Object();


PeasyCam cam;

float percsize = 200;

Minim minim;
PhyUGen simUGen;
Gain gain;

AudioOutput out;
AudioRecorder recorder;


float gainVal = 1.;

float speed = 0;
float pos = 100;

ArrayList<MidiControler> midiCtrls = new ArrayList<MidiControler>();
ArrayList<midiNote> midiNotes = new ArrayList<midiNote>();
///////////////////////////////////////

void setup()
{
  size(1000, 700, P3D);
  //fullScreen(P3D,2);
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
  
  //simUGen.mdl.triggerForceImpulse("mass"+(excitationPoint), 0, 1, 0);
  cam.setDistance(500);  // distance from looked-at point

//Adjust this to your settings using 
   MidiBus.list();  
  // Knowing that first integer paramater below is the input MIDI device and the second the output MIDI device
  myBus = new MidiBus(this, 0, 1); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.


  midiCtrls.add(MidiControler.addMidiControler(simUGen.mdl,1, 0.01, 0.3, "spring", "stiffness"));
  midiCtrls.add(MidiControler.addMidiControler(simUGen.mdl,2, 0.0001, 0.1, "spring", "damping"));
  midiCtrls.add(MidiControler.addMidiControler(simUGen.mdl,3, 0.01, 0.3, "osc", "stiffness",0.5));
  midiCtrls.add(MidiControler.addMidiControler(simUGen.mdl,4, 0.0001, 0.1, "osc", "damping",0.5));
  
 // midiNotes.add(new midiNote(0.01, 0.9, "str",0,simUGen.nbmass -1,"Y"));
}

void draw()
{
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2, height/2.0, 0, 0, 1, 0); //<>//

  //mdl.draw_physics();

  background(0);

  pushMatrix();
  translate(xOffset,yOffset, 0.);
  renderLinks(simUGen.mdl);
  popMatrix();

  fill(255);
  textSize(13); 

  text("Friction: " + fric, 50, 50, 50);
//  text("Zoom: " + zZoom, 50, 100, 50);
  text("spring stiffness: " + simUGen.mdl.getParamValueOfSubset("spring","stiffness"),10,50);
  text("spring damping: " + simUGen.mdl.getParamValueOfSubset("spring","damping"),10,70);
  text("osc stiffness: " + simUGen.mdl.getParamValueOfSubset("osc","stiffness"),10,90);
  text("osc damping: " + simUGen.mdl.getParamValueOfSubset("osc","damping"),10,110);
  
  if (mouseDragged == 1){
    if((mouseX) < (simUGen.dimX*gridSpacing+xOffset) & (mouseY) < (simUGen.dimY*gridSpacing+yOffset) & mouseX>xOffset & mouseY > yOffset){ // Garde fou pour ne pas sortir des limites du pinScreen
      //println(mouseX, mouseY);
      if(mouseButton == LEFT)
        engrave(mouseX-xOffset, mouseY - yOffset);
      if(mouseButton == RIGHT)
        chisel(mouseX-xOffset, mouseY - yOffset);
    }
  }
  
  if ( recorder.isRecording() )
  {
    text("Currently recording...", 5, 15);
  }
  else
  {
    text("Not recording.", 5, 15);
  }

}



void fExt(){
  String matName = "osc" + floor(random(simUGen.dimX))+"_"+ floor(random(simUGen.dimY));
  simUGen.mdl.triggerForceImpulse(matName, random(100) , random(100), random(500));
}

void engrave(float mX, float mY){
  String matName = "osc" + floor(mX/ gridSpacing)+"_"+floor(mY/ gridSpacing);
  //println(simUGen.mdl.matExists(matName));
  if(simUGen.mdl.matExists(matName))
    simUGen.mdl.triggerForceImpulse(matName, 0. , 0., 15.);
}

void chisel(float mX, float mY){
  String matName = "osc" + floor(mX/ gridSpacing)+"_"+floor(mY/ gridSpacing);
 // println(simUGen.mdl.matExists(matName));
  synchronized(lock){
  if(simUGen.mdl.matExists(matName))
    simUGen.mdl.removeMatAndConnectedLinks(matName);
  }
}


void mouseDragged() {
  mouseDragged = 1;
  
}

void mouseReleased() {
  mouseDragged = 0;
}



void keyPressed() {
  if (key == ' ')
  simUGen.mdl.setGravity(-0.001);
  if(keyCode == UP){
    fric += 0.001;
    synchronized(lock){
      simUGen.mdl.setFriction(0.);
    }
    println(fric);

  }
  else if (keyCode == DOWN){
    fric -= 0.001;
    fric = max(fric, 0);
    simUGen.mdl.setFriction(fric);
    println(fric);
  }
  else if (keyCode == LEFT){
    zZoom ++;
  }
  else if (keyCode == RIGHT){
    zZoom --;
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
