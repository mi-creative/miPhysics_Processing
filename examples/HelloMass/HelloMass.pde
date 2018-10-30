/*
Model: Hello Mass
Author: James Leonard (james.leonard@gipsa-lab.fr)

A physical equivalent to a Hello World program!

We create a mass, and attach it to six fixed points with spring-dampers.
We then simulate the model, and can trigger forces on the mass by 
hitting the space bar.
*/

import physicalModelling.*;
import peasy.*;
PeasyCam cam;

int displayRate = 90;

float m = 1.0;
float k = 0.001;
float z = 0.01;
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
  mdl.addSpringDamper3D("spring2", dist, k*0.9, z, "mass", "ground2"); 
  mdl.addSpringDamper3D("spring3", dist, k*2, z, "mass", "ground3"); 
  mdl.addSpringDamper3D("spring4", dist, k*2.1, z, "mass", "ground4"); 
  mdl.addSpringDamper3D("spring5", dist, k*1.5, z, "mass", "ground5"); 
  mdl.addSpringDamper3D("spring6", dist, k*1.6, z, "mass", "ground6"); 
  
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
}

/* Trigger random forces on the mass */
void keyPressed() {
  if (key == ' ')
    mdl.triggerForceImpulse("mass",random(-5,5),random(-5,5),random(-5,5));
}