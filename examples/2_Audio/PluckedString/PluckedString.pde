import peasy.*;

import miPhysics.Renderer.*;
import miPhysics.Engine.*;
import miPhysics.Engine.Sound.*;

/* Phyiscal parameters for the model */
float m = 1.0;
float k = 0.4;
float z = 0.01;
float l0 = 0.01;
float dist = 0.1;
float fric = 0.00003;
float grav = 0.;

float c_k = 0.01;
float c_z = 0.001;

int nbmass = 340;
int baseFrameRate = 60;
float currAudio = 0;

PeasyCam cam;

  PhysicalModel mdl; 
  Observer3D listener;
  PosInput3D input;
  ModelRenderer renderer;
  
  miPhyAudioClient audioStreamHandler;

  float audioOut = 0;
  int smoothing = 100;

///////////////////////////////////////

void setup()
{
  //size(1000, 700, P3D);
  fullScreen(P3D,1);
    cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(3500);
  

    this.mdl = new PhysicalModel(44100, (int)baseFrameRate);
    mdl.setGlobalGravity(0., 0, grav);
    mdl.setGlobalFriction(fric);
    
    input = this.mdl.addMass("percMass", new PosInput3D(1., new Vect3D(3, -4, 0.), smoothing));
    
    this.mdl.addMass("gnd0", new Ground3D(0.3, new Vect3D(- dist * nbmass/2, 0, 0.)));
    this.mdl.addInteraction("colg0", new Contact3D(c_k, c_z), "percMass", "gnd0");
    
    for (int i= 0; i< nbmass; i++){
      this.mdl.addMass("str"+i, new Mass2DPlane(m, 0.1, new Vect3D(dist*(i+1 - nbmass/2), 0., 0.)));
      this.mdl.addInteraction("col"+i, new Contact3D(c_k, c_z), "percMass", "str"+i);
    }
    this.mdl.addMass("gnd1", new Ground3D(0.3, new Vect3D(dist*(nbmass+1 - nbmass/2), 0, 0.)));
    this.mdl.addInteraction("colg1", new Contact3D(c_k, c_z), "percMass", "gnd1");

    this.mdl.addInteraction("sprdg0", new SpringDamper3D(l0, k, z), "str0", "gnd0");
    for (int i= 0; i< nbmass-1; i++)
      this.mdl.addInteraction("sprd"+i, new SpringDamper3D(l0, k, z), "str"+i, "str"+(i+1));
    this.mdl.addInteraction("sprdg1", new SpringDamper3D(l0, k, z), "str"+(nbmass-1), "gnd1");

    this.listener = this.mdl.addInOut("obs1", new Observer3D(filterType.HIGH_PASS), "str5");
        this.listener = this.mdl.addInOut("obs2", new Observer3D(filterType.HIGH_PASS), "str130");


    this.mdl.init();
  
  renderer = new ModelRenderer(this);  
  renderer.setZoomVector(100,100,100);  
  renderer.displayMasses(true);  
  renderer.setColor(massType.MASS2DPLANE, 140, 140, 40);
  renderer.setColor(interType.SPRINGDAMPER3D, 135, 70, 70, 255);
  renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 0.1);
  renderer.setStrainColor(interType.SPRINGDAMPER3D, 105, 100, 200, 255);
  
  audioStreamHandler = miPhyAudioClient.miPhyClassic(44100, 128, 0, 2, mdl);
  audioStreamHandler.setListenerAxis(listenerAxis.Y);
  audioStreamHandler.start();
    
  cam.setDistance(500);  // distance from looked-at point
  
  frameRate(baseFrameRate);

}

void draw()
{
  noCursor();
  background(0,0,25);

  directionalLight(126, 126, 126, 100, 0, -1);
  ambientLight(182, 182, 182);
  
  float x = 40 * (float)mouseX / width - 20;
  float y = 30 * (float)mouseY / height - 15;
  input.drivePosition(new Vect3D(x, y, 0));

  renderer.renderModel(mdl);

  cam.beginHUD();
  stroke(125,125,255);
  strokeWeight(2);
  fill(0,0,60, 220);
  rect(0,0, 250, 50);
  textSize(16);
  fill(255, 255, 255);
  text("Curr Audio: " + currAudio, 10, 30);
  cam.endHUD();
  
  //println(frameRate);

}

/*
void exit(){
  audioStreamHandler.shutdown();
}
*/
