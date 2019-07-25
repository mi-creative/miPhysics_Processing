
 
import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;
import controlP5.*;

PeasyCam cam;
ControlP5 cp5;
ModelRenderer renderer;
Minim minim;
PhyUGen simUGen;
Gain gain;
AudioOutput out;
AudioInput in;
AudioRecorder recorder;

int baseFrameRate = 60;

boolean wIsPressed;

int gridSpacing = 2;
int xOffset= 0;
int yOffset= 0;

float currAudio = 0;
float gainVal = 1.;

float percsize = 200;

float speed = 0;
float pos = 100;

float Ctrl_damping, Ctrl_friction, Ctrl_stiffness, Ctrl_outGain, Ctrl_inGain, Ctrl_attack;
float excitingX, excitingY, excitingZ;
float listeningX, listeningY, listeningZ;

boolean toggleInput = false;
boolean toggleOutput = false;

int excitationPoint;
int listeningPoint;

float twistTarget = 0;

///////////////////////////////////////

void setup()
{
  //fullScreen(P3D,2);
  size(1000, 700, P3D);

  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(500000);
  
  minim = new Minim(this);

  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut(minim.STEREO, 512, 44100);  
  in = minim.getLineIn(Minim.MONO,64,44100);

  //recorder = minim.createRecorder(out, "myrecording.wav");
  
  // start the Gain at 0 dB, which means no change in amplitude
  gain = new Gain(0);
  
  // create a physicalModel UGEN
  simUGen = new PhyUGen(44100);
  
  // patch the Oscil to the output
  simUGen.patch(gain).patch(out);
  
  renderer = new ModelRenderer(this);
  
  renderer.displayMats(true);
  renderer.setSize(matModuleType.Mass3D, 1);
  renderer.setColor(matModuleType.Mass3D, 50, 255, 200);
  renderer.setSize(matModuleType.Ground3D, 3);
  renderer.setColor(matModuleType.Ground3D, 120, 200, 100);
  renderer.setColor(linkModuleType.SpringDamper3D, 135, 70, 70, 255);
  renderer.setStrainGradient(linkModuleType.SpringDamper3D, true, 0.5);
  renderer.setStrainColor(linkModuleType.SpringDamper3D, 105, 100, 200, 255);
    
  cam.setDistance(500);  // distance from looked-at point
  
  frameRate(baseFrameRate);
  
  // Interface elements for quick parametric exploration
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);

  cp5.addSlider("Ctrl_damping").setPosition(20,20).setRange(0.00001, 0.01);
  cp5.addSlider("Ctrl_friction").setPosition(20,40).setRange(0.000001, 0.001);
  cp5.addSlider("Ctrl_stiffness").setPosition(20,60).setRange(0.0000001, 0.2);
  cp5.addSlider("Ctrl_attack").setPosition(20,100).setRange(0, 1.);
  
  ButtonBar b = cp5.addButtonBar("preset")
     .setPosition(0, 120)
     .setSize(200, 20)
     .addItems(split("a b c d e"," "));
  b.changeItem("a","text","default");
  b.changeItem("b","text","p1");
  b.changeItem("c","text","p2");
  b.changeItem("d","text","p3");
  b.changeItem("e","text","p4");
  
  cp5.addToggle("toggleInput")
     .setPosition(230,20)
     .setSize(10,10)
     .setLabel("Input (mic)")
     .setLabelVisible(true);
   cp5.addSlider("Ctrl_inGain").setPosition(245,20).setRange(0, 1.).setLabel("Input Gain");
 
   cp5.addToggle("toggleOutput")
     .setPosition(230,54)
     .setSize(10,10)
     .setLabel("Output")
     .setLabelVisible(true);
   cp5.addSlider("Ctrl_outGain").setPosition(245,54).setRange(0, 1.).setLabel("Output Gain");

   cp5.addSlider("excitationPoint")
   .setPosition(420,20)
   .setWidth(150)
   .setRange(1,dimX-2) // values can range from big to small as well
   .setValue(3)
   //.setNumberOfTickMarks(dimX-2)
   .setSliderMode(Slider.FLEXIBLE)
   ;
   
  //listeningPoint = dimX/2;azerttyyy
  cp5.addSlider("listeningPoint")
   .setPosition(420,40)
   .setWidth(150)
   .setRange(1,dimX-2) // values can range from big to small as well
   .setValue(dimX-2-3)
   //.setNumberOfTickMarks(dimX-2)
   .setSliderMode(Slider.FLEXIBLE)
   ;
   
   
    cp5.addSlider("excitingX").setPosition(660,20).setRange(0., 1.).setWidth(50).setValue(.8);
    cp5.addSlider("excitingY").setPosition(660,40).setRange(0., 1.).setWidth(50).setValue(.8);
    cp5.addSlider("excitingZ").setPosition(660,60).setRange(0., 1.).setWidth(50).setValue(.8);

    cp5.addSlider("listeningX").setPosition(800,20).setRange(0., 1.).setWidth(50).setValue(.8);
    cp5.addSlider("listeningY").setPosition(800,40).setRange(0., 1.).setWidth(50).setValue(.8);
    cp5.addSlider("listeningZ").setPosition(800,60).setRange(0., 1.).setWidth(50).setValue(.8);
  
  preset(0);
}

void draw()
{
  background(0,0,25);
  directionalLight(126, 126, 126, 100, 0, -1);
  ambientLight(182, 182, 182);

  renderer.renderModel(simUGen.mdl);
  
  cam.beginHUD();
  
  fill(100);
  rect(0,0,200,140);
  cp5.draw();
  
  cam.endHUD();
  
  simUGen.mdl.changeDampingParamOfSubset(Ctrl_damping,"stretchingFactor");
  simUGen.mdl.changeDampingParamOfSubset(Ctrl_damping,"myBeam");
  simUGen.mdl.setFriction(Ctrl_friction);
  simUGen.mdl.changeStiffnessParamOfSubset(Ctrl_stiffness,"myBeam");
  
  cam.setActive(wIsPressed);

}

void keyPressed() {
  // Series of various attack interaction
    if (key =='a'){
      frcRate = 1;
      forcePeak = 0.1*Ctrl_attack;
      triggerForceRamp = true;
    }
    if (key =='z'){
      frcRate = 1;
      forcePeak = 0.5*Ctrl_attack;
      triggerForceRamp = true;
    }
    if (key =='e'){
      frcRate = 1;
      forcePeak = 1*Ctrl_attack;
      triggerForceRamp = true;
    }
    if (key =='r'){
      frcRate = 1;
      forcePeak = 2*Ctrl_attack;
      triggerForceRamp = true;
    }
    if (key =='t'){
      frcRate = 1;
      forcePeak = 6*Ctrl_attack;
      triggerForceRamp = true;
    }
    if (key =='y'){
      frcRate = 0.01;
      forcePeak = 6*Ctrl_attack;
      triggerForceRamp = true;
    }
    // hold that key for horizontal stretching activation (control with horizontal mouse movement)
    if (key =='q'){
      lenghtStrech = true;
    }
    // hold that key for vertical homothetic stretching activation (control with vertical mouse movement)
    if (key =='s'){
      sectionStrech = true;
    }
    // hold that key for beam twisting activation (control with vertical mouse movement)
    if (key =='d'){
      twist = true;
    }
    // hold that key for camera control activation (unfreeze peasyCam standard control)
    if (key =='w') {
      wIsPressed = true;
    }    
}


void keyReleased() {
  if (key =='q'){
    lenghtStrech = false;
  }
  if (key =='s'){
    sectionStrech = false;
  }
  if (key =='d'){
    twist = false;
  }
  if (key =='w') {
      wIsPressed = false;
    }
}

void mouseMoved(){
    if(lenghtStrech){
      for (int k = 0; k < groundsL.size(); k++) {
        simUGen.mdl.setMatPosition(groundsL.get(k), new Vect3D(simUGen.mdl.getMatPosition(groundsL.get(k)).x+(mouseX-pmouseX)/10., simUGen.mdl.getMatPosition(groundsL.get(k)).y, simUGen.mdl.getMatPosition(groundsL.get(k)).z));
        simUGen.mdl.setMatPosition(groundsR.get(k), new Vect3D(simUGen.mdl.getMatPosition(groundsR.get(k)).x-(mouseX-pmouseX)/10., simUGen.mdl.getMatPosition(groundsR.get(k)).y, simUGen.mdl.getMatPosition(groundsR.get(k)).z));
      }
    }
    
    if(sectionStrech){
      for (int k = 0; k < groundsL.size(); k++) {
         simUGen.mdl.setMatPosition(groundsL.get(k), new Vect3D(simUGen.mdl.getMatPosition(groundsL.get(k)).x, simUGen.mdl.getMatPosition(groundsL.get(k)).y*(1+(mouseY-pmouseY)/100.), simUGen.mdl.getMatPosition(groundsL.get(k)).z));
         simUGen.mdl.setMatPosition(groundsL.get(k), new Vect3D(simUGen.mdl.getMatPosition(groundsL.get(k)).x, simUGen.mdl.getMatPosition(groundsL.get(k)).y, simUGen.mdl.getMatPosition(groundsL.get(k)).z*(1+(mouseY-pmouseY)/100.)));
         simUGen.mdl.setMatPosition(groundsR.get(k), new Vect3D(simUGen.mdl.getMatPosition(groundsR.get(k)).x, simUGen.mdl.getMatPosition(groundsR.get(k)).y*(1+(mouseY-pmouseY)/100.), simUGen.mdl.getMatPosition(groundsR.get(k)).z));
         simUGen.mdl.setMatPosition(groundsR.get(k), new Vect3D(simUGen.mdl.getMatPosition(groundsR.get(k)).x, simUGen.mdl.getMatPosition(groundsR.get(k)).y, simUGen.mdl.getMatPosition(groundsR.get(k)).z*(1+(mouseY-pmouseY)/100.)));
      }
    }

    if(twist){
      for (int k = 0; k < groundsL.size(); k++) {
        simUGen.mdl.setMatPosition(groundsL.get(k), new Vect3D(simUGen.mdl.getMatPosition(groundsL.get(k)).x, 
                               (cos((mouseY-pmouseY)/100.)*(simUGen.mdl.getMatPosition(groundsL.get(k)).y - (dist*(dimY-1))/2.) - sin((mouseY-pmouseY)/100.)*(simUGen.mdl.getMatPosition(groundsL.get(k)).z - (dist*(dimZ-1))/2.) + (dist*(dimY-1))/2.), 
                               (sin((mouseY-pmouseY)/100.)*(simUGen.mdl.getMatPosition(groundsL.get(k)).y - (dist*(dimY-1))/2.) + cos((mouseY-pmouseY)/100.)*(simUGen.mdl.getMatPosition(groundsL.get(k)).z - (dist*(dimZ-1))/2.) + (dist*(dimZ-1))/2.)));
      }
    }
    
}

void excitationPoint(int excitationPoint){
  excitationPoint+=1;
  massToExcite = "mass" + excitationPoint;
  println(massToExcite);
}

void listeningPoint(int listeningPoint){
  listeningPoint+=1;
  massToListenTo = "mass" + listeningPoint;
  println(massToListenTo);
}


// PRESETS
void preset(int n) {
  println("bar clicked, item-value:", n);
  if (n == 0){
    cp5.getController("Ctrl_damping").setValue(0.00001);
    cp5.getController("Ctrl_friction").setValue(0.0001);
    cp5.getController("Ctrl_stiffness").setValue(0.04);
    cp5.getController("Ctrl_outGain").setValue(0.1);
    cp5.getController("Ctrl_inGain").setValue(0.1);
    cp5.getController("Ctrl_attack").setValue(1.0);
    updateModelParam();
  }
}

void updateModelParam(){
  println("MaJ Param");
  simUGen.mdl.changeDampingParamOfSubset(Ctrl_damping,"myBeam");
  simUGen.mdl.setFriction(Ctrl_friction);
  simUGen.mdl.changeStiffnessParamOfSubset(Ctrl_stiffness,"myBeam");
}
