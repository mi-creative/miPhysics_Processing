import peasy.*;
import miPhysics.*;

int displayRate = 50;
boolean BASIC_VISU = false;
String fileName=null;
String file=null;

PeasyCam cam;
PhysicalModel mdl;
ModelRenderer renderer;
ModelLoader loader;

void setup() {
  
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(3000);
  cam.rotateX(radians(0));

  cam.setDistance(750);

  background(0);

  mdl = new PhysicalModel(1050, displayRate);
  renderer = new ModelRenderer(this);
  loader = new ModelLoader(this);

//   loader.loadModel("/Users/Remi/./Desktop/data/FlyingMesh.xml",mdl);
//   loader.setIsLoaded(true);
   

  //selectInput("select the file you want to open", "load");
    loader.loadModelFromFile(mdl);
        

  if (BASIC_VISU) {
    renderer.displayMats(false);
    renderer.setColor(linkModuleType.SpringDamper3D, 155, 200, 200, 255);
    renderer.setSize(linkModuleType.SpringDamper3D, 1);
  } else {
    renderer.displayMats(false);
    renderer.setColor(linkModuleType.SpringDamper3D, 0, 50, 255, 255);
    renderer.setSize(linkModuleType.SpringDamper3D, 1);
    renderer.setStrainGradient(linkModuleType.SpringDamper3D, true, 0.02);
    renderer.setStrainColor(linkModuleType.SpringDamper3D, 150, 150, 255, 255);
  }

  frameRate(displayRate);


} 

void draw() {

if (loader.getIsLoaded()==false) {
    waitingScreen();
  } else {
    mdl.draw_physics();
    background(0);
    renderer.renderModel(mdl);
  } 
}



void load(File selection) {
  if (selection==null) {
    println("No file was selected");
  } else {
    file = selection.getName();
    fileName=selection.getAbsolutePath();
    synchronized(mdl.getLock()) {
      loader.loadModel(fileName, mdl);
      loader.setIsLoaded(true);
    }
  }
}

void save(File selection) {
  if (selection==null) {
    println("No file was selected");
  } else {
    synchronized(mdl.getLock()) {
      fileName=selection.getAbsolutePath();
      loader.saveModel(fileName, mdl);
    }
  }
}

void waitingScreen() {
  background(0);
  fill(255);
  textSize(30);
  textAlign(CENTER, BOTTOM);
  text("model " + file + " loading ...", 10, 10);
  textAlign(CENTER, CENTER);
  text("number of Mats charged = " + mdl.getNumberOfMats(), 10, 50);
  textAlign(CENTER, TOP);
  text("number of Links charged = " + mdl.getNumberOfLinks(), 10, 100);
}
