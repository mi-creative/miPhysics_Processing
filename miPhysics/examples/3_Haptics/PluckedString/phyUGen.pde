import java.util.Arrays;
import ddf.minim.UGen;

import miPhysics.*;

/* haptic parameters */
int ewma_smooth = 30;

/* Phyiscal parameters for the model */
float m = 1.0;
float k = 0.4;
float z = 0.01;
float l0 = 0.005;
float dist = 0.1;
float fric = 0.00001;
float grav = 0.;

float c_dist = 0.5;
float c_k = 0.01;
float c_z = 0.01;

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
  
    this.mdl.addHapticInput3D("hapticMass", new Vect3D(0,-1,0.), ewma_smooth);    
    
    int nbmass = 70;
    
    this.mdl.addGround3D("gnd0", new Vect3D(0.,0.,0.));
    for(int i= 0; i< nbmass; i++)
      this.mdl.addMass2DPlane("str"+i, m, new Vect3D(dist*(i+1),0.,0.), new Vect3D(0.,0.,0.));
    this.mdl.addGround3D("gnd1", new Vect3D(dist*(nbmass+1),0.,0.));
    for(int i= 0; i< nbmass-1; i++)
      this.mdl.addSpringDamper3D("sprd"+i, l0, k, z, "str"+i, "str"+(i+1));
    this.mdl.addSpringDamper3D("sprdg0", l0, k, z, "gnd0", "str0");
    this.mdl.addSpringDamper3D("sprdg1", l0, k, z, "gnd1", "str"+(nbmass-1));
    
    for(int i= 0; i< nbmass; i++)
      this.mdl.addContact3D("col", c_dist, c_k, c_z, "hapticMass", "str"+i);
  
    listeningPoint = "str4";

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

  @Override
  protected void uGenerate(float[] channels)
  {
    float sample;
    synchronized(lock) { 
                  
    this.mdl.computeStep();

    // calculate the sample value
    if(simUGen.mdl.matExists(listeningPoint)){
      sample =(float)(this.mdl.getMatPosition(listeningPoint).y)* 2.;
      
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
