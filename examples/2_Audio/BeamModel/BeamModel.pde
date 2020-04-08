import peasy.*;

import miPhysics.Renderer.*;
import miPhysics.Engine.*;
import miPhysics.Engine.Sound.*;

import java.math.RoundingMode;
import java.text.DecimalFormat;


int baseFrameRate = 60;
float currAudio = 0;

PeasyCam cam;

PhysicsContext phys; 

Observer3D listener;
Driver3D driver;
miTopoCreator beam;

ModelRenderer renderer;
miPhyAudioClient audioStreamHandler;

boolean showInstructions = true;

///////////////////////////////////////

void setup()
{
  //size(1000, 700, P3D);
  fullScreen(P3D,2);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(5500);


  phys = new PhysicsContext(44100);
  phys.setGlobalFriction(0.00001);

  beam = new miTopoCreator("topo", phys.getGlobalMedium());
  beam.setDim(45, 2, 2, 1);  
  beam.setGeometry(25, 25);
  beam.setParams(1,0.2,0.0001);
  beam.setMassRadius(2);
  beam.addBoundaryCondition(Bound.X_LEFT);
  beam.addBoundaryCondition(Bound.X_RIGHT);
  beam.generate();
  beam.translate(-25*22, 0, 0);
  
  driver = beam.addInOut("driver", new Driver3D(), "m_8_0_0");
  listener = beam.addInOut("listener1", new Observer3D(filterType.HIGH_PASS), "m_15_1_0");
  beam.addInOut("listener2", new Observer3D(filterType.HIGH_PASS), "m_40_0_0");
  
  phys.mdl().addPhyModel(beam);

  phys.init();

  renderer = new ModelRenderer(this);  
  renderer.displayMasses(true);  
  renderer.setColor(massType.MASS3D, 140, 140, 240);
  renderer.setColor(interType.SPRINGDAMPER3D, 135, 70, 70, 255);
  renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 0.1);
  renderer.setStrainColor(interType.SPRINGDAMPER3D, 105, 100, 200, 255);
  
  renderer.displayIntersectionVolumes(true);
  renderer.displayForceVectors(false);

  audioStreamHandler = miPhyAudioClient.miPhyClassic(44100, 128, 0, 2, phys);
  audioStreamHandler.setListenerAxis(listenerAxis.Y);
  audioStreamHandler.setGain(0.03);
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

  if(showInstructions)
    displayModelInstructions();

  renderer.renderScene(phys);
}

void keyPressed(){
  
  int forceRampSteps = (int)(0.1 * 44100);
  
  switch(key){
    case 'a':
      driver.moveDriver(beam.getMass("m_35_1_0"));
      driver.triggerForceRamp(0, 0.1, 0, forceRampSteps);
      break;
    case 'z':
      driver.moveDriver(beam.getMass("m_25_1_0"));
      driver.triggerForceRamp(0, 0.2, 0, forceRampSteps);
      break;
    case 'e':
      driver.moveDriver(beam.getMass("m_15_1_0"));
      driver.triggerForceRamp(0, 0.4, 0, forceRampSteps);
      break;
    case 'r':
      driver.moveDriver(beam.getMass("m_10_1_0"));
      driver.triggerForceRamp(0, 0.7, 0, forceRampSteps);
      break;
    case 't':
      driver.moveDriver(beam.getMass("m_5_1_0"));
      driver.triggerForceRamp(0, 0.9, 0, forceRampSteps);
      break;
    case 'y':
      driver.moveDriver(beam.getMass("m_5_1_0"));
      driver.triggerForceRamp(0, 1.3, 0, forceRampSteps);
      break;
    case 'h':
      showInstructions = !showInstructions;
  }
}


void displayModelInstructions(){
  cam.beginHUD();
  textMode(MODEL);
  textSize(16);
  fill(255, 255, 255);
  text("Use the [a, z, e, r, t, y] keys to pluck the beam.", 10, 30);
  text("Plucking from soft to hard and from central to near one end.", 10, 55);
  text("Press 'h' to hide help", 10, 105);
  text("FrameRate : " + frameRate, 10, 130);
  DecimalFormat df = new DecimalFormat("#.####");
  df.setRoundingMode(RoundingMode.CEILING);
  text("Curr Audio: " + df.format(listener.observePos().y), 10, 155);
  cam.endHUD();
}
