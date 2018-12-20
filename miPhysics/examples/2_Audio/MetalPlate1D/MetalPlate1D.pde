
import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;

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


///////////////////////////////////////

void setup()
{
  //size(1000, 700, P3D);
  fullScreen(P3D,2);
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

}

void draw()
{
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2, height/2.0, 0, 0, 1, 0);

  //mdl.draw_physics();

  background(0);

  pushMatrix();
  translate(xOffset,yOffset, 0.);
  renderLinks(simUGen.mdl);
  popMatrix();

  fill(255);
  textSize(13); 

  text("Friction: " + fric, 50, 50, 50);
  text("Zoom: " + zZoom, 50, 100, 50);

  
  if (mouseDragged == 1){
    if((mouseX) < (dimX*gridSpacing+xOffset) & (mouseY) < (dimY*gridSpacing+yOffset) & mouseX>xOffset & mouseY > yOffset){ // Garde fou pour ne pas sortir des limites du pinScreen
      println(mouseX, mouseY);
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
  String matName = "osc" + floor(random(dimX))+"_"+ floor(random(dimY));
  simUGen.mdl.triggerForceImpulse(matName, random(100) , random(100), random(500));
}

void engrave(float mX, float mY){
  String matName = "osc" + floor(mX/ gridSpacing)+"_"+floor(mY/ gridSpacing);
  println(simUGen.mdl.matExists(matName));
  if(simUGen.mdl.matExists(matName))
    simUGen.mdl.triggerForceImpulse(matName, 0. , 0., 15.);
}

void chisel(float mX, float mY){
  String matName = "osc" + floor(mX/ gridSpacing)+"_"+floor(mY/ gridSpacing);
  println(simUGen.mdl.matExists(matName));
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