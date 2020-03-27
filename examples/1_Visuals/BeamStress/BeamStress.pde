
import peasy.*;
import miPhysics.Engine.*;
import miPhysics.Renderer.*;

int displayRate = 90;

int dimX = 2;
int dimY = 2;
int dimZ = 12;
int overlap = 3;

double K = 0.003;
double M = 1;

PeasyCam cam;

PhysicsContext phys;
miTopoCreator beam;

ModelRenderer renderer;

boolean showInstructions = true;

double grav = 0.001;

void setup() {

  size(1000, 700, P3D);

  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);
  cam.rotateX(radians(-90));
  cam.setDistance(700);
  background(0);

  phys = new PhysicsContext(1050, displayRate);

  phys.setGlobalGravity(0, 0, grav);
  phys.setGlobalFriction(0.0001);

  beam = new miTopoCreator("beam", phys.getGlobalMedium());
  beam.setDim(dimX, dimY, dimZ, overlap);
  beam.setParams(M, K, 0.003);
  beam.setGeometry(25, 25);
  beam.setMassRadius(3);
  beam.addBoundaryCondition(Bound.Z_LEFT);
  beam.generate();

  phys.createMassSubset("beamMasses");
  phys.createInteractionSubset("beamInteractions");
  for(Mass m : beam.getMassList())
    phys.addMassToSubset(m,"beamMasses");
  for(Interaction i : beam.getInteractionList())
    phys.addInteractionToSubset(i,"beamInteractions");  
  
  phys.mdl().addPhyModel(beam);

  int nb = 0;
  for(Mass elem : beam.getMassList()){
    println(elem.getName());
    phys.mdl().addInteraction("plane"+nb++, new PlaneContact3D(0.1, 0.005, 2, 0), elem); 
  }
  
  phys.mdl().addInOut("driver", new Driver3D(),"beam/m_" + (dimX/2)+ "_" + (dimY/2) + "_" + (dimZ/2));

  phys.init();

  renderer = new ModelRenderer(this);
  renderer.displayMasses(true);
  renderer.setColor(interType.SPRINGDAMPER3D, 180, 10, 10, 170);
  renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 0.1);
  renderer.setStrainColor(interType.SPRINGDAMPER3D, 255, 250, 255, 255);

  frameRate(displayRate);
} 


void draw() {
  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(0);
  fill(255);
  drawPlane(2, 0, 200); 

  if(showInstructions)
    displayModelInstructions();
    
  phys.computeScene();
  renderer.renderScene(phys);
}


void keyPressed() {
  switch(key){
    case 'a':
      M = random(10) + 1;
      phys.setParamForMassSubset("beamMasses", param.MASS, M); 
      break;
    case 'z':
      K = random(0.1) + 0.001;
      phys.setParamForInteractionSubset("beamInteractions", param.STIFFNESS, K); 
      break;
    case 'h':
      showInstructions = ! showInstructions;
      break;
    case 'i':
      renderer.toggleModuleNameDisplay();
    default:
      break;
 
  }
  
  switch(keyCode){
    case UP:
      for(Driver3D d : phys.mdl().getDrivers())
        d.applyFrc(new Vect3D(0, -10, 0));
        break;
    case DOWN:
      for(Driver3D d : phys.mdl().getDrivers())
        d.applyFrc(new Vect3D(0, 10, 0));
        break;
    case LEFT:
      for(Driver3D d : phys.mdl().getDrivers())
        d.applyFrc(new Vect3D(-10, 0, 0));
        break;
    case RIGHT:
      for(Driver3D d : phys.mdl().getDrivers())
        d.applyFrc(new Vect3D(10, 0, 0));
        break;
    default:
      break;
  } 
}



void drawPlane(int orientation, float position, float size) {
  stroke(255);
  fill(0, 0, 60);

  beginShape();
  if (orientation ==2) {
    vertex(-size, -size, position);
    vertex( size, -size, position);
    vertex( size, size, position);
    vertex(-size, size, position);
  } else if (orientation == 1) {
    vertex(-size, position, -size);
    vertex( size, position, -size);
    vertex( size, position, size);
    vertex(-size, position, size);
  } else if (orientation ==0) {
    vertex(position, -size, -size);
    vertex(position, size, -size);
    vertex(position, size, size);
    vertex(position, -size, size);
  }
  endShape(CLOSE);
}



void displayModelInstructions(){
  cam.beginHUD();
  textMode(MODEL);
  textSize(16);
  fill(255, 255, 255);
  text("Use arrows to punch the beam !", 10, 30);
  text("Press 'a' to change beam mass", 10, 55);
  text("Press 'z' to change beam stiffness", 10, 80);
  text("Press 'i' to toggle mass name display", 10, 105);
  text("Press 'h' to hide help", 10, 130);
  text("FrameRate : " + frameRate, 10, 155);
  text("Mass : " + M, 10, 180);
  text("Stiffness : " + K, 10, 205);
  cam.endHUD();
}
