import java.util.Arrays;
import ddf.minim.UGen;

import miPhysics.*;

/* Phyiscal parameters for the model */
float m = 1.0;
float k = 0.2;
float z = 0.0001;

// slight pre-strain on the beam by using a shorter l0
float l0 = 20;

// spacing between the masses, imposed by the fixed points at each end
float dist = 25;

float fric = 0.00001;
float grav = 0.;

int dimX = 25;
int dimY = 2;
int dimZ = 2;

boolean triggerForceRamp = false;
float forcePeak = 10;

float frc = 0;
float frcRate = 0.01;


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

    this.mdl = new PhysicalModel(sampleRate, (int)baseFrameRate);
    mdl.setGravity(grav);
    mdl.setFriction(fric);

    audioOut = 0;
    audioRamp = 0;


    generateVolume(mdl, dimX, dimY, dimZ, "mass", "spring", m, l0, dist, k, z);

    listeningPoint = "mass85";
    excitationPoint = "mass5";

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

      this.mdl.computeStep();
      
      if (audioRamp < 1)
        audioRamp +=0.00001;

      // Triggered force (for "plucking")
      if(triggerForceRamp){
        frc = frc + frcRate * 0.1;
        simUGen.mdl.triggerForceImpulse(excitationPoint,0,frc,0);

        if (frc > forcePeak){
          triggerForceRamp = false;
          frc = 0;
        }
      }

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
