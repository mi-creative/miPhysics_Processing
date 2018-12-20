import java.util.Arrays;
import ddf.minim.UGen;

import miPhysics.*;

/* haptic parameters */
int ewma_smooth = 30;

/* Phyiscal parameters for the model */
float fric = 0.00002;
float grav = 0.;

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
    mdl.setGravity(0.000);
    mdl.setFriction(fric);

    audioOut = 0;

    this.mdl.addHapticInput3D("hapticMass", new Vect3D(0, -1, 0.), 30);    

    int nbmass = 30;

    float Ypos = 0;

    this.mdl.addGround3D("gnd0_0", new Vect3D(0., Ypos, 0.000));
    for (int i= 0; i< nbmass; i++)
      this.mdl.addMass2DPlane("str0_"+i, 1, new Vect3D(0.1*(i+1), Ypos, 0.000), new Vect3D(0., 0.0, 0.));
    this.mdl.addGround3D("gnd0_1", new Vect3D(0.1*(nbmass+1), Ypos, 0.000));
    for (int i= 0; i< nbmass-1; i++)
      this.mdl.addSpringDamper3D("sprd"+i, 0.04, 0.3, 0.004, "str0_"+i, "str0_"+(i+1));
    this.mdl.addSpringDamper3D("sprdg0", 0.04, 0.3, 0.004, "gnd0_0", "str0_0");
    this.mdl.addSpringDamper3D("sprdg1", 0.04, 0.3, 0.004, "gnd0_1", "str0_"+(nbmass-1));

    for (int i= 0; i< nbmass; i++)
      this.mdl.addContact3D("col", 0.4, 0.003, 0.001, "hapticMass", "str0_"+i);

    Ypos = 1;

    this.mdl.addGround3D("gnd1_0", new Vect3D(0., Ypos, 0.000));
    for (int i= 0; i< nbmass; i++)
      this.mdl.addMass2DPlane("str1_"+i, 1, new Vect3D(0.1*(i+1), Ypos, 0.), new Vect3D(0., 0.0, 0.));
    this.mdl.addGround3D("gnd1_1", new Vect3D(0.1*(nbmass+1), Ypos, 0.));
    for (int i= 0; i< nbmass-1; i++)
      this.mdl.addSpringDamper3D("sprd"+i, 0.02, 0.1, 0.004, "str1_"+i, "str1_"+(i+1));
    this.mdl.addSpringDamper3D("sprdg0", 0.02, 0.1, 0.004, "gnd1_0", "str1_0");
    this.mdl.addSpringDamper3D("sprdg1", 0.02, 0.1, 0.004, "gnd1_1", "str1_"+(nbmass-1));

    for (int i= 0; i< nbmass; i++)
      this.mdl.addContact3D("col", 0.4, 0.003, 0.001, "hapticMass", "str1_"+i);

    Ypos = 2.;  

    this.mdl.addGround3D("gnd2_0", new Vect3D(0., Ypos, 0.000));
    for (int i= 0; i< nbmass; i++)
      this.mdl.addMass2DPlane("str2_"+i, 1, new Vect3D(0.1*(i+1), Ypos, 0.000), new Vect3D(0., 0.0, 0.));
    this.mdl.addGround3D("gnd2_1", new Vect3D(0.1*(nbmass+1), Ypos, 0.000));
    for (int i= 0; i< nbmass-1; i++)
      this.mdl.addSpringDamper3D("sprd"+i, 0.01, 0.5, 0.004, "str2_"+i, "str2_"+(i+1));
    this.mdl.addSpringDamper3D("sprdg0", 0.01, 0.5, 0.004, "gnd2_0", "str2_0");
    this.mdl.addSpringDamper3D("sprdg1", 0.01, 0.5, 0.004, "gnd2_1", "str2_"+(nbmass-1));

    for (int i= 0; i< nbmass; i++)
      this.mdl.addContact3D("col", 0.3, 0.006, 0.001, "hapticMass", "str2_"+i); 

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
      sample =(float)(this.mdl.getMatPosition("str0_15").y* 1.)+
        (float)(this.mdl.getMatPosition("str1_13").y* 1.)+
        (float)(this.mdl.getMatPosition("str2_12").y* 1.2);

      /* High pass filter to remove the DC offset */
      audioOut = sample - prevSample + 0.95 * audioOut;
      prevSample = sample;

      Arrays.fill( channels, audioOut );
      currAudio = audioOut;
    }
  }
}
