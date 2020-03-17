
import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;

import miPhysics.ModelRenderer.*;

int displayRate = 60;

int mouseDragged = 0;

int gridSpacing = 2;
int xOffset= 0;
int yOffset= 0;

int zZoom = 1;

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

  minim = new Minim(this);

  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut();

  recorder = minim.createRecorder(out, "myrecording.wav");

  // start the Gain at 0 dB, which means no change in amplitude
  gain = new Gain(0);

  simUGen = new PhyUGen(44100);
  simUGen.patch(gain).patch(out);

  renderer = new ModelRenderer(this);
  renderer.displayMasses(false);
  renderer.setColor(interType.SPRINGDAMPER1D, 155, 50, 50, 170);
  renderer.setStrainGradient(interType.SPRINGDAMPER1D, true, 1);
  renderer.setStrainColor(interType.SPRINGDAMPER1D, 255, 250, 255, 255);


  cam.setDistance(500);  // distance from looked-at point
}

void draw()
{
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2, height/2.0, 0, 0, 1, 0);

  background(0);

  renderer.setZoomVector(1, 1, 0.1 * zZoom);

  pushMatrix();
  translate(xOffset, yOffset, 0.);
  renderer.renderModel(simUGen.mdl);
  popMatrix();

  fill(255);
  textSize(13); 
  text("Friction: " + fric, 50, 50, 50);
  text("Zoom: " + zZoom, 50, 100, 50);

  if (mouseDragged == 1) {
    if ((mouseX) < (dimX*gridSpacing+xOffset) & (mouseY) < (dimY*gridSpacing+yOffset) & mouseX>xOffset & mouseY > yOffset) { // Garde fou pour ne pas sortir des limites du pinScreen
      println(mouseX, mouseY);
      if (mouseButton == LEFT)
        engrave(mouseX-xOffset, mouseY - yOffset);
      if (mouseButton == RIGHT)
        chisel(mouseX-xOffset, mouseY - yOffset);
    }
  }

  if ( recorder.isRecording() )
  {
    text("Currently recording...", 5, 15);
  } else
  {
    text("Not recording.", 5, 15);
  }
}


void engrave(float mX, float mY) {
  String matName = "osc" + floor(mX/ gridSpacing)+"_"+floor(mY/ gridSpacing);
  Mass m = simUGen.mdl.getMass(matName);
  if (m != null) {
    simUGen.d.moveDriver(m);
    simUGen.d.applyFrc(new Vect3D(0., 0., 15.));
  }
}

void chisel(float mX, float mY) {
  String matName = "osc" + floor(mX/ gridSpacing)+"_"+floor(mY/ gridSpacing);
  Mass m = simUGen.mdl.getMass(matName);
  if (m != null) {
    simUGen.mdl.removeMassAndConnectedInteractions(m);
  }
}


void mouseDragged() {
  mouseDragged = 1;
}

void mouseReleased() {
  mouseDragged = 0;
}



void keyPressed() {

  if (keyCode == UP) {
    fric += 0.001;
    simUGen.mdl.setGlobalFriction(0.);
    println(fric);
  } else if (keyCode == DOWN) {
    fric -= 0.001;
    fric = max((float)fric, 0.);
    simUGen.mdl.setGlobalFriction(fric);
    println(fric);
  } else if (keyCode == LEFT) {
    zZoom ++;
  } else if (keyCode == RIGHT) {
    zZoom --;
  }
}
