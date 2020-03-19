import java.util.Arrays;
import ddf.minim.UGen;

import miPhysics.Engine.*;




public class PhyUGen extends UGen
{

  private float    oneOverSampleRate;
  float audioOut;
  PhysicalModel mdl;

  public PhyUGen(int sampleRate)
  {
    super();


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
