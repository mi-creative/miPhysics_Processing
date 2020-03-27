import miPhysics.Engine.*;
import miPhysics.Engine.Sound.*;
import miPhysics.Renderer.*;
import peasy.*;

int baseFrameRate = 60;

int mouseDragged = 0;

int gridSpacing = 2;
int xOffset= 0;
int yOffset= 0;

float currAudio = 0;
float gainVal = 1.;

PeasyCam cam;

PhysicsContext phys;

PhyModel bell;
PhyModel hammer;

Driver3D d;

ModelRenderer renderer;
miPhyAudioClient audioStreamHandler;

boolean showInstructions = true;



void setup()
{
  //size(1000, 700, P3D);
  fullScreen(P3D, 2);

  cam = new PeasyCam(this, 200);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);
  cam.rotateY(radians(-90));
  cam.rotateZ(radians(90));
  
  phys = new PhysicsContext(44100, (int)baseFrameRate);
  phys.setGlobalGravity(0, 0, 0);
  phys.setGlobalFriction(0.00001);
  
  bell = createBell();
  hammer = createHammer();

  phys.mdl().addPhyModel(bell);
  phys.mdl().addPhyModel(hammer);
  
  phys.colEngine().addCollision(bell,hammer,0.3,0.001);
  
  phys.init();

  renderer = new ModelRenderer(this);
  renderer.setZoomVector(1, 1, 1);
  renderer.displayMasses(true);
  renderer.setColor(massType.MASS3D, 55, 180, 155);
  renderer.setColor(interType.SPRINGDAMPER3D, 80, 100, 255, 170);
  renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 0.1);
  renderer.setStrainColor(interType.SPRINGDAMPER3D, 255, 250, 255, 255);

  audioStreamHandler = miPhyAudioClient.miPhyClassic(22050, 128, 0, 2, phys);
  audioStreamHandler.listenPos();
  audioStreamHandler.setListenerAxis(listenerAxis.Z);
  audioStreamHandler.setGain(3);
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
}

void keyPressed(){
  switch(key){
    case ' ':
      for(Driver3D d: hammer.getDrivers())
        d.applyFrc(new Vect3D(0, -(0.6+ random(0.6)), -0.1));
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
  text("Press the space bar to hit launch the hammer towards the bell.", 10, 30);
  text("Press 'o' to toggle object volumes display", 10, 55);
  text("Press 'v' to toggle intersection volumes display", 10, 80);
  text("Press 'h' to hide help", 10, 105);
  text("FrameRate : " + frameRate, 10, 130);
  cam.endHUD();
}
