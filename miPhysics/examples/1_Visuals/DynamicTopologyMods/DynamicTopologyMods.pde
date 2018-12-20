/*
Model: Dynamic Topology Modifications.
Author: James Leonard (james.leonard@gipsa-lab.fr)

Draw a 2D Mesh of Osc modules (mass-spring-ground systems).

Left-Click Drag across the surface to apply forces and create ripples.
Right-Click Drag across the surface to remove masses (and connected links).

Use UP and DOWN keys to add/decrease air friction in the model.
Use LEFT and RIGHT keys to zoom the Z axis.
*/
import miPhysics.*;
import peasy.*;
PeasyCam cam;


int displayRate = 60;
int dimX = 115;
int dimY = 65;

PhysicalModel mdl;

int mouseDragged = 0;

int gridSpacing = 2;
int xOffset= 0;
int yOffset= 0;

float fric = 0.001;

// SETUP: THIS IS WHERE WE SETUP AND INITIALISE OUR MODEL

void setup() {
  fullScreen(P3D);
  background(0);

  mdl = new PhysicalModel(550, displayRate);
  mdl.setGravity(0.000);
  mdl.setFriction(fric);
  
  gridSpacing = (int)((height/dimX)*2);
  generatePinScreen(mdl, dimX, dimY, "osc", "spring", 1., gridSpacing, 0.0006, 0.0, 0.09, 0.1);

  mdl.init();
  frameRate(displayRate);   

} 

// DRAW: THIS IS WHERE WE RUN THE MODEL SIMULATION AND DISPLAY IT

void draw() {

  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2, height/2.0, 0, 0, 1, 0);

  mdl.draw_physics();

  background(0);

  pushMatrix();
  translate(xOffset,yOffset, 0.);
  renderLinks(mdl);
  popMatrix();

  fill(255);
  textSize(13); 

  text("Friction: " + fric, 50, 50, 50);
  text("Zoom: " + zZoom, 50, 100, 50);

  
  if (mouseDragged == 1){
    if((mouseX) < (dimX*gridSpacing+xOffset) & (mouseY) < (dimY*gridSpacing+yOffset) & mouseX>xOffset & mouseY > yOffset){ // Garde fou pour ne pas sortir des limites du pinScreen
      println(mouseX, mouseY);
      if(mouseButton == LEFT)
        engrave(mouseX-xOffset, mouseY - yOffset);
      if(mouseButton == RIGHT)
        chisel(mouseX-xOffset, mouseY - yOffset);
    }
  }
 
}


void fExt(){
  String matName = "osc" + floor(random(dimX))+"_"+ floor(random(dimY));
  mdl.triggerForceImpulse(matName, random(100) , random(100), random(500));
}

void engrave(float mX, float mY){
  String matName = "osc" + floor(mX/ gridSpacing)+"_"+floor(mY/ gridSpacing);
  println(mdl.matExists(matName));
  if(mdl.matExists(matName))
    mdl.triggerForceImpulse(matName, 0. , 0., 15.);
}

void chisel(float mX, float mY){
  String matName = "osc" + floor(mX/ gridSpacing)+"_"+floor(mY/ gridSpacing);
  println(mdl.matExists(matName));
  if(mdl.matExists(matName))
    mdl.removeMatAndConnectedLinks(matName);
}


void mouseDragged() {
  mouseDragged = 1;
  
}

void mouseReleased() {
  mouseDragged = 0;
}



void keyPressed() {
  if (key == ' ')
  mdl.setGravity(-0.001);
  if(keyCode == UP){
    fric += 0.001;
    mdl.setFriction(fric);
    println(fric);

  }
  else if (keyCode == DOWN){
    fric -= 0.001;
    fric = max(fric, 0);
    mdl.setFriction(fric);
    println(fric);
  }
  else if (keyCode == LEFT){
    zZoom ++;
  }
  else if (keyCode == RIGHT){
    zZoom --;
  }
}

void keyReleased() {
  if (key == ' ')
  mdl.setGravity(0.000);
}