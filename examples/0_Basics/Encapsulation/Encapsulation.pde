/*
Model: Hello Mass
Author: James Leonard (james.leonard@gipsa-lab.fr)

A physical equivalent to a Hello World program!

We create a mass, and attach it to six fixed points with spring-dampers.
We then simulate the model, and can trigger forces on the mass by 
hitting the space bar.
*/

import miPhysics.Engine.*;
import miPhysics.Renderer.*;

import peasy.*;
PeasyCam cam;

int displayRate = 90;

float m = 1.0;
float k = 0.001;
float z = 0.01;
float dist = 70;

PhysicsContext phys;
ModelRenderer renderer;

boolean showInstructions = true;


void setup() {
  frameRate(displayRate);
  //size(1000, 700, P3D);
  fullScreen(P3D);
  cam = new PeasyCam(this, 300);
  cam.setMinimumDistance(100);
  cam.setMaximumDistance(1500);
  cam.rotateY(PI/2);
  cam.rotateX(PI/12);
  
  phys = new PhysicsContext(300, displayRate);
  
  // Build some top level elements... this is the same as the HelloMass example
  
  phys.mdl().addMass("mass", new Mass3D(m, 15, new Vect3D(0., 0., 0.), new Vect3D(0., 0., 0.)));
  phys.mdl().addMass("ground1", new Ground3D(1, new Vect3D(dist, 0., 0.)));
  phys.mdl().addMass("ground2", new Ground3D(1, new Vect3D(-dist, 0., 0.)));
  phys.mdl().addMass("ground3", new Ground3D(1, new Vect3D(0., dist, 0.)));
  phys.mdl().addMass("ground4", new Ground3D(1, new Vect3D(0., -dist, 0.)));
  phys.mdl().addMass("ground5", new Ground3D(1, new Vect3D(0., 0., dist)));
  phys.mdl().addMass("ground6", new Ground3D(1, new Vect3D(0., 0., -dist)));
  phys.mdl().addInteraction("spring1", new SpringDamper3D(dist, k, z), "mass", "ground1");
  phys.mdl().addInteraction("spring2", new SpringDamper3D(dist, k*0.9, z), "mass", "ground2");
  phys.mdl().addInteraction("spring3", new SpringDamper3D(dist, k*2, z), "mass", "ground3");
  phys.mdl().addInteraction("spring4", new SpringDamper3D(dist, k*2.1, z), "mass", "ground4");
  phys.mdl().addInteraction("spring5", new SpringDamper3D(dist, k*1.5, z), "mass", "ground5");
  phys.mdl().addInteraction("spring6", new SpringDamper3D(dist, k*1.2, z), "mass", "ground6");
  phys.mdl().addInOut("drive",new Driver3D(),"mass");
  
  // Define a specific medium (gravity and air friction) - after all, why not...
  Medium med = new Medium(0.0001, new Vect3D(0, -0.01,0.0));
  
  // Build an encapsulated macro element.
  miString mac = new miString("str1", med, 30, 2, 0.01, 0.001, 0.0001, 10, 3);
  mac.changeToFixedPoint("m_29");
  mac.rotate(0,PI/4,0);
  
  // And another...
  PhyModel mac2 = new miString("str2", med, 37, 2, 0.01, 0.001, 0.0001, 8, 3);
  mac2.changeToFixedPoint("m_36");
  mac2.rotate(0,3*PI/4,0);
 
  // And another ! For this one, we create a string, then add an extra pendulum.
  PhyModel mac3 = new miString("str3", med, 30, 2, 0.01, 0.001, 0.0001, 8, 3);
  mac3.rotate(0,0,0);
  mac3.translate(100,0,0);
  mac3.addMass("bigMass", new Mass3D(0.05, 30, new Vect3D(100, 100, 100)));
  mac3.addInteraction("sp", new SpringDamper3D(100,0.001, 0.001), "bigMass", "m_10");
 

  // Add the macro elements to the top-level physics scene
  phys.mdl().addPhyModel(mac);
  phys.mdl().addPhyModel(mac2);
  phys.mdl().addPhyModel(mac3);
  
  
  // Now let's add connections between the top level model and encapsulated models !
  
  // We can either directly give the module references to the addInteraction method...
  /*
  phys.mdl().addInteraction("sp", new SpringDamper3D(0,0.001, 0.001), phys.mdl().getMass("mass"), mac.getMass("m_0"));
  phys.mdl().addInteraction("sp2", new SpringDamper3D(0,0.001, 0.001), phys.mdl().getMass("mass"), mac2.getMass("m_0"));
  phys.mdl().addInteraction("sp3", new SpringDamper3D(0,0.001, 0.001), mac.getMass("m_10"), mac3.getMass("m_0"));
  phys.mdl().addInteraction("sp4", new SpringDamper3D(0,0.001, 0.001), mac2.getMass("m_20"), mac3.getMass("m_19"));
  */
  
  //Or use an "OSC-like" naming pattern.
  phys.mdl().addInteraction("sp", new SpringDamper3D(0,0.001, 0.001), "mass", "str1/m_0");
  phys.mdl().addInteraction("sp2", new SpringDamper3D(0,0.001, 0.001), "mass", "str2/m_0");
  phys.mdl().addInteraction("sp3", new SpringDamper3D(0,0.001, 0.001), "str1/m_10", "str3/m_0");
  phys.mdl().addInteraction("sp4", new SpringDamper3D(0,0.001, 0.001), "str2/m_20", "str3/m_19");
  
  
  phys.init(); 
  
  renderer = new ModelRenderer(this);
  renderer.setZoomVector(1,1,1);
  renderer.displayObjectVolumes(true);
}

void draw() {
  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(0);
  stroke(255);
  
  if(showInstructions)
    displayModelInstructions();
  
  phys.computeScene();
  renderer.renderScene(phys);
}

/* Trigger random forces on the mass */
void keyPressed() {
  switch(key){
    case ' ':
      for(Driver3D driver : phys.mdl().getDrivers())
        driver.applyFrc(new Vect3D(random(-5,5),random(-5,5),random(-5,5)));
      break;
    case 'h':
      showInstructions = ! showInstructions;
      break;
    case 'a':
      phys.mdl().getPhyModel("str3").removeMassAndConnectedInteractions("m_11");
      break;
    case 'z':
      phys.mdl().removeInteraction("sp2");
      break;
    case 'i':
      renderer.toggleModuleNameDisplay();
      break;
    case 'v':
      renderer.toggleIntersectionVolumesDisplay();
      break;
    case 'o':
      renderer.toggleObjectVolumesDisplay();
      break;
  }
}



void displayModelInstructions(){
  cam.beginHUD();
  textMode(MODEL);
  textSize(16);
  fill(255, 255, 255);
  text("Press the space bar to trigger random forces on the big mass", 10, 30);
  text("Press 'a' to remove an mass from the third string", 10, 55);
  text("Press 'z' to remove an interaction coupling the big mass to the second string", 10, 80);
  text("Press 'o' to toggle Object volume display", 10, 105);
  text("Press 'h' to hide help", 10, 130);
  text("FrameRate : " + frameRate, 10, 155);
  cam.endHUD();
}
