import java.util.Arrays;
import ddf.minim.UGen;

import miPhysics.*;

int dimX = 35;
int overlap = 1;

double grav = 0.000004;

int nbStrings = 6;

public class PhyUGen extends UGen
{


  private float    oneOverSampleRate;

  float[] audioOut;
  float[] prevAudio;
  String[] listeners;

  PhysicalModel mdl;

  public PhyUGen(int sampleRate)
  {
    super();

    this.mdl = new PhysicalModel(sampleRate, (int)baseFrameRate);
    mdl.setGravity(0.);
    mdl.setFriction(0.00003);

    listeners = new String[nbStrings];
    audioOut = new float[nbStrings];
    prevAudio = new float[nbStrings];

    int len = dimX;

    for (int i = 0; i < nbStrings; i++) {

      TopoGenerator q = new TopoGenerator(mdl, ("str"+str(i)), "spring");


      q.setDim(len, 1, 1, overlap);
      q.setParams(1, 0.7, 0.05);
      q.setGeometry(10, 0.1);
      q.set2DPlane(true);
      q.setTranslation(-400, -600 + 130 * i, 0);
      q.addBoundaryCondition(Bound.X_LEFT);
      q.addBoundaryCondition(Bound.X_RIGHT);

      q.generate();

      // Calculate next string mength (approximately guitar tuning intervals)
      if (i == 1)
        len = round(len*pow(1.059463, 4));
      else
        len = round(len*pow(1.059463, 5));
      audioOut[i] = 0;
      prevAudio[i] = 0;
      listeners[i] = "str"+i+"_" + floor(dimX/3)+ "_" + 0 + "_" + 0;
    }
    for (int i = 0; i < nbStrings-1; i++) {
      for (int j = 0; j < nbStrings; j++) {
        if (i!=j)
          mdl.addSpring3D("damper"+i+"_"+j, 130*abs(j-i), 0.006, "str"+i+"_2_0_0", "str"+str(j)+"_2_0_0");
      }
    }

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


      // Triggered linear ramp forces (for "plucking")
      for (int i = 0; i < nbStrings; i++) {
        if (triggerForceRamp[i]) {
          frc[i] = frc[i] + frcRate[i] * 0.1;
          simUGen.mdl.triggerForceImpulse("str"+ i +"_" + (dimX/5 + 5 * i)+ "_0_0", 0, frc[i], 0);

          if (frc[i] > forcePeak[i]) {
            triggerForceRamp[i] = false;
            frc[i] = 0;
          }
        }
      }

      this.mdl.computeStep();

      audioOut[0] = 0;


      if (audioRamp < 1)
        audioRamp +=0.00001;

      float allAudio = 0;

      for (int i = 0; i < listeners.length; i++) {

        Vect3D listenPos = this.mdl.getMatPosition(listeners[i]);

        // calculate the sample value
        if (simUGen.mdl.matExists(listeners[i])) {
          sample = (float)(listenPos.y)* (0.01 - 0.001 * i);

          /* High pass filter to remove the DC offset */
          audioOut[i] = (sample - prevAudio[i] + 0.95 * audioOut[i]) * audioRamp;
          prevAudio[i] = sample;

          allAudio += audioOut[i];
        } else
          audioOut[0] = 0;
        channels[1] = allAudio;
        channels[0] = allAudio;
      }
    }
    currAudio = audioOut[0];
  }
}
