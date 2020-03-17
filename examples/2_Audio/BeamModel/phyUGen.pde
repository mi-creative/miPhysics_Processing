import java.util.Arrays;
import ddf.minim.UGen;

import miPhysics.Engine.*;

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

int dimX = 45;
int dimY = 2;
int dimZ = 2;

boolean triggerForceRamp = false;
float forcePeak = 10;

float frc = 0;
float frcRate = 0.01;


public class PhyUGen extends UGen
{

  private float    oneOverSampleRate;
  float audioOut;
  PhysicalModel mdl;

  public PhyUGen(int sampleRate)
  {
    super();

    this.mdl = new PhysicalModel(sampleRate, (int)baseFrameRate);
    mdl.setGlobalGravity(0,0,grav);
    mdl.setGlobalFriction(fric);

    audioOut = 0;

    generateVolume(mdl, dimX, dimY, dimZ, "mass", "spring", m, 1, l0, dist, k, z);
    
    mdl.addInOut("driver", new Driver3D(), "mass5");
    mdl.addInOut("listener", new Observer3D(filterType.HIGH_PASS), "mass85");

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
      this.mdl.computeSingleStep();

      // Triggered force (for "plucking")
      if(triggerForceRamp){
        frc = frc + frcRate * 0.1;
        for(Driver3D d: mdl.getDrivers()){
          d.applyFrc(new Vect3D(0,frc,0));
        }

        if (frc > forcePeak){
          triggerForceRamp = false;
          frc = 0;
        }
      }

      audioOut = 0;
      for(Observer3D ob: mdl.getObservers()){
        audioOut += 0.015 * (ob.observePos().x + ob.observePos().y + ob.observePos().z);
      }
    
    Arrays.fill( channels, audioOut );
    currAudio = audioOut;
  }
}
