
import peasy.*;
import miPhysics.Engine.*;
import miPhysics.ModelRenderer.*;

int displayRate = 90;

int dimX = 2;
int dimY = 2;
int dimZ = 12;
int overlap = 3;

PeasyCam cam;

PhysicalModel mdl;
ModelRenderer renderer;

double grav = 0.001;

void setup() {

  size(1000, 700, P3D);

  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);
  cam.rotateX(radians(-90));
  cam.setDistance(700);

  background(0);

  mdl = new PhysicalModel(1050, displayRate);

  mdl.setGlobalGravity(0, 0, grav);
  mdl.setGlobalFriction(0.0001);

  TopoGenerator q = new TopoGenerator(mdl, "mass", "spring");
  q.setDim(dimX, dimY, dimZ, overlap);
  q.setParams(1, 0.003, 0.003);
  q.setGeometry(25, 25);
  
  q.setMassRadius(3);


  q.setMatSubsetName("beamMats");
  q.setLinkSubsetName("beamLinks");

  q.addBoundaryCondition(Bound.Z_LEFT);

  q.generate();

  int nb = 0;
  for(Mass elem : mdl.getMassList()){
    println(elem.getName());
    mdl.addInteraction("plane"+nb++, new PlaneContact3D(0.1, 0.005, 2, 0), elem); 
  }
  
  String triggerMass = "mass_" + (dimX/2)+ "_" + (dimY/2) + "_" + (dimZ/2); 
  mdl.addInOut("driver", new Driver3D(),triggerMass);

  mdl.init();

  renderer = new ModelRenderer(this);
  renderer.displayMasses(true);
  renderer.setColor(interType.SPRINGDAMPER3D, 180, 10, 10, 170);
  renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 0.1);
  renderer.setStrainColor(interType.SPRINGDAMPER3D, 255, 250, 255, 255);

  frameRate(displayRate);
} 

// DRAW: THIS IS WHERE WE RUN THE MODEL SIMULATION AND DISPLAY IT

void draw() {

  mdl.compute();

  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);

  background(0);
  fill(255);
  drawPlane(2, 0, 200); 

  renderer.renderModel(mdl);
}


void keyPressed() {


  if (key == ' ')
    mdl.setGlobalGravity(0, 0, -grav);

  if (key == 'a') {
    for(Driver3D d : mdl.getDrivers())
      d.applyFrc(new Vect3D(0, 10, 0));    
  } else if (key == 'z') {
    for(Driver3D d : mdl.getDrivers())
      d.applyFrc(new Vect3D(0, -10, 0));
  } else if (key =='e') {
    for(Driver3D d : mdl.getDrivers())
      d.applyFrc(new Vect3D(10, 0, 0));
  } else if (key =='r') {
    for(Driver3D d : mdl.getDrivers())
      d.applyFrc(new Vect3D(-10, 0, 0));
  } else if (key == 'q') {
    grav = 0.001;
    mdl.setGlobalGravity(0, 0, grav);
  } else if (key=='s') {
    grav = 0.003;
    mdl.setGlobalGravity(0, 0, grav);
  }
  if (key =='w'){
    mdl.setParamForMassSubset(param.MASS, random(10) + 1, "beamMats"); 
  }
  if (key =='x'){
    mdl.setParamForInteractionSubset(param.STIFFNESS, random(0.2) + 0.001, "beamLinks"); 
  }
  
  
}

void keyReleased() {
  if (key == ' ')
    mdl.setGlobalGravity(0, 0, grav);
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
