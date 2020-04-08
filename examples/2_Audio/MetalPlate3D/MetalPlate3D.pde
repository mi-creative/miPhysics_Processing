import miPhysics.Engine.*;
import miPhysics.Engine.Sound.*;
import miPhysics.Renderer.*;


int displayRate = 60;

int mouseDragged = 0;

PhysicsContext phys;
PhyModel mesh;
Observer3D listener;
Driver3D driver;

miPhyAudioClient audioStreamHandler;

int gridSpacing;
int xOffset= 0;
int yOffset= 0;

int zZoom = 1;
int dimX = 22;
int dimY = 13;
double fric = 0.01;

ModelRenderer renderer;

boolean showInstructions = true;


///////////////////////////////////////

void setup()
{
  //size(1000, 700, P3D);
  fullScreen(P3D, 2);

  phys = new PhysicsContext(44100, displayRate);

  phys.setGlobalGravity(0, 0, 0);
  phys.setGlobalFriction(0.00001);

  gridSpacing = (int)((width/dimX));

  mesh = createMesh(dimX, dimY, "osc", "spring", 1., gridSpacing, 0.12, 0.1);
  driver = mesh.addInOut("driver", new Driver3D(), "osc0_0");
  mesh.addInOut("listener", new Observer3D(), "osc5_5");
  mesh.addInOut("listener2", new Observer3D(), "osc19_10");

  phys.mdl().addPhyModel(mesh);

  phys.init();

  renderer = new ModelRenderer(this);

  renderer.displayMasses(true);
  renderer.setColor(massType.MASS3D, 105, 100, 250);
  renderer.setColor(interType.SPRINGDAMPER3D, 155, 50, 50, 70);
  renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 20);
  renderer.setStrainColor(interType.SPRINGDAMPER3D, 255, 250, 255, 255);

  audioStreamHandler = miPhyAudioClient.miPhyClassic(44100, 256, 0, 2, phys);
  audioStreamHandler.listenPos();
  audioStreamHandler.setListenerAxis(listenerAxis.Z);
  audioStreamHandler.setGain(0.01);
  audioStreamHandler.start();
}

void draw()
{
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2, height/2.0, 0, 0, 1, 0);

  background(0, 0, 25);

  directionalLight(126, 126, 126, 100, 0, -1);
  ambientLight(182, 182, 182);
  if (showInstructions)
    displayModelInstructions();


  renderer.setZoomVector(1, 1, 0.1 * zZoom);

  pushMatrix();
  translate(xOffset + 20, yOffset + 20, 0.);
  renderer.renderScene(phys);
  popMatrix();



  if (mouseDragged == 1) {
    if ((mouseX) < (dimX*gridSpacing+xOffset) & (mouseY) < (dimY*gridSpacing+yOffset) & mouseX>xOffset & mouseY > yOffset) { // Garde fou pour ne pas sortir des limites du pinScreen
      if (mouseButton == LEFT)
        engrave(mouseX-xOffset, mouseY - yOffset);
      if (mouseButton == RIGHT)
        chisel(mouseX-xOffset, mouseY - yOffset);
    }
  }
}


void engrave(float mX, float mY) {
  String matName = "osc" + floor(mX/ gridSpacing)+"_"+floor(mY/ gridSpacing);
  Mass m = mesh.getMass(matName);
  if (m != null) {
    driver.moveDriver(m);
    driver.applyFrc(new Vect3D(0., 0., 15.));
  }
}

void chisel(float mX, float mY) {
  String matName = "osc" + floor(mX/ gridSpacing)+"_"+floor(mY/ gridSpacing);
  synchronized(phys.getLock()) {
    Mass m = mesh.getMass(matName);
    if (m != null)
      mesh.removeMassAndConnectedInteractions(m);
  }
}


void mouseDragged() {
  mouseDragged = 1;
}

void mouseReleased() {
  mouseDragged = 0;
}



void keyPressed() {
  switch(keyCode) {
  case UP:
    fric += 0.001;
    phys.setGlobalFriction(0.);
    break;
  case DOWN:
    fric -= 0.001;
    fric = max((float)fric, 0.);
    phys.setGlobalFriction(fric);
    break;
  case LEFT:
    zZoom++;
    break;
  case RIGHT:
    zZoom--;
    break;
  default:
    break;
  }

  switch(key) {
  case 'h':
    showInstructions = ! showInstructions;
  default:
    break;
  }
}

void displayModelInstructions() {
  textMode(MODEL);
  textSize(16);
  fill(255, 255, 255);
  text("Left-click and drag over the mesh to excite it.", 10, 30);
  text("Right-click and drag to create holes in the mesh", 10, 55);
  text("Press 'h' to hide help", 10, 80);
  text("FrameRate : " + frameRate, 10, 105);
  text("Friction: " + fric, 50, 50, 130);
  text("Zoom: " + zZoom, 50, 100, 155);
}
