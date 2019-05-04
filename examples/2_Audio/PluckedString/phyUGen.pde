import java.util.Arrays;
import ddf.minim.UGen;

import miPhysics.*;

/* Phyiscal parameters for the model */
float m = 1.0;
float k = 0.4;
float z = 0.01;
float l0 = 0.02;
float dist = 0.1;
float fric = 0.00003;
float grav = 0.;

float c_dist = 0.5;
float c_gnd = 0.65;
float c_k = 0.07;
float c_z = 0.01;

float smooth = 0.01;
float x_avg=0, y_avg=0;

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
    
    this.mdl.addMass2DPlane("guideM1", 1000000000, new Vect3D(2,-4,0.), new Vect3D(0,2,0.));
    this.mdl.addMass2DPlane("guideM2", 1000000000, new Vect3D(4,-4,0.), new Vect3D(0,2,0.));
    this.mdl.addMass2DPlane("guideM3", 1000000000, new Vect3D(3,-3,0.), new Vect3D(0,2,0.)); 
    this.mdl.addMass3D("percMass", 100, new Vect3D(3,-4,0.), new Vect3D(0,2,0.));    
    this.mdl.addSpringDamper3D("test", 1, 1., 1., "guideM1", "percMass");
    this.mdl.addSpringDamper3D("test", 1, 1., 1., "guideM2", "percMass");
    this.mdl.addSpringDamper3D("test", 1, 1., 1., "guideM3", "percMass");
    
    int nbmass = 240;
    
    this.mdl.addGround3D("gnd0", new Vect3D(0.,0.,0.));
    for(int i= 0; i< nbmass; i++)
      this.mdl.addMass2DPlane("str"+i, m, new Vect3D(dist*(i+1),0.,0.), new Vect3D(0.,0.,0.));
    this.mdl.addGround3D("gnd1", new Vect3D(dist*(nbmass+1),0.,0.));
    for(int i= 0; i< nbmass-1; i++)
      this.mdl.addSpringDamper3D("sprd"+i, l0, k, z, "str"+i, "str"+(i+1));
    this.mdl.addSpringDamper3D("sprdg0", l0, k, z, "gnd0", "str0");
    this.mdl.addSpringDamper3D("sprdg1", l0, k, z, "gnd1", "str"+(nbmass-1));
    
    for(int i= 0; i< nbmass; i++)
      this.mdl.addContact3D("col", c_dist, c_k, c_z, "percMass", "str"+i);
    this.mdl.addContact3D("col", c_gnd, 10, c_z, "percMass", "gnd0");
    this.mdl.addContact3D("col", c_gnd, 10, c_z, "percMass", "gnd1");
  
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
