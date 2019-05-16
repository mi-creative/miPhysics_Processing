import peasy.*;
import miPhysics.*;

int displayRate = 50;
boolean BASIC_VISU = false;
String fileName=null;

PeasyCam cam;
PhysicalModel mdl;
ModelRenderer renderer;
ModelLoader loader;

void setup() {

  size(1000, 700, P3D);

  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);
  cam.rotateX(radians(-80));
  
  cam.setDistance(750);

  background(0);

  mdl = new PhysicalModel(1050, displayRate);
  renderer = new ModelRenderer(this);
  loader = new ModelLoader(this);
  
 // loader.loadModel("/Users/Remi/Desktop/data/BeamModel.xml",mdl);
  
  selectInput("select the file you want to open","load");
  
  
  if (BASIC_VISU){
    renderer.displayMats(false);
    renderer.setColor(linkModuleType.SpringDamper3D, 155, 200, 200, 255);
    renderer.setSize(linkModuleType.SpringDamper3D, 1);
  }
  else{
    renderer.displayMats(false);
    renderer.setColor(linkModuleType.SpringDamper3D, 0, 50, 255, 255);
    renderer.setSize(linkModuleType.SpringDamper3D, 1);
    renderer.setStrainGradient(linkModuleType.SpringDamper3D, true, 0.02);
    renderer.setStrainColor(linkModuleType.SpringDamper3D, 150, 150, 255, 255);
  }
  
  frameRate(displayRate);

} 

void draw() {
  
  mdl.draw_physics();

  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);

  background(0);

  renderer.renderModel(mdl);
}



void load(File selection){
  if (selection==null){
    println("No file was selected");
  }
  else{
    fileName=selection.getAbsolutePath();
    println(fileName);
    synchronized(mdl.getLock()){
      loader.loadModel(fileName, mdl);
    }
  }
}

void save(File selection){
  if (selection==null){
    println("No file was selected");
  }
  else{
        synchronized(mdl.getLock()){
          fileName=selection.getAbsolutePath();
          loader.saveModel(fileName, mdl);
        }
  }
}
