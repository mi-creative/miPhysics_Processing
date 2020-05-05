/* 
  WARNING : Haptic models haven't been ported to the new API yet
  this model won't currently build 
  */

/*  LIB imports */
import miPhysics.*;

import processing.serial.*;
import static java.util.concurrent.TimeUnit.*;
import java.util.concurrent.*;

import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;
import peasy.*;

/* End of LIB imports */

PhysicalModel mdl = new PhysicalModel(1000);

PeasyCam cam;

Ellipsoid earth;
ArrayList<Ellipsoid> massShapes = new ArrayList<Ellipsoid>();


/* scheduler definition ************************************************************************************************/ 
private final ScheduledExecutorService scheduler      = Executors.newScheduledThreadPool(1);
/* end scheduler definition ********************************************************************************************/  

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

PVector tmp = new PVector(0,0);
Vect3D frcOut = new Vect3D(0,0,0);


/* Position and force calibration/scaling gains */
float            alpha                                = 200;
float            beta                                 = 60;

/* Device position offset */
float offset_x = 0;
float offset_y = -10;


long start = 0;
long end = 0;
long elapsed = 0;
int stepsMissed = 0;
long microtimeRate = 0;


/* setup section *******************************************************************************************************/
void setup(){
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
  
  /* Build model and visualisation */
  int nbMass = 200;
  
  mdl.setGravity(0.00005);
  mdl.setFriction(0.001);
  
  mdl.addHapticInput3D("hapticMass", new Vect3D(0,0,0), 10);
  addShape(new PVector(0,0,0),"moon.jpg", 0.35*100);
  
  for(int i = 0; i < nbMass ; i++){
    Vect3D vec = new Vect3D(random(-1.,1),random(-1.,1),random(-1.,1));
    mdl.addMass3D("mass"+i, 7+random(3.), vec, new Vect3D(0.0,0.0,0));
    addShape(vec.toPVector(),"earth.jpg", 0.1*100);
  }
  
  mdl.addGround3D("gnd", new Vect3D(0.,0.,1.));
  
  Ellipsoid tmp = new Ellipsoid(this, 32, 32);
  tmp.setRadius(3*100);
  tmp.moveTo(new PVector(0, 0, 1));
  //tmp.strokeWeight(0);
  tmp.fill(color(32, 32, 200,10));
  tmp.tag = "";
  tmp.drawMode(Shape3D.TEXTURE);
  
  massShapes.add(tmp);
  
  for(int i = 0; i < nbMass ; i++){
    mdl.addBubble3D("bub"+i, 3., 0.1, 0.1, "gnd", "mass"+i);
    mdl.addPlaneContact("plane"+i, 0, 0.01, 0.01, 2, 0, "mass"+i);
    for(int j = 0; j < nbMass; j++){
      if(i != j)
        mdl.addContact3D("cont"+i+"_"+j, 0.2, 0.02, 0.01, "mass"+j, "mass"+i);
    }    
  }
  
  for(int i = 0; i < nbMass ; i++){
    mdl.addContact3D("cont_hap"+i, 0.5, 0.02, 0.01, "hapticMass", "mass"+i);
  }
  mdl.addBubble3D("bubh", 4., 0.01, 0.01, "gnd", "hapticMass");
  
  
  frcOut = new Vect3D();
  mdl.init();
  
  /* visual elements setup */
  background(0);   
  
  /* setup framerate speed */
  frameRate(baseFrameRate);
  
  microtimeRate = (long) 1000000. / hapticRate;
  
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);
  
  /* setup simulation thread to run at 1kHz */ 
  SimulationThread st = new SimulationThread();
  scheduler.scheduleAtFixedRate(st, microtimeRate, microtimeRate, MICROSECONDS);
  
  end = System.nanoTime();
  start = System.nanoTime();
}



void draw(){
  /* put graphical code here, runs repeatedly at defined framerate in setup, else default at 60fps: */
  background(255);
  
  
  for (Ellipsoid massShape : massShapes)
    massShape.draw();
    
  hint(DISABLE_DEPTH_TEST);
  drawPlane(2, 0, 300);
  renderShapes(mdl);
  hint(ENABLE_DEPTH_TEST);
  
  cam.beginHUD();
  stroke(125,125,255);
  strokeWeight(2);
  fill(0,0,60, 220);
  rect(0,0, 250, 80);
  textSize(16);
  fill(255, 255, 255);
  text("Steps Missed: " + stepsMissed, 10, 20);
  text("Pos: " + String.format("%4.2e",posEE.x) + ", " + String.format("%4.2e",posEE.y) , 10, 40);
  text("Frc: " + String.format("%4.2e",fEE.x) + ", " + String.format("%4.2e",fEE.y) , 10, 60);
  cam.endHUD();

}


void stop() {
  fEE.x = 0;
  fEE.y = 0;
  torques.set(widgetOne.set_device_torques(fEE.array()));
  widgetOne.device_write_torques();
} 


/* Drawing & Utility functions */

void addShape(PVector pos, String texture, float size){
      Ellipsoid tmp = new Ellipsoid(this, 20, 20);
      tmp.setTexture(texture);
      tmp.setRadius(size);
      tmp.moveTo(pos.x, pos.y, pos.z);
      tmp.strokeWeight(0);
      tmp.fill(color(32, 32, 200,100));
      tmp.tag = "";
      tmp.drawMode(Shape3D.TEXTURE);
      massShapes.add(tmp);
}


void renderShapes(PhysicalModel mdl){
  PVector v;
    for( int i = 0; i < mdl.getNumberOfMats(); i++){
        v = mdl.getMatPosAt(i).toPVector().mult(100.);
        massShapes.get(i).moveTo(v.x, v.y, v.z); 
        massShapes.get(i).rotateBy(radians(3f), radians(6f), random(radians(3f)));
  }
}

void drawPlane(int orientation, float position, float size){
  stroke(255);
  fill(127, 30);
  
  beginShape();
  if(orientation ==2){
    vertex(-size, -size, position);
    vertex( size, -size, position);
    vertex( size, size, position);
    vertex(-size, size, position);
  } else if (orientation == 1) {
    vertex(-size,position, -size);
    vertex( size,position, -size);
    vertex( size,position, size);
    vertex(-size,position, size);  
  } else if (orientation ==0) {
    vertex(position, -size, -size);
    vertex(position, size, -size);
    vertex(position, size, size);
    vertex(position,-size, size);
  }
  endShape(CLOSE);
}
