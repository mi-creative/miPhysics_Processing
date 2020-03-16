import java.util.Arrays;
import ddf.minim.UGen;

import miPhysics.*;

int dimX = 3;
int dimY = 2;
int dimZ = 10;
int overlap = 3;
double grav = 0.000004;

public class PhyUGen extends UGen
{

  private float    oneOverSampleRate;

  float[] audioOut ={0, 0};

  PhysicalModel mdl;
  Driver3D driver;

  public PhyUGen(int sampleRate)
  {
    super();

    this.mdl = new PhysicalModel(sampleRate, (int)baseFrameRate);
    mdl.setGlobalGravity(0,0,0);
    mdl.setGlobalFriction(0.00001);

    TopoGenerator q = new TopoGenerator(mdl, "mass", "spring");
    q.setDim(dimX, dimY, dimZ, overlap);
    q.setParams(1, 0.006, 0.00003);
    q.setGeometry(25, 25);    
    q.setTranslation(0, 0, 3);
    q.setMassRadius(3);
    q.generate();
    
    int i = 0;
    for(Mass m : mdl.getMassList()){
      mdl.addInteraction("plane"+i++, new PlaneContact3D(0.1, 0.05, 2, 0), m);
    }
    
    mdl.addInOut("list1", new Observer3D(filterType.HIGH_PASS), "mass_" + (dimX/2)+ "_" + (dimY/2) + "_" + (dimZ-1));
    mdl.addInOut("list2", new Observer3D(filterType.HIGH_PASS), "mass_" + (dimX/2)+ "_" + (dimY/2) + "_" + 0);
    
    driver = mdl.addInOut("driver", new Driver3D(), "mass_" + (dimX/2)+ "_" + (dimY/2) + "_" + (dimZ/2));

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
    
    ArrayList<Observer3D> listeners = mdl.getObservers();
    for(int i = 0; i < listeners.size(); i++){
      audioOut[i] =(float)(listeners.get(i).observePos().x)* 0.1
          + (float)(listeners.get(i).observePos().y)* 0.1
          + (float)(listeners.get(i).observePos().z)* 0.1;
      channels[i] = audioOut[i];

    }
    currAudio = audioOut[0];
  }
}
