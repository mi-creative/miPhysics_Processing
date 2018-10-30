/*
Model: Tiny Wrecking Ball
Author: James Leonard (james.leonard@gipsa-lab.fr)

A chain of 3 masses attached to a fixed point.
The last mass is heavy and collides with a 2D Plane.
*/

import physicalModelling.*;
import peasy.*;

PeasyCam cam;
PhysicalModel mdl;

int displayRate = 60;

void setup() {
  frameRate(displayRate);
  
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(500);

  size(900, 450, P3D);
  background(0);

  // instantiate our physical model context
  mdl = new PhysicalModel(1050, displayRate);

  // some initial coordinates for the modules.
  Vect3D initPos = new Vect3D(300., 0., 200.);
  Vect3D initPos2 = new Vect3D(200., 0., 200.);
  Vect3D initPos3 = new Vect3D(100., 0., 200.);
  Vect3D initPos4 = new Vect3D(0., 0., 200.);
  Vect3D initV = new Vect3D(0., 0., 0.);

  mdl.setGravity(0.005);
  mdl.setFriction(0.005);

  mdl.addMass3D("mass1", 20.0, initPos, initV);
  mdl.addMass3D("mass2", 1.0, initPos2, initV);
  mdl.addMass3D("mass3", 1.0, initPos3, initV);
  mdl.addGround3D("ground1", initPos4);

  mdl.addRope3D("rope1", 100.0, 0.01,0.08, "mass1", "mass2");
  mdl.addRope3D("rope2", 100.0, 0.01,0.08, "mass2", "mass3");
  mdl.addRope3D("rope3", 100.0, 0.01,0.08, "mass3", "ground1");

  for(int i = 1; i <=3; i++)
    mdl.addPlaneInteraction("plane"+i, 50, 0.01, 0.1, 0, -160, "mass"+i);

  // initialise the model before starting calculations.
  mdl.init();
  
  cam.setDistance(500);  // distance from looked-at point
} 

void draw() {

  mdl.draw_physics();

  Vect3D pos1 = mdl.getMatPosition("mass1");
  Vect3D pos2 = mdl.getMatPosition("mass2");
  Vect3D pos3 = mdl.getMatPosition("mass3");
  Vect3D pos4 = mdl.getMatPosition("ground1");

  println("Mass 1 position: " + pos1);
  println("Mass 2 position: " + pos2);
  println("Mass 3 position: " + pos3);

  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);

  background(0);

  strokeWeight(1);
  drawGrid(40, 4);
  drawPlane(0, -160, 160); 

  noStroke();
  fill(190, 190, 125);
  drawSphere(pos1, 50);  
  drawSphere(pos2, 20);
  drawSphere(pos3, 20);  
  fill(0, 125, 125);
  drawSphere(pos4, 50);

  stroke(0, 255, 0);
  strokeWeight(5);
  drawLine(pos1, pos2);
  drawLine(pos2, pos3);
  drawLine(pos3, pos4);
}