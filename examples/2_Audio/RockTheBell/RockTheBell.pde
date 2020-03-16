
import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;

int baseFrameRate = 60;

int mouseDragged = 0;

int gridSpacing = 2;
int xOffset= 0;
int yOffset= 0;

float currAudio = 0;
float gainVal = 1.;

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
  fullScreen(P3D, 2);

  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);
  cam.rotateX(radians(-90));
  cam.setDistance(700);

  minim = new Minim(this);

  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut(Minim.MONO, 2048);

  recorder = minim.createRecorder(out, "myrecording.wav");

  // start the Gain at 0 dB, which means no change in amplitude
  gain = new Gain(0);

  simUGen = new PhyUGen(44100);
  simUGen.patch(gain).patch(out);

  renderer = new ModelRenderer(this);

  renderer.setZoomVector(1, 1, 1);

  renderer.displayMasses(true);
  renderer.setColor(massType.MASS3D, 80, 100, 255);

  renderer.setColor(interType.SPRINGDAMPER3D, 80, 100, 255, 170);
  renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 0.1);
  renderer.setStrainColor(interType.SPRINGDAMPER3D, 255, 250, 255, 255);


  frameRate(baseFrameRate);
}

void draw()
{
  background(255, 255, 255);

  directionalLight(126, 126, 126, 100, 0, -1);
  ambientLight(182, 182, 182);

  renderer.renderModel(simUGen.mdl);

  cam.beginHUD();
  stroke(125, 125, 255);
  strokeWeight(2);
  fill(0, 0, 60, 220);
  rect(0, 0, 250, 50);
  textSize(16);
  fill(255, 255, 255);
  text("Curr Audio: " + currAudio, 10, 30);
  cam.endHUD();
}


void keyPressed() {
  if (key == ' ') {
    simUGen.driver.applyFrc(new Vect3D(0, -1, 0));
  }
  if (key == 'a') {
    for (Driver3D d : simUGen.mdl.getDrivers())
      d.applyFrc(new Vect3D(0, 0.1, 0));
  }
}
