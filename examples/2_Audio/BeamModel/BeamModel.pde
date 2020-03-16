
import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;

int baseFrameRate = 60;

int mouseDragged = 0;

int gridSpacing = 2;
int xOffset= 0;
int yOffset= 0;

ModelRenderer renderer;

float currAudio = 0;
float gainVal = 1.;

PeasyCam cam;

float percsize = 200;

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
  fullScreen(P3D,2);
  
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(500000);
  
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
  
  renderer = new ModelRenderer(this);
  
  renderer.displayMasses(true);
  renderer.setSize(massType.MASS3D, 1);
  renderer.setColor(massType.MASS3D, 50, 255, 200);
  renderer.setColor(massType.GROUND3D, 120, 200, 100);
  renderer.setColor(interType.SPRINGDAMPER3D, 135, 70, 70, 255);
  renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 0.5);
  renderer.setStrainColor(interType.SPRINGDAMPER3D, 105, 100, 200, 255);

    
  cam.setDistance(500);  // distance from looked-at point
  
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

void keyPressed() {
    if (key =='a'){
      forcePeak = 0.1;
      triggerForceRamp = true;
    }
    if (key =='z'){
      forcePeak = 0.5;
      triggerForceRamp = true;
    }
    if (key =='e'){
      forcePeak = 1;
      triggerForceRamp = true;
    }
    if (key =='r'){
      forcePeak = 2;
      triggerForceRamp = true;
    }
    if (key =='t'){
      forcePeak = 3;
      triggerForceRamp = true;
    }
  
}
