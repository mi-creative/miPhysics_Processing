import java.util.Arrays;
import ddf.minim.UGen;
import miPhysics.*;

int dimX = 22;
int dimY = 13;

float fric = 0.00001;

int maxListeningPt;

public class PhyUGen extends UGen
{
  private float    oneOverSampleRate;

  PhysicalModel mdl;
  Driver3D d;


  // strat with ony one constructor for the function.
  public PhyUGen(int sampleRate /* any other arguments?*/)
  {
    super();

    this.mdl = new PhysicalModel(sampleRate, displayRate);
    mdl.setGlobalFriction(fric);

    gridSpacing = (int)((width/dimX));
 
    generateMesh(mdl, dimX, dimY, "osc", "spring", 1., gridSpacing, 0.12, 0.1);
    d = mdl.addInOut("driver", new Driver3D(), "osc0_0");
    mdl.addInOut("listener", new Observer3D(),"osc5_5");


    this.mdl.init();
  }

  /**
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
    float sample = 0;
    this.mdl.computeSingleStep();

    for(Observer3D obs: mdl.getObservers())
      sample += (float)obs.observePos().z * 0.01;
    
    Arrays.fill( channels, sample );
  }
    
}
