/**
 **********************************************************************************************************************
 */

import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;
import processing.serial.*;
import static java.util.concurrent.TimeUnit.*;
import java.util.concurrent.*;

Minim minim;
PhyUGen simUGen;
Gain gain;

AudioOutput out;
AudioRecorder recorder;

private Object lock = new Object();

float currAudio = 0;
float gainVal = 1.;

PeasyCam cam;




/* scheduler definition ************************************************************************************************/
private final ScheduledExecutorService scheduler      = Executors.newScheduledThreadPool(1);


/* device block definitions ********************************************************************************************/
Board             haplyBoard;
Device            widgetOne;
Mechanisms        pantograph;

byte              widgetOneID                         = 5;
int               CW                                  = 0;
int               CCW                                 = 1;
/* end device block definition *****************************************************************************************/


/* Visual frame rate */
long baseFrameRate = 60;

/* Rate of the haptic simulation thread */
int hapticRate = 1000;


/* data for a 2DOF device */
/* joint space */
PVector           angles                              = new PVector(0, 0);
PVector           torques                             = new PVector(0, 0);

/* task space */
PVector           posEE                               = new PVector(0, 0);
PVector           fEE                                 = new PVector(0, 0);

PVector tmp = new PVector(0, 0);
Vect3D frcOut = new Vect3D(0, 0, 0);

/* Position and force calibration/scaling gains */
float            alpha                                = 200;
float            beta                                 = 0.3;

/* Device position offset */
float offset_x = 0;
float offset_y = -10;

long start = 0;
long end = 0;
long elapsed = 0;
int stepsMissed = 0;

long microtimeRate = 0;

/* setup section *******************************************************************************************************/
void setup() {
  /* put setup code here, run once: */

  /* screen size definition */
  size(1000, 700, P3D);
  

  /* device setup */
  haplyBoard          = new Board(this, Serial.list()[0], 0); 
  pantograph          = new Pantograph();
  widgetOne           = new Device(widgetOneID, haplyBoard);

  widgetOne.set_mechanism(pantograph);

  widgetOne.add_actuator(1, CW, 1);
  widgetOne.add_actuator(2, CW, 2);

  widgetOne.add_encoder(1, CW, 180, 13824, 1);
  widgetOne.add_encoder(2, CW, 0, 13824, 2);

  widgetOne.device_set_parameters();

  /* visual elements setup */
  background(0);
  
  /* setup framerate speed */
  frameRate(baseFrameRate);

  microtimeRate = (long) 1000000. / hapticRate;
 
  cam = new PeasyCam(this, 200);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(250000);

  minim = new Minim(this);
  out = minim.getLineOut();
  gain = new Gain(0);

  simUGen = new PhyUGen(44100);
  simUGen.patch(gain).patch(out);
  
  createShapeArray(simUGen.mdl);

  /* setup simulation thread to run at 1kHz */
  SimulationThread st = new SimulationThread();
  scheduler.scheduleAtFixedRate(st, microtimeRate, microtimeRate, MICROSECONDS);

  end = System.nanoTime();
  start = System.nanoTime();
}


/* draw section ********************************************************************************************************/
void draw() {
    
  /* put graphical code here, runs repeatedly at defined framerate in setup, else default at 60fps: */
  background(255);
  
  directionalLight(126, 126, 126, 100, 0, -1);
  ambientLight(182, 182, 182);

  renderModelShapes(simUGen.mdl);
  

  cam.beginHUD();
  stroke(125,125,255);
  strokeWeight(2);
  fill(0,0,60, 220);
  rect(0,0, 250, 100);
  textSize(16);
  fill(255, 255, 255);
  text("Steps Missed: " + stepsMissed, 10, 20);
  text("Pos: " + String.format("%4.2e",posEE.x) + ", " + String.format("%4.2e",posEE.y) , 10, 40);
  text("Frc: " + String.format("%4.2e",fEE.x) + ", " + String.format("%4.2e",fEE.y) , 10, 60);
  text("Curr Audio: " + currAudio, 10, 80);
  cam.endHUD();

}


void stop() {
  fEE.x = 0;
  fEE.y = 0;
  torques.set(widgetOne.set_device_torques(fEE.array()));
  widgetOne.device_write_torques();
} 



void keyPressed() {
  if (key =='o') {
    offset_x = -posEE.x;
    offset_y = -posEE.y;
  }

  if (keyCode == LEFT) {
  }
}
