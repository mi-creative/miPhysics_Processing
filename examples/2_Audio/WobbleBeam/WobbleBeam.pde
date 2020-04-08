import peasy.*;

import miPhysics.Renderer.*;
import miPhysics.Engine.*;
import miPhysics.Engine.Sound.*;

import java.math.RoundingMode;
import java.text.DecimalFormat;

int baseFrameRate = 60;

PeasyCam cam;

// Audio Output Variables Init
float currAudio = 0;

PhysicsContext phys; 

Observer3D listener;
PosInput3D input;
miTopoCreator beam;

ModelRenderer renderer;
miPhyAudioClient audioStreamHandler;

boolean showInstructions = true;


///////////////////////////////////////

void setup()
{
  //size(1000, 700, P3D); //   Fullscreen option
  fullScreen(P3D, 2); //    Or window option
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(5000);
  
  phys = new PhysicsContext(44100);
  phys.setGlobalFriction(0.0000003);

  PhyModel perc = new PhyModel("pluck", phys.getGlobalMedium());
  input = perc.addMass("input", new PosInput3D(40, new Vect3D(3, -4, 0), 100));
  phys.mdl().addPhyModel(perc);
  
  beam = new miTopoCreator("topo", phys.getGlobalMedium());
  beam.setDim(4, 50, 1, 1);  
  beam.setGeometry(10, 10);
  beam.setParams(1,0.3,0.0001);
  beam.setMassRadius(4);
  beam.set2DPlane(true);
  beam.addBoundaryCondition(Bound.Y_LEFT);
  //beam.addBoundaryCondition(Bound.X_RIGHT);
  beam.generate();
  beam.translate(0, 0, 0);
  
  listener = beam.addInOut("listener1", new Observer3D(filterType.HIGH_PASS), "m_2_30_0");
  beam.addInOut("listener2", new Observer3D(filterType.HIGH_PASS), "m_1_22_0");
  
  phys.mdl().addPhyModel(beam);
  phys.colEngine().addCollision(beam, perc,0.1, 0.01);

  phys.init();
  
  renderer = new ModelRenderer(this);
    
  renderer.displayMasses(true);
  renderer.setColor(massType.MASS2DPLANE, 120, 0, 140);
  renderer.setColor(massType.GROUND3D, 30, 100, 100);
  
  renderer.setColor(interType.SPRINGDAMPER3D, 235, 120, 120, 255);
  renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 0.05);
  renderer.setStrainColor(interType.SPRINGDAMPER3D, 130, 130, 250, 255);
  
  cam.setDistance(500);  // distance from looked-at point
  
  audioStreamHandler = miPhyAudioClient.miPhyClassic(44100, 128, 0, 2, phys);
  audioStreamHandler.setListenerAxis(listenerAxis.Y);
  audioStreamHandler.setGain(0.05);
  audioStreamHandler.start();
  
  frameRate(baseFrameRate);

}

void draw()
{
  noCursor();
  background(0, 0, 25);
  directionalLight(126, 126, 126, 100, 1, 0);
  ambientLight(182, 182, 182);

  float x = 2000 * (float)mouseX / width - 1000;
  float y = 1500 * (float)mouseY / height - 750;
  input.drivePosition(new Vect3D(x, y, 0));

  if(showInstructions)
    displayModelInstructions();

  renderer.renderScene(phys);
}


void keyPressed(){
  switch(key){
    case 'o':
      renderer.toggleObjectVolumesDisplay();
      break;
    case 'v':
      renderer.toggleIntersectionVolumesDisplay();
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
  text("Use the mouse to pluck the string with the red Position Input module", 10, 30);
  text("Press 'o' to toggle object volumes display", 10, 55);
  text("Press 'v' to toggle intersection volumes display", 10, 80);
  text("Press 'h' to hide help", 10, 105);
  text("FrameRate : " + frameRate, 10, 130);
  DecimalFormat df = new DecimalFormat("#.####");
  df.setRoundingMode(RoundingMode.CEILING);
  text("Curr Audio: " + df.format(listener.observePos().y), 10, 155);
  cam.endHUD();
}
