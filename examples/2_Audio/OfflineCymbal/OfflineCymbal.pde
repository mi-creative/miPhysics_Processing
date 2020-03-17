
import peasy.*;
import miPhysics.Engine.*;
import miPhysics.ModelRenderer.*;

int displayRate = 90;

int DIM = 40;
double dist = 10;

PeasyCam cam;

PhysicalModel mdl;
Driver3D driver;
Observer3D listener;

ModelRenderer renderer;

import beads.*;
WavFileReaderWriter audioWriter;


int audioRate = 44100;
float audioData[][];

int index = 0;
float maxSample = 0;
int recTime = 10;


double grav = 0.001;

void setup() {

  size(1000, 700, P3D);

  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);
  cam.rotateX(radians(-90));
  cam.setDistance(700);
  
  audioData = new float[1][recTime*audioRate];
  audioWriter = new WavFileReaderWriter();


  background(0);

  mdl = new PhysicalModel(1000, displayRate);

  mdl.setGlobalGravity(0, 0, 0);
  mdl.setGlobalFriction(0.0000);

  ArrayList<ArrayList<Mass>> modHolder = new ArrayList<ArrayList<Mass>>();
  
  

  double radius = (DIM/2)*dist; 
  Vect3D center = new Vect3D(dist*DIM/2, dist*DIM/2, 0);

  generateMesh(mdl, DIM, DIM, "osc", "spring", 1., dist, 0.12, 0.04);
    
  ArrayList<Mass> toRemove = new ArrayList<Mass>();

  for(Mass m: mdl.getMassList()){
    if(m.getPos().dist(center) > radius)
      toRemove.add(m);
  }

  for (Mass m : toRemove)
    mdl.removeMassAndConnectedInteractions(m);

  mdl.addMass("perc", new Osc3D(10, 25, 0.00001, 0.01, new Vect3D(DIM/3*dist, DIM/3*dist, 150)), new Medium(0, new Vect3D(0, 0, 0))); 
  driver = mdl.addInOut("drive", new Driver3D(), "perc");

  for (int i = 0; i < mdl.getNumberOfMasses()-1; i++) {
    if(mdl.getMassList().get(i) != null){
      println(mdl.getMassList().get(i).getName());
      mdl.addInteraction("col_"+i, new Contact3D(0.1, 0.01), "perc", mdl.getMassList().get(i).getName());
    }
  }
  
  listener = mdl.addInOut("listener", new Observer3D(filterType.HIGH_PASS), mdl.getMass("osc10_10"));


  mdl.init();

  renderer = new ModelRenderer(this);
  renderer.displayMasses(true);
  renderer.setColor(interType.SPRINGDAMPER3D, 180, 10, 10, 170);
  renderer.setStrainGradient(interType.SPRINGDAMPER3D, true, 15);
  renderer.setStrainColor(interType.SPRINGDAMPER3D, 255, 250, 255, 255);

  frameRate(displayRate);
} 

// DRAW: THIS IS WHERE WE RUN THE MODEL SIMULATION AND DISPLAY IT

void draw() {
  
  for(int i = 0; i < 100; i++){
    
    mdl.computeSingleStep();
    
    float audioSamp = (float)(listener.observePos().z);
    if (abs(audioSamp) > maxSample)
      maxSample = abs(audioSamp);
      
    if(index < recTime*audioRate){
      audioData[0][index] = audioSamp;
      index++;
    }
    else{
      exit();
    }
  }

  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);

  background(0);
  fill(255);

  renderer.renderModel(mdl);
  
  cam.beginHUD();
  stroke(125,125,255);
  strokeWeight(2);
  fill(0,0,60, 220);
  rect(0,0, width, 50);
  textSize(16);
  fill(255, 255, 255);
  text("Recorded audio : " + (float)index / (float)audioRate + " seconds", 10, 30);
  cam.endHUD();
}


void keyPressed() {

  if (key == 'a') {
    for (Driver3D d : mdl.getDrivers())
      d.applyFrc(new Vect3D(0, 0, -20));
  }
}





// On exiting the Processing Sketch: write audio data to the sound files
void exit() {
  

  AudioFileType type = AudioFileType.WAV;
  SampleAudioFormat saf =  new SampleAudioFormat(
    44100, 
    16, 
    1, 
    true, 
    true);
  println(audioWriter.getSupportedFileTypesForWriting());

  // Normalise audio
  float invMax = 1.0/maxSample;
  for (int i = 0; i < recTime*audioRate; i++) {
    audioData[0][i] *= invMax;
  }

  try {
    audioWriter.writeAudioFile(audioData, sketchPath()+"/model_output.wav", type, saf);

  } 
  catch (IOException ex) {
    println("Oh no.");
  }
  catch (OperationUnsupportedException ex) {
    println("Oh no.");
  }
  catch (FileFormatException ex) {
    println("Oh no.");
  }
  super.exit();
} 







void generateMesh(PhysicalModel mdl, int dimX, int dimY, String mName, String lName, double masValue, double dist,double K, double Z) {
  // add the masses to the model: name, mass, initial pos, init speed
  String masName;
  Vect3D X0;

  for (int i = 0; i < dimY; i++) {
    for (int j = 0; j < dimX; j++) {
      masName = mName + j +"_"+ i;
      X0 = new Vect3D((float)j*dist,(float)i*dist, 0.);
      if((i==dimY/2) && (j == dimX/2))
        mdl.addMass(masName, new Ground3D(1, X0));
      else
        mdl.addMass(masName, new Mass1D(masValue, 10, X0));
    }
  }
  // add the spring to the model: length, stiffness, connected mats
  String masName1, masName2;

    for (int i = 0; i < dimX; i++) {
      for (int j = 0; j < dimY-1; j++) {
        masName1 = mName + i +"_"+ j;
        masName2 = mName + i +"_"+ str(j+1);
        mdl.addInteraction(lName + "1_" +i+"_"+j, new SpringDamper3D(dist*0.1, K, Z), masName1, masName2);
      }
    }
    
    for (int i = 0; i < dimX-1; i++) {
      for (int j = 0; j < dimY; j++) {
        masName1 = mName + i +"_"+ j;
        masName2 = mName + str(i+1) +"_"+ j;
        mdl.addInteraction(lName + "2_" +i+"_"+j, new SpringDamper3D(dist*0.1, K, Z), masName1, masName2);
      }
    }
}
