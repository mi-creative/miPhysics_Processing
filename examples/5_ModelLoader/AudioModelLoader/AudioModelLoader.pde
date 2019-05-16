import peasy.*;
import miPhysics.*;


import ddf.minim.*;
import ddf.minim.ugens.*;

int displayRate = 50;
boolean BASIC_VISU = false;
String fileName=null;

Minim minim;
PhyUGen simUGen;
Gain gain;
AudioOutput out;

PeasyCam cam;
ModelRenderer renderer;
ModelLoader loader;

void setup() {

  size(1000, 700, P3D);

  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);
  cam.rotateX(radians(-80));
  
  cam.setDistance(750);

  background(0);

  renderer = new ModelRenderer(this);
  loader = new ModelLoader(this);
  
   minim = new Minim(this);
  
  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut();
    
    // start the Gain at 0 dB, which means no change in amplitude
  gain = new Gain(0);
  
  // create a physicalModel UGEN
  simUGen = new PhyUGen(44100);
  
  // patch the Oscil to the output
  simUGen.patch(gain).patch(out);
  
 // loader.loadModel("/Users/Remi/Desktop/data/BeamModel.xml",mdl);
  
  
  
  if (BASIC_VISU){
    renderer.displayMats(false);
    renderer.setColor(linkModuleType.SpringDamper3D, 155, 200, 200, 255);
    renderer.setSize(linkModuleType.SpringDamper3D, 1);
  }
  else{
    renderer.displayMats(false);
    renderer.setColor(linkModuleType.SpringDamper3D, 0, 50, 255, 255);
    renderer.setSize(linkModuleType.SpringDamper3D, 1);
    renderer.setStrainGradient(linkModuleType.SpringDamper3D, true, 0.02);
    renderer.setStrainColor(linkModuleType.SpringDamper3D, 150, 150, 255, 255);
  }
  
  frameRate(displayRate);

} 

void draw() {
  
  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);

  background(0);

  renderer.renderModel(simUGen.mdl);
  
}


void load(File selection){
  if (selection==null){
    println("No file was selected");
  }
  else{
    fileName=selection.getAbsolutePath();
    println(fileName);
    synchronized(simUGen.mdl.getLock()){
      loader.loadModel(fileName, simUGen.mdl);
    }
  }
}


void keyPressed(){
 if(key == 'a')
    simUGen.mdl.triggerForceImpulse(30,10,10,0);
}


void save(File selection){
  if (selection==null){
    println("No file was selected");
  }
  else{
        synchronized(simUGen.mdl.getLock()){
          fileName=selection.getAbsolutePath();
          loader.saveModel(fileName, simUGen.mdl);
        }
  }
}
