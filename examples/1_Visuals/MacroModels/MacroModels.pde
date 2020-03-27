import miPhysics.Engine.*;
import miPhysics.Renderer.*;

import peasy.*;
PeasyCam cam;

int displayRate = 60;

PhysicsContext phys;

PhyModel model1;
miTopoCreator model2, model3;
Driver3D driver1, driver2, driver3;

ModelRenderer renderer;

boolean showInstructions = true;
float bubbleRadius = 500;


void setup() {
  frameRate(displayRate);
  fullScreen(P3D);
  cam = new PeasyCam(this, 250);
  cam.setMinimumDistance(100);
  cam.setMaximumDistance(1500);
 
 
  // STEP 1: Create the physics context 
  phys = new PhysicsContext(1000, displayRate);  
  phys.setGlobalFriction(0.004);
  phys.setGlobalGravity(0, -0.016, 0.);
  
  // STEP 2: Create physical objects and add them to the scene !
  double dist = 25;
  int cpt;
  model1 = new PhyModel("shape1", phys.getGlobalMedium());
  model1.addMass("m1", new Mass3D(1, dist, new Vect3D(0, 0, 0)));
  model1.addMass("m2", new Mass3D(1, dist, new Vect3D(0, dist, 0)));
  model1.addMass("m3", new Mass3D(1, dist, new Vect3D(dist, dist, 0)));
  model1.addMass("m4", new Mass3D(1, dist, new Vect3D(dist, dist, dist)));
  
  model1.addInteraction("i1", new SpringDamper3D(dist, 0.1, 0.1), "m1", "m2");
  model1.addInteraction("i2", new SpringDamper3D(dist, 0.1, 0.1), "m2", "m3");
  model1.addInteraction("i3", new SpringDamper3D(sqrt(2)*dist, 0.1, 0.1), "m1", "m3");
  model1.addInteraction("i4", new SpringDamper3D(sqrt(2)*dist, 0.1, 0.1), "m1", "m4");
  model1.addInteraction("i5", new SpringDamper3D(sqrt(2)*dist, 0.1, 0.1), "m2", "m4");
  model1.addInteraction("i6", new SpringDamper3D(sqrt(2)*dist, 0.1, 0.1), "m3", "m4");
  
  cpt = 0;
  for(Mass m : model1.getMassList())
    model1.addInOut("driver"+cpt++, new Driver3D(), m);

  phys.mdl().addPhyModel(model1);
  
  
  model2 = new miTopoCreator("string", phys.getGlobalMedium());
  model2.setDim(130, 1, 1, 3);  
  model2.setGeometry(20, 20);
  model2.setParams(0.5,0.01,0.01);
  model2.setMassRadius(20);
  model2.generate();
  model2.translate(-40, -50, -50);
  
  cpt = 0;
  for(Mass m : model2.getMassList())
    model2.addInOut("driver"+cpt++, new Driver3D(), m);

  phys.mdl().addPhyModel(model2);
  
  model3 = new miTopoCreator("topo", phys.getGlobalMedium());
  model3.setDim(20, 5, 3, 2);  
  model3.setGeometry(20, 20);
  model3.setParams(0.5,0.008,0.001);
  model3.setMassRadius(20);
  model3.generate();
  model3.translate(40, -50, 50);
  
  cpt = 0;
  for(Mass m : model3.getMassList())
    model3.addInOut("driver"+cpt++, new Driver3D(), m);

  phys.mdl().addPhyModel(model3);
  
  
  // STEP 3: Set up an enclosing space (the BOWL !!)
  
  Ground3D center = phys.mdl().addMass("ground", new Ground3D(1, new Vect3D(0., -300., 0.)));
  cpt = 0;
  for(Mass m : model1.getMassList())
    phys.mdl().addInteraction("bub"+cpt++, new Bubble3D(bubbleRadius, 0.01, 0.01), center, m);
  for(Mass m : model2.getMassList())
    phys.mdl().addInteraction("bub"+cpt++, new Bubble3D(bubbleRadius, 0.01, 0.01), center, m);
  for(Mass m : model3.getMassList())
    phys.mdl().addInteraction("bub"+cpt++, new Bubble3D(bubbleRadius, 0.01, 0.01), center, m);
  
  
  // STEP 4 : Setup any collisions
  
  // Add some auto-collision for the string, so it doesn't fold into itself
  phys.colEngine().addAutoCollision(model2,30,20,0.0001,0.0001);
  // setup colliders between the three objects
  phys.colEngine().addCollision(model1,model2,0.01,0.01);
  phys.colEngine().addCollision(model1,model3,0.01,0.01);
  phys.colEngine().addCollision(model2,model3,0.01,0.01);


  // STEP 5 : Initialise the Physics Context !
  phys.init(); 
  
  renderer = new ModelRenderer(this);
  renderer.setZoomVector(1,1,1);
  renderer.displayModuleNames(false);
  renderer.setTextSize(6);
  renderer.setForceVectorScale(500);
  renderer.displayAutoCollisionVolumes(false);
  renderer.displayObjectVolumes(true);
  renderer.displayIntersectionVolumes(true);
}

void draw() {
  directionalLight(251, 102, 126, 0, 1, 0);
  ambientLight(142, 142, 142);
  background(0);
  stroke(255);
  
  if(showInstructions)
    displayModelInstructions();
    
  PVector test = phys.mdl().getMass("ground").getPos().toPVector();
  pushMatrix();
  rotateX(PI);
  translate(-test.x, -test.y, -test.z);
  drawHemisphere(bubbleRadius+20, 0xEE660000, 50);
  drawHemisphere(bubbleRadius+23, 0xFFFFFFAA, 50);
  popMatrix();
  
  phys.computeScene();
  renderer.renderScene(phys);

}

/* Trigger random forces on the mass */
void keyPressed() {
  switch(key){
    case ' ':
        for(Driver3D d : phys.mdl().getDrivers())
        d.applyFrc(new Vect3D(random(-1, 1),random(-5.95),random(-1, 1)));    
    case 'w':
      for(Driver3D d : model1.getDrivers())
        d.applyFrc(new Vect3D(random(-1, 1),random(-5.95),random(-1, 1)));
      break;
    case 'x':
      for(Driver3D d : model2.getDrivers())
        d.applyFrc(new Vect3D(random(-1, 1),random(-3.95),random(-1, 1)));
      break;
    case 'c':
      for(Driver3D d : model3.getDrivers())
        d.applyFrc(new Vect3D(random(-1, 1),random(-4.95),random(-1, 1)));
      break;
    case 'z':
      renderer.toggleObjectVolumesDisplay();
      break;
    case 'e':
      renderer.toggleIntersectionVolumesDisplay();
      break;
    case 'h':
      showInstructions = !showInstructions;
      break;
    case 'a':
      renderer.toggleAutoCollisonVolumesDisplay();
      break;
    default:
      break;
  }
}



void displayModelInstructions(){
  cam.beginHUD();
  textMode(MODEL);
  textSize(16);
  fill(255, 255, 255);
  text("Press the space bar to trigger random forces on all objects", 10, 30);
  text("Press 'w' to apply force to object 1 (pyramid)", 10, 55);
  text("Press 'x' to apply force to object 2 (string)", 10, 80);
  text("Press 'c' to apply force to object 3 (plate)", 10, 105);
  text("Press 'a' to toggle Auto-Collision Voxels display", 10, 130);
  text("Press 'z' to toggle Object Volumes display", 10, 155);
  text("Press 'e' to toggle Intersection Volumes display", 10, 180);
  text("FrameRate : " + frameRate, 10, 205);
  text("Press 'h' to hide instructions", 10, 230);

  cam.endHUD();
}


void drawHemisphere(float rho, int col, float div){
  
  float factor = TWO_PI / div;
  float x, y, z;
  
  noStroke();
  fill(col);
  
  for(float phi = 0.0; phi < HALF_PI/2; phi += factor/2) {
    beginShape(QUAD_STRIP);
    for(float theta = 0.0; theta < TWO_PI + factor; theta += factor) {
      x = rho * sin(phi) * cos(theta);
      z = rho * sin(phi) * sin(theta);
      y = -rho * cos(phi);
 
      vertex(x, y, z);
 
      x = rho * sin(phi + factor) * cos(theta);
      z = rho * sin(phi + factor) * sin(theta);
      y = -rho * cos(phi + factor);
 
      vertex(x, y, z);
    }
    endShape(CLOSE);
  }

}
