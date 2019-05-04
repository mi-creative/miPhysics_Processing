import java.util.Arrays;
import ddf.minim.UGen;

import miPhysics.*;

/* Phyiscal parameters for the model */
float m = 1.0;
float k = 0.2;
float z = 0.0001;
float l0 = 25;
float dist = 25;
float fric = 0.00001;
float grav = 0.;

int dimX = 30;
int dimY = 2;
int dimZ = 2;

boolean triggerForceRamp = false;
float forcePeak = 10;

float frc = 0;
float frcRate = 0.01;

int listeningPoint = 15;
int excitationPoint = 10;



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


    generateVolume(mdl, dimX, dimY, dimZ, "mass", "spring", m, l0, dist, k, z);

    listeningPoint = "mass15";

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

      // Triggered force (for "plucking")

      if(triggerForceRamp){
        frc = frc + frcRate * 0.1;
        simUGen.mdl.triggerForceImpulse("mass28",0,frc,0);

        if (frc > forcePeak){
          triggerForceRamp = false;
          frc = 0;
        }
      }


      // calculate the sample value
      if (simUGen.mdl.matExists(listeningPoint)) {
        sample =(float)(this.mdl.getMatPosition(listeningPoint).x)* 0.1
               + (float)(this.mdl.getMatPosition(listeningPoint).y)* 0.1
               + (float)(this.mdl.getMatPosition(listeningPoint).z)* 0.1;

        /* High pass filter to remove the DC offset */
        audioOut = sample - prevSample + 0.95 * audioOut;
        prevSample = sample;
      } else
        sample = 0;
    }
    Arrays.fill( channels, audioOut );
    currAudio = audioOut;
  }
}
