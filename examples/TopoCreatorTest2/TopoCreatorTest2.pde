import peasy.*;

import miPhysics.Renderer.*;
import miPhysics.Engine.*;
import miPhysics.Engine.Sound.*;

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
Observer3D listener;
PosInput3D input;
ModelRenderer renderer;

miPhyAudioClient audioStreamHandler;

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

  Medium med = new Medium(0.000001, new Vect3D(0, -0.00, 0.0));

  phys = new PhysicsContext(44100);

  miTopoCreator string = new miTopoCreator("string", med);
  string.setDim(25,2,1,1);
  string.setGeometry(0.1,0.09);
  string.setParams(1,0.05,0.0001);
  string.setMassRadius(0.05);
  string.set2DPlane(true);
  string.addBoundaryCondition(Bound.X_LEFT);
  string.addBoundaryCondition(Bound.X_RIGHT);
  string.generate();
  string.rotate(-PI/12, 0, 0);
  
  miTopoCreator shape = new miTopoCreator("more", med);
  shape.setDim(35,2,1,1);
  shape.setGeometry(0.1,0.08);
  shape.setParams(1,0.05,0.0001);
  shape.setMassRadius(0.05);
  shape.set2DPlane(true);
  shape.addBoundaryCondition(Bound.X_LEFT);
  shape.addBoundaryCondition(Bound.X_RIGHT);
  shape.generate();
  shape.translate(2, 0., 0);
  
  miTopoCreator mini = new miTopoCreator("end", med);
  mini.setDim(15,2,1,1);
  mini.setGeometry(0.1,0.08);
  mini.setParams(1,0.05,0.0001);
  mini.setMassRadius(0.05);
  mini.set2DPlane(true);
  mini.addBoundaryCondition(Bound.X_LEFT);
  mini.addBoundaryCondition(Bound.X_RIGHT);
  mini.generate();
  mini.rotate(PI/12,0, 0);
  mini.translate(5.5, -0.8, 0);
  
  //phys.mdl().addInteraction("link", new SpringDamper3D(0.6, 0.001, 0.01), shape.getMass("m_3_0_0") ,string.getMass("m_33_0_0"));
  
  //string.rotate(0, PI/2, 0);
  
  
  
  PhyModel perc = new PhyModel("pluck", med);

  input = perc.addMass("input", new PosInput3D(0.2, new Vect3D(30, 30, 0), 100));

  phys.mdl().addPhyModel(string);
  phys.mdl().addPhyModel(perc);
  phys.mdl().addPhyModel(shape);
  phys.mdl().addPhyModel(mini);

  phys.mdl().addInOut("listener1", new Observer3D(filterType.HIGH_PASS), phys.mdl().getPhyModel("string").getMass("m_10_0_0"));
  phys.mdl().addInOut("listener2", new Observer3D(filterType.HIGH_PASS), phys.mdl().getPhyModel("more").getMass("m_10_0_0"));
  phys.mdl().addInOut("listener3", new Observer3D(filterType.HIGH_PASS), phys.mdl().getPhyModel("end").getMass("m_10_0_0"));


   // OPTION 1: add collisions manually between objects
  /*
  int i = 0;
  for(Mass m : string.getMassList()){
    phys.mdl().addInteraction("cnt"+i, new Contact3D(0.3, 0.01), m, perc.getMass("input"));
    i++;
  }*/

  // OPTION 2: add a general collision between objects
  phys.colEngine().addCollision(string, perc, 0.015, 0.0001);
  phys.colEngine().addCollision(shape, perc, 0.015, 0.0001);
  phys.colEngine().addCollision(mini, perc, 0.015, 0.0001);

  phys.colEngine().addCollision(string, shape, 0.015, 0.0001);
  phys.colEngine().addCollision(shape, mini, 0.015, 0.0001);
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

  audioStreamHandler = miPhyAudioClient.miPhyClassic(44100, 512, 0, 2, phys);
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
