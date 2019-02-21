import java.util.Arrays;
import ddf.minim.UGen;

import miPhysics.*;

/* Phyiscal parameters for the model */
/* The general approach her is to use general/homogeneus parameters for mass (m), stifness (k), internal viscosity (z)
/* dist is the value defining the distance between to mass modules when generating the structure
/* fric is the global external viscoty
/* l0 is the resting lenght for all interaction modules
/* grav is a general parameters of gravity
/* c_dist, c_gnd, c_k and c_z are the parameters of the interaction model and mass
*/ 
float m, k, z, dist, fric, l0, grav, c_dist, c_gnd, c_k, c_z;

public class PhyUGen extends UGen
{
  
  private String listeningPoint;

  private float    oneOverSampleRate;
  public ArrayList <PVector> modelPos;
  public ArrayList <PVector> modelVel;
  
  float prevSample;
  float audioOut;

  PhysicalModel mdl;

  public PhyUGen(int sampleRate)
  {
    super();

    this.mdl = new PhysicalModel(sampleRate, (int)baseFrameRate);
    mdl.setGravity(grav);
    mdl.setFriction(fric);

    audioOut = 0;
    
       
    // Just a good old beam
    m = 1.0; k = 0.3; z = 0.0001; dist = 0.24; fric = 0.00003; l0 = 0.3; grav = 0.; c_dist =0.6; c_gnd = 0.35; c_k = 0.03; c_z = 0.01; 
    generateVolume(this.mdl, 3, 30, 1, "mass", "spring", m, dist, k, z);
    listeningPoint = "mass20";
    
    // Metal Hurlant / 
    //m = 1.0; k = 0.35; z = 0.01; dist = 0.4; fric = 0.0003; l0 = 0.2; grav = 0.; c_dist = 1.8; c_gnd = 0.65; c_k = 0.07; c_z = -0.04;
    //generateVolume(this.mdl, 3, 40, 1, "mass", "spring", m, dist, k, z);
    //listeningPoint = "mass30";
    
    // Fat Woden Stick / 
    // m = 1.0; k = 0.35; z = 0.1; dist = 1.; fric = 0.0003; l0 = 0.2; grav = 0.; c_dist = .9; c_gnd = 0.65; c_k = 0.07; c_z = 0.04; 
    // generateVolume(this.mdl, 3, 40, 1, "mass", "spring", m, dist, k, z);
    // listeningPoint = "mass30";

    // Udu
    //m = 1.0; k = 0.39; z = 0.02; dist = 1.; fric = 0.0003; l0 = 0.2; grav = 0.; c_dist = 1.9; c_gnd = 0.65; c_k = 0.07; c_z = 0.04; 
    //generateVolume(this.mdl, 2, 10, 1, "mass", "spring", m, dist, k, z);
    //listeningPoint = "mass10";
    
    // Balafon
    //m = 1.0; k = 0.39; z = 0.02; dist = 1.; fric = 0.0003; l0 = 0.2; grav = 0.; c_dist = 1.9; c_gnd = 0.65; c_k = 0.07; c_z = 0.04; 
    //generateVolume(this.mdl, 3, 10, 1, "mass", "spring", m, dist, k, z);
    //listeningPoint = "mass20";
    
    // Tabla
    //m = 1.0; k = 0.39; z = 0.01; dist = 1.; fric = 0.0003; l0 = 0.2; grav = 0.; c_dist = 1.9; c_gnd = 0.65; c_k = 0.07; c_z = 0.04; 
    //generateVolume(this.mdl, 5, 20, 1, "mass", "spring", m, dist, k, z);
    //listeningPoint = "mass20";
    
    // Tiberian Crotals
    //m = 1.0; k = 0.39; z = 0.0001; dist = 1.; fric = 0.00003; l0 = 0.2; grav = 0.; c_dist = 1.9; c_gnd = 0.65; c_k = 0.07; c_z = 0.04; 
    //generateVolume(this.mdl, 20, 5, 1, "mass", "spring", m, dist, k, z);
    //listeningPoint = "mass30";
    
    // Cow Bell
    //m = 1.0; k = 0.35; z = 0.001; dist = 1.; fric = 0.003; l0 = 0.2; grav = 0.; c_dist = 1.9; c_gnd = 0.65; c_k = 0.07; c_z = 0.04;
    //generateVolume(this.mdl, 5, 20, 1, "mass", "spring", m, dist, k, z);
    //listeningPoint = "mass30";
    
    // Screaming Bitch
    //m = 1.0; k = 0.1; z = 0.00001; dist = 1.; fric = 0.000003; l0 = 0.2; grav = 0.; c_dist = 4.9; c_gnd = 0.65; c_k = 0.07; c_z = 0.04; 
    //generateVolume(this.mdl, 20, 5, 1, "mass", "spring", m, dist, k, z);
    //listeningPoint = "mass30";
    
    // Try and make it scream
    //m = 1.0; k = 0.35; z = 0.00001; dist = 1.; fric = 0.0003; l0 = 0.2; grav = 0.; c_dist = 6.9; c_gnd = 0.65; c_k = 0.07; c_z = 0.04; 
    //generateVolume(this.mdl, 2, 2, 1, "mass", "spring", m, dist, k, z);
    //listeningPoint = "mass3";

    
    this.mdl.addMass2DPlane("guideM1", 1000000000, new Vect3D(2,-4,0.), new Vect3D(0,2,0.));
    this.mdl.addMass2DPlane("guideM2", 1000000000, new Vect3D(4,-4,0.), new Vect3D(0,2,0.));
    this.mdl.addMass2DPlane("guideM3", 1000000000, new Vect3D(3,-3,0.), new Vect3D(0,2,0.)); 
    this.mdl.addMass3D("percMass", 100, new Vect3D(3,-4,0.), new Vect3D(0,2,0.));    
    this.mdl.addSpringDamper3D("test", 1, 1., 1., "guideM1", "percMass");
    this.mdl.addSpringDamper3D("test", 1, 1., 1., "guideM2", "percMass");
    this.mdl.addSpringDamper3D("test", 1, 1., 1., "guideM3", "percMass");
    
    for(int i= 1; i< mdl.getNumberOfMats()-4; i++)
    this.mdl.addContact3D("col", c_dist, c_k, c_z, "percMass", "mass"+i);
     

    this.mdl.init();
  }
  
  /*
   * This routine will be called any time the sample rate changes.
   */
  protected void sampleRateChanged()
  {
    oneOverSampleRate = 1 / sampleRate();
    this.mdl.setSimRate((int)sampleRate());
  }

  // Some variable dealing with mouse movement smoothing
  float smooth = 0.01;
  float x_avg=0, y_avg=0;
  
  @Override
  protected void uGenerate(float[] channels)
  {
    float sample;
    synchronized(lock) { 
      
    float x = 30*(float)mouseX / width - 15;
    float y = 30*(float)mouseY / height - 15;
    
    x_avg = (1-smooth) * x_avg + (smooth) * x;
    y_avg = (1-smooth) * y_avg + (smooth) * y;

    this.mdl.setMatPosition("guideM1",new Vect3D(x_avg-1, y_avg, 0));
    this.mdl.setMatPosition("guideM2",new Vect3D(x_avg+1, y_avg, 0));
    this.mdl.setMatPosition("guideM3",new Vect3D(x_avg, y_avg-1, 0));
    this.mdl.computeStep();

    // calculate the sample value
    if(simUGen.mdl.matExists(listeningPoint)){
      sample =(float)(this.mdl.getMatPosition(listeningPoint).y)* 1. +
              (float)(this.mdl.getMatPosition(listeningPoint).x)* 1.;;
      
      /* High pass filter to remove the DC offset */
      audioOut = sample - prevSample + 0.95 * audioOut;
      prevSample = sample;
    }
    else
      sample = 0;
    }
    Arrays.fill( channels, audioOut );
    currAudio = audioOut;
  }
}
