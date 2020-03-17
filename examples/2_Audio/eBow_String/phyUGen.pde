import java.util.Arrays;
import ddf.minim.UGen;

import miPhysics.Engine.*;


public class PhyUGen extends UGen
{
  private float    oneOverSampleRate;

  float audioOut = 0;
  int smoothing = 100;

  PhysicalModel mdl; 
  Observer3D listener;
  PosInput3D input;

  float m = 1.0;
  float k = 0.4;
  float z = 0.01;
  float l0 = 0.02;
  float dist = 0.1;

  float fric = 0.00003;
  float grav = 0.;

  float c_k = 0.0001;
  float c_z = -0.001;

  int nbmass = 240;


  public PhyUGen(int sampleRate)
  {
    super();

    this.mdl = new PhysicalModel(sampleRate, (int)baseFrameRate);
    mdl.setGlobalGravity(0., 0, grav);
    mdl.setGlobalFriction(fric);

    input = this.mdl.addMass("percMass", new PosInput3D(1., new Vect3D(3, -4, 0.), smoothing));

    this.mdl.addMass("gnd0", new Ground3D(0.3, new Vect3D(- dist * nbmass/2, 0, 0.)));
    this.mdl.addInteraction("colg0", new Contact3D(c_k, c_z), "percMass", "gnd0");

    for (int i= 0; i< nbmass; i++) {
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
    float x = 30 * (float)mouseX / width - 15;
    float y = 30 * (float)mouseY / height - 15;
    input.drivePosition(new Vect3D(x, y, 0));

    this.mdl.computeSingleStep();

    audioOut = (float)listener.observePos().y * 1.4;
    Arrays.fill( channels, audioOut );
    currAudio = audioOut;
  }
}
