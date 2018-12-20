/*
Model: Dynamic Parameter Modifications.
Author: James Leonard (james.leonard@gipsa-lab.fr)

Variant on the HelloMass model.

We create "subsets" for the mass and the different springs.
We can then modify the physical parameters of modules in these subsets 
in real time during the simulation.

Trigger forces on the mass using the space bar.
Hit 'a' to change the inertia of the mass
Hit 'z', 'e' or 'r' to change the stiffness and damping of the springs.
*/

import miPhysics.*;
import peasy.*;
PeasyCam cam;

int displayRate = 90;

float m = 1.0;
float k = 0.001;
float k2 = 0.001;
float k3 = 0.001;
float z = 0.01;
float z2 = 0.01;
float z3 = 0.01;
float dist = 70;

/*  global physical model object : will contain the model and run calculations. */
PhysicalModel mdl;

void setup() {
  frameRate(displayRate);
  size(1000, 700, P3D);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(100);
  cam.setMaximumDistance(500);
  
  mdl = new PhysicalModel(300, displayRate);

  /* Create a mass, connected to fixed points via Spring Dampers */
  mdl.addMass3D("mass", m, new Vect3D(0., 0., 0.), new Vect3D(0., 0., 1.));
  
  mdl.addGround3D("ground1", new Vect3D(dist, 0., 0.));
  mdl.addGround3D("ground2", new Vect3D(-dist, 0., 0.));
  mdl.addGround3D("ground3", new Vect3D(0., dist, 0.));
  mdl.addGround3D("ground4", new Vect3D(0., -dist, 0.));
  mdl.addGround3D("ground5", new Vect3D(0., 0., dist));
  mdl.addGround3D("ground6", new Vect3D(0., 0., -dist));
  
  mdl.addSpringDamper3D("spring1", dist, k, z, "mass", "ground1"); 
  mdl.addSpringDamper3D("spring2", dist, k, z, "mass", "ground2"); 
  mdl.addSpringDamper3D("spring3", dist, k2, z2, "mass", "ground3"); 
  mdl.addSpringDamper3D("spring4", dist, k2, z2, "mass", "ground4"); 
  mdl.addSpringDamper3D("spring5", dist, k3, z3, "mass", "ground5"); 
  mdl.addSpringDamper3D("spring6", dist, k3, z3, "mass", "ground6"); 
  
  /* Group modules into subsets for parameter modifications */
  mdl.createMatSubset("massmod");
  mdl.addMatToSubset("mass","massmod");
  
  mdl.createLinkSubset("X_springs");
  mdl.addLinkToSubset("spring1","X_springs");
  mdl.addLinkToSubset("spring2","X_springs");
  
  mdl.createLinkSubset("Y_springs");
  mdl.addLinkToSubset("spring3","Y_springs");
  mdl.addLinkToSubset("spring4","Y_springs");
  
  mdl.createLinkSubset("Z_springs");
  mdl.addLinkToSubset("spring5","Z_springs");
  mdl.addLinkToSubset("spring6","Z_springs");
  
  mdl.init(); 
}

void draw() {
  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(0);
  stroke(255);
  
  /* Calculate Physics */
  mdl.draw_physics();
  
  /* Draw the mass and the springs */
  PVector pos = mdl.getMatPVector("mass");
  line(pos.x, pos.y, pos.z, dist, 0, 0);
  line(pos.x, pos.y, pos.z, -dist, 0, 0);
  line(pos.x, pos.y, pos.z, 0, dist, 0);
  line(pos.x, pos.y, pos.z, 0, -dist, 0);
  line(pos.x, pos.y, pos.z, 0, 0, dist);
  line(pos.x, pos.y, pos.z, 0, 0, -dist);
  translate(pos.x, pos.y, pos.z);
  sphere(15);
  
  fill(255);
  textSize(12); 
  text("Mass Val: " + m, 15, 15, 15);
  text("X Springs:  k =  " + k + ",z = " + z, 15, 30, 15);
  text("Y Springs:  k =  " + k2 + ",z = " + z2, 15, 45, 15);
  text("Z Springs:  k =  " + k3 + ",z = " + z3, 15, 60, 15);
}

void keyPressed() {
  // Trigger a random force on the mass module
  if (key == ' ')
    mdl.triggerForceImpulse("mass",random(-5,5),random(-5,5),random(-5,5));
  // randomly modify the inertia of the mass module
  if (key == 'a'){
    m = random(1.0, 20);
    mdl.changeMassParamOfSubset(m,"massmod");
  }
  if (key == 'z'){
    k = random(0.000001, 0.1);
    mdl.changeStiffnessParamOfSubset(k,"X_springs");
    z = random(0.001, 0.1);
    mdl.changeDampingParamOfSubset(z,"X_springs");
  }
  if (key == 'e'){
    k2 = random(0.000001, 0.1);
    mdl.changeStiffnessParamOfSubset(k2,"Y_springs");
    z2 = random(0.001, 0.1);
    mdl.changeDampingParamOfSubset(z2,"Y_springs");
  }
  if (key == 'r'){
    k3 = random(0.000001, 0.1);
    mdl.changeStiffnessParamOfSubset(k3,"Z_springs");
    z3 = random(0.001, 0.1);
    mdl.changeDampingParamOfSubset(z3,"Z_springs");
  }
}