import java.util.Arrays;
import ddf.minim.UGen;

import miPhysics.*;

float currAudio = 0;
float gainVal = 1.;



public class PhyUGen extends UGen
{

  private String listeningPoint;
  private String excitationPoint;

  private float    oneOverSampleRate;

  float prevSample;
  float audioOut;
  float audioRamp;

  PhysicalModel mdl;

  public PhyUGen(int sampleRate)
  {
    super();

    this.mdl = new PhysicalModel(sampleRate, (int)displayRate);

    audioOut = 0;
    audioRamp = 0;

  selectInput("select the file you want to open","load");


    listeningPoint = "mass85";
    excitationPoint = "mass5";
    
    //loader.saveModel("BeamModel.xml", this.mdl);
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

      this.mdl.computeStep();
      
      if (audioRamp < 1)
        audioRamp +=0.00001;


      // calculate the sample value
      if (simUGen.mdl.matExists(listeningPoint)) {
        sample =(float)(this.mdl.getMatPosition(listeningPoint).x)* 0.015
               + (float)(this.mdl.getMatPosition(listeningPoint).y)* 0.015
               + (float)(this.mdl.getMatPosition(listeningPoint).z)* 0.015;

        /* High pass filter to remove the DC offset */
        audioOut = (sample - prevSample + 0.95 * audioOut) * audioRamp;;
        prevSample = sample;
      } else
        sample = 0;
    
    Arrays.fill( channels, audioOut );
    currAudio = audioOut;
  }
}
