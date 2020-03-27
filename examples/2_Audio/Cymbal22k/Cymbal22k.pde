import miPhysics.Engine.*;
import miPhysics.Engine.Sound.*;
import miPhysics.Renderer.*;
import peasy.*;

int baseFrameRate = 60;

float currAudio = 0;

PeasyCam cam;


PhysicsContext phys;
PhyModel hammer;

Observer3D listener;
PosInput3D input;
Driver3D driver;

ModelRenderer renderer;
miPhyAudioClient audioStreamHandler;

boolean showInstructions = true;


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
  double Z = 0.013;
  
  phys = new PhysicsContext(44100, (int)baseFrameRate);
  
  phys.setGlobalGravity(0, 0, 0);
  phys.setGlobalFriction(0.00001);

  PhyModel cymb = createCymbal(DIM, DIM, "osc", "spring", 1., dist, K, Z);

  hammer = new PhyModel("hammer", phys.getGlobalMedium());
  hammer.addMass("perc", new Osc3D(50, 15, 0.00001, 0.01, new Vect3D(DIM/2.5*dist, DIM/3.5*dist, 70)), new Medium(0, new Vect3D(0, 0, 0))); 
  hammer.addInOut("drive", new Driver3D(), "perc");
  
  phys.mdl().addPhyModel(cymb);
  phys.mdl().addPhyModel(hammer);
  
  phys.colEngine().addCollision(cymb,hammer,0.5,0.001);

  phys.init();


  // Step 3: Setup Renderer
  renderer = new ModelRenderer(this);
  renderer.setZoomVector(1, 1, 1);
  renderer.displayMasses(false);
  renderer.setColor(massType.MASS3D, 80, 100, 255);
  renderer.setColor(interType.SPRINGDAMPER3D, 80, 10, 155, 170);
  renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 15);
  renderer.setStrainColor(interType.SPRINGDAMPER3D, 255, 250, 0, 255);

  // Step 4: setup the real time simulation / audio thread
  audioStreamHandler = miPhyAudioClient.miPhyClassic(22050, 128, 0, 2, phys);
  audioStreamHandler.listenPos();
  audioStreamHandler.setListenerAxis(listenerAxis.Z);
  audioStreamHandler.setGain(0.1);
  audioStreamHandler.start();


  frameRate(baseFrameRate);
}

void draw()
{
  background(0, 0, 25);

  directionalLight(126, 126, 126, 100, 0, -1);
  ambientLight(182, 182, 182);
  
  if(showInstructions)
    displayModelInstructions();

  renderer.renderScene(phys);

  PVector pos;
  synchronized(phys.getLock()){
    pos = hammer.getMass("perc").getPos().toPVector();
  }
  pushMatrix();
  translate(pos.x, pos.y, pos.z);
  noStroke();
  fill(255, 0, 0);
  sphere(15);
  popMatrix();
}


void keyPressed(){
  switch(key){
    case ' ':
      for (Driver3D d : hammer.getDrivers())
        d.applyFrc(new Vect3D(0, 0., -50));
      break;
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
  text("Press the space bar to hit the cymbal with the red hammer.", 10, 30);
  text("Press 'o' to toggle object volumes display", 10, 55);
  text("Press 'v' to toggle intersection volumes display", 10, 80);
  text("Press 'h' to hide help", 10, 105);
  text("FrameRate : " + frameRate, 10, 130);
  cam.endHUD();
}
