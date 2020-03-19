import miPhysics.Engine.*;
import miPhysics.Engine.Sound.*;
import miPhysics.Renderer.*;

import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;

int baseFrameRate = 60;

float currAudio = 0;

PeasyCam cam;


PhysicalModel mdl; 
Observer3D listener;
PosInput3D input;
Driver3D driver;

ModelRenderer renderer;
miPhyAudioClient audioStreamHandler;

///////////////////////////////////////

void setup()
{
  //size(1000, 700, P3D);
  fullScreen(P3D, 2);

  // Step 1: setup Camera
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);
  cam.rotateX(radians(-90));
  cam.setDistance(700);

  // Step 2: setup Physical Model
  int DIM = 30;
  double dist = 10;
  double K = 0.3;
  double Z = 0.023;

  double radius = ((DIM/2)-1)*dist; 
  Vect3D center = new Vect3D(dist*DIM/2, dist*DIM/2, 0);
  
  mdl = new PhysicalModel(44100, (int)baseFrameRate);
  mdl.setGlobalGravity(0, 0, 0);
  mdl.setGlobalFriction(0.00001);

  generateMesh(mdl, DIM, DIM, "osc", "spring", 1., dist, K, Z);

  ArrayList<Mass> toRemove = new ArrayList<Mass>();
  for (Mass m : mdl.getMassList()) {
    if (m.getPos().dist(center) > radius)
      toRemove.add(m);
  }
  for (Mass m : toRemove)
    mdl.removeMassAndConnectedInteractions(m);

  mdl.addMass("perc", new Osc3D(5, 15, 0.00001, 0.01, new Vect3D(DIM/2.5*dist, DIM/3.5*dist, 50)), new Medium(0, new Vect3D(0, 0, 0))); 
  driver = mdl.addInOut("drive", new Driver3D(), "perc");

  for (int i = 0; i < mdl.getNumberOfMasses()-1; i++) {
    if (mdl.getMassList().get(i) != null) {
      println(mdl.getMassList().get(i).getName());
      mdl.addInteraction("col_"+i, new Contact3D(0.05, 0.001), "perc", mdl.getMassList().get(i).getName());
    }
  }

  mdl.addInOut("list_1", new Observer3D(filterType.HIGH_PASS), "osc16_24");
  mdl.addInOut("list_2", new Observer3D(filterType.HIGH_PASS), "osc13_23");
  mdl.init();


  // Step 3: Setup Renderer
  renderer = new ModelRenderer(this);
  renderer.setZoomVector(1, 1, 1);
  renderer.displayMasses(false);
  renderer.setColor(massType.MASS3D, 80, 100, 255);
  renderer.setColor(interType.SPRINGDAMPER3D, 80, 100, 255, 170);
  renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 15);
  renderer.setStrainColor(interType.SPRINGDAMPER3D, 255, 250, 255, 255);

  // Step 4: setup the real time simulation / audio thread
  audioStreamHandler = miPhyAudioClient.miPhyClassic(22050, 256, 0, 2, mdl);
  audioStreamHandler.listenPos();
  audioStreamHandler.setListenerAxis(listenerAxis.Z);
  audioStreamHandler.setGain(0.1);
  audioStreamHandler.start();


  frameRate(baseFrameRate);
}

void draw()
{
  background(255, 255, 255);

  directionalLight(126, 126, 126, 100, 0, -1);
  ambientLight(182, 182, 182);

  renderer.renderModel(mdl);

  PVector pos = mdl.getMass("perc").getPos().toPVector();
  pushMatrix();
  translate(pos.x, pos.y, pos.z);
  noStroke();
  fill(255, 0, 0);
  sphere(15);
  popMatrix();

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
    driver.applyFrc(new Vect3D(0, -1, 0));
  }
  if (key == 'a') {
    for (Driver3D d : mdl.getDrivers())
      d.applyFrc(new Vect3D(0, 0., -10));
  }
}





void generateMesh(PhysicalModel mdl, int dimX, int dimY, String mName, String lName, double masValue, double dist, double K, double Z) {

  String masName;
  Vect3D X0;
  for (int i = 0; i < dimY; i++) {
    for (int j = 0; j < dimX; j++) {
      masName = mName + j +"_"+ i;
      X0 = new Vect3D((float)j*dist, (float)i*dist, 0.);
      float m = min((float)(masValue*(1+0.01*i*dimX)), (float)(masValue*(1+0.01*(dimX-i)))); 
      if ((i==dimY/2) && (j == dimX/2))
        mdl.addMass(masName, new Ground3D(1, X0));
      else
        mdl.addMass(masName, new Mass1D(m, 10, X0));
    }
  }

  String masName1, masName2;
  for (int i = 0; i < dimX; i++) {
    for (int j = 0; j < dimY-1; j++) {
      masName1 = mName + i +"_"+ j;
      masName2 = mName + i +"_"+ str(j+1);
      mdl.addInteraction(lName + "1_" +i+"_"+j, new SpringDamper3D(dist*0.1, K, Z), masName1, masName2);
    }
  }
  for (int i = 0; i < dimX-1; i++) {
    for (int j = 0; j < dimY; j++) {
      masName1 = mName + i +"_"+ j;
      masName2 = mName + str(i+1) +"_"+ j;
      mdl.addInteraction(lName + "2_" +i+"_"+j, new SpringDamper3D(dist*0.9, K, Z), masName1, masName2);
    }
  }
}
