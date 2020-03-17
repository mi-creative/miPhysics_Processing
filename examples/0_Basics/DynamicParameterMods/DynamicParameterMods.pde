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

Press 'w' to print the model state.
*/

import miPhysics.Engine.*;

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
  mdl.addMass("mass", new Mass3D(m, 15, new Vect3D(0., 0., 0.), new Vect3D(0., 0., 0.)));

  //mdl.addMass3D("mass", m, 10, new Vect3D(0., 0., 0.), new Vect3D(0., 0., 1.));
  mdl.addMass("ground1", new Ground3D(1, new Vect3D(dist, 0., 0.)));
  mdl.addMass("ground2", new Ground3D(1, new Vect3D(-dist, 0., 0.)));
  mdl.addMass("ground3", new Ground3D(1, new Vect3D(0., dist, 0.)));
  mdl.addMass("ground4", new Ground3D(1, new Vect3D(0., -dist, 0.)));
  mdl.addMass("ground5", new Ground3D(1, new Vect3D(0., 0., dist)));
  mdl.addMass("ground6", new Ground3D(1, new Vect3D(0., 0., -dist)));

  mdl.addInteraction("spring1", new SpringDamper3D(dist, k, z), "mass", "ground1");
  mdl.addInteraction("spring2", new SpringDamper3D(dist, k*0.9, z), "mass", "ground2");
  mdl.addInteraction("spring3", new SpringDamper3D(dist, k*2, z), "mass", "ground3");
  mdl.addInteraction("spring4", new SpringDamper3D(dist, k*2.1, z), "mass", "ground4");
  mdl.addInteraction("spring5", new SpringDamper3D(dist, k*1.5, z), "mass", "ground5");
  mdl.addInteraction("spring6", new SpringDamper3D(dist, k*1.2, z), "mass", "ground6");
  
  mdl.addInOut("drive",new Driver3D(),"mass");
  
  mdl.init(); 
  
  /* Group modules into subsets for parameter modifications */
  mdl.createMassSubset("massmod");
  mdl.addMassToSubset("mass","massmod");
  
  mdl.createInteractionSubset("X_springs");
  mdl.addInteractionToSubset("spring1","X_springs");
  mdl.addInteractionToSubset("spring2","X_springs");
  
  mdl.createInteractionSubset("Y_springs");
  mdl.addInteractionToSubset("spring3","Y_springs");
  mdl.addInteractionToSubset("spring4","Y_springs");
  
  mdl.createInteractionSubset("Z_springs");
  mdl.addInteractionToSubset("spring5","Z_springs");
  mdl.addInteractionToSubset("spring6","Z_springs");
  
  mdl.init(); 
}

void draw() {
  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(0);
  stroke(255);
  
  /* Calculate Physics */
  mdl.compute();
  
  /* Draw the mass and the springs */
  PVector pos = mdl.getMass("mass").getPos().toPVector();
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



void printModelState(){
  
  println("---");
  println("Population of the physical model:");
  
  //for (int i= 0; i < mdl.getNbOfMasses();i++){
  //  print("Mat at index " + i +":\t");
  //  print(mdl.getMatNameAt(i) +"\ttype: " + mdl.getMatTypeAt(i) +"\t");
  //  println("Mass = " + mdl.getMatMassAt(i) +", ");
  //}
  
  //for (int i= 0; i < mdl.getNbOfLinks();i++){
  //  print("Link at index " + i +":\t");
  //  print(mdl.getLinkNameAt(i) +"\ttype: " + mdl.getLinkTypeAt(i) +"\t");
  //  print("Stiffness = " + mdl.getLinkStiffnessAt(i) +", ");
  //  println("Damping = " + mdl.getLinkDampingAt(i));
  //}
  println("---");

}

void keyPressed() {
  // Trigger a random force on the mass module
  if (key == ' ')
    for(Driver3D driver : mdl.getDrivers())
      driver.applyFrc(new Vect3D(random(-5,5),random(-5,5),random(-5,5)));  // randomly modify the inertia of the mass module
  if (key == 'a'){
    m = random(1.0, 20);
    mdl.setParamForMassSubset(param.MASS, m, "massmod");
  }
  if (key == 'z'){
    k = random(0.000001, 0.1);
    mdl.setParamForInteractionSubset(param.STIFFNESS, k, "X_springs");
    z = random(0.001, 0.1);
    mdl.setParamForInteractionSubset(param.DAMPING, z, "X_springs");
  }
  if (key == 'e'){
    k2 = random(0.000001, 0.1);
    mdl.setParamForInteractionSubset(param.STIFFNESS, k2, "Y_springs");
    z2 = random(0.001, 0.1);
    mdl.setParamForInteractionSubset(param.DAMPING, z2, "Y_springs");
  }
  if (key == 'r'){
    k3 = random(0.000001, 0.1);
    mdl.setParamForInteractionSubset(param.STIFFNESS, k3, "Z_springs");
    z3 = random(0.001, 0.1);
    mdl.setParamForInteractionSubset(param.DAMPING, z3, "Z_springs");
  }
  if (key == 'w'){
    printModelState();
  }
}
