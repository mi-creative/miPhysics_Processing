
import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;

int baseFrameRate = 60;

PeasyCam cam;

// Audio Output Variables Init
float currAudio = 0;
Minim minim;
PhyUGen simUGen;
Gain gain;
AudioOutput out;

ModelRenderer renderer;


///////////////////////////////////////

void setup()
{
  //size(1000, 700, P3D); //   Fullscreen option
  fullScreen(P3D); //    Or window option
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(5000);
  
  minim = new Minim(this);
  
  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut();
  
  // start the Gain at 0 dB, which means no change in amplitude
  gain = new Gain(0);
  
  // create a physicalModel UGEN
  simUGen = new PhyUGen(44100);
  // patch the Oscil to the output
  simUGen.patch(gain).patch(out);
  
  renderer = new ModelRenderer(this);
  
  renderer.setZoomVector(100,100,100);
  
  renderer.displayMats(true);
  renderer.setSize(matModuleType.Mass3D, 55);
  renderer.setColor(matModuleType.Mass3D, 140, 140, 40);
  renderer.setSize(matModuleType.Mass2DPlane, 5);
  renderer.setColor(matModuleType.Mass2DPlane, 120, 0, 140);
  renderer.setSize(matModuleType.Ground3D, 10);
  renderer.setColor(matModuleType.Ground3D, 30, 100, 100);
  
  renderer.setColor(linkModuleType.SpringDamper3D, 235, 120, 120, 255);
  renderer.setStrainGradient(linkModuleType.SpringDamper3D, true, 0.05);
  renderer.setStrainColor(linkModuleType.SpringDamper3D, 130, 130, 250, 255);
  
  cam.setDistance(500);  // distance from looked-at point
  
  frameRate(baseFrameRate);

}

void draw()
{
  background(255,255,255);

  directionalLight(126, 126, 126, 100, 0, -1);
  ambientLight(182, 182, 182);
  
  renderer.renderModel(simUGen.mdl);

  cam.beginHUD();
  stroke(125,125,255);
  strokeWeight(2);
  fill(0,0,60, 220);
  rect(0,0, 250, 50);
  textSize(16);
  fill(255, 255, 255);
  text("Curr Audio: " + currAudio, 10, 30);
  cam.endHUD();
}


void keyPressed() {
  
}

void keyReleased() {
  if (key == ' ')
  saveFrame("line-######.png");
}
