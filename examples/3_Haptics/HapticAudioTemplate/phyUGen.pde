import java.util.Arrays;
import ddf.minim.UGen;

import miPhysics.*;

float fric = 0.;

/* haptic parameters */
int ewma_smooth = 30;


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

    /* create the rest of the model here! */

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

      /* listen to something from the model here ! */
      sample = 0;

      /* High pass filter to remove the DC offset */
      audioOut = sample - prevSample + 0.95 * audioOut;
      prevSample = sample;

      Arrays.fill( channels, audioOut );
      currAudio = audioOut;
    }
  }
}
