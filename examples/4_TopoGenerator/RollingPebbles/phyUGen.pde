import java.util.Arrays;
import ddf.minim.UGen;

import miPhysics.*;

int dimX = 4;
int dimY = 4;
int dimZ = 3;
int overlap = 2;


double grav = 0.000004;


public class PhyUGen extends UGen
{

  private String listeningPoint;

  private float    oneOverSampleRate;

  float prevSample;


  float[] audioOut ={0, 0};
  float[] prevAudio ={0, 0};
  Observer3D listeners[];


  PhysicalModel mdl;
  Driver3D driver;

  public PhyUGen(int sampleRate)
  {
    super();
    
    listeners = new Observer3D[2];

    this.mdl = new PhysicalModel(sampleRate, (int)baseFrameRate);
    mdl.setGlobalGravity(0, 0, 0.000004);
    mdl.setGlobalFriction(0.00001);


    TopoGenerator q = new TopoGenerator(mdl, "pebbleA", "springA");
    q.setDim(dimX, dimY, dimZ, overlap);
    q.setParams(1, 0.05, 0.0001);
    q.setGeometry(25, 25);
    q.setMassRadius(15);
    q.setTranslation(1, 1, 0);
    q.generate();

    q.conditionAlongSphere(40, true);
    q.conditionAlongSphere(20, false);

    int firstPebbleEnd = mdl.getNumberOfMasses();


    TopoGenerator q2 = new TopoGenerator(mdl, "pebbleB", "springB");
    q2.setDim(dimX, dimY, dimZ, overlap);
    q2.setParams(1, 0.05, 0.0001);
    q2.setGeometry(25, 25);
    q2.setMassRadius(15);

    //q2.setTranslation(100,100,100);
    q2.generate();

    q2.conditionAlongSphere(40, true);
    q2.conditionAlongSphere(20, false);

    int secondPebbleEnd = mdl.getNumberOfMasses();

    mdl.addMass("gnd", new Osc3D(500, 3, 0.0001, 0.07, new Vect3D(0, 0, 1000)));

    for (int i = 0; i < mdl.getNumberOfMasses(); i++) {
      mdl.addInteraction("bub"+i, new Bubble3D(1000, 0.01, 0.1), mdl.getMass("gnd"), mdl.getMassList().get(i));
    }

    for (int i = 0; i < firstPebbleEnd; i++) {
      for (int j = firstPebbleEnd; j < secondPebbleEnd; j++) {
        mdl.addInteraction("cont"+i+"_"+j, new Contact3D(0.01, 0.01), mdl.getMassList().get(j), mdl.getMassList().get(i));
      }
    }
    
    listeners[0] = mdl.addInOut("list0", new Observer3D(filterType.HIGH_PASS), "pebbleA_2_2_2");
    listeners[1] = mdl.addInOut("list1", new Observer3D(filterType.HIGH_PASS), "pebbleB_2_2_2");

    driver = mdl.addInOut("driver", new Driver3D(), "gnd");

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

    for (int i = 0; i < listeners.length; i++) {
      
      PVector listenPos = listeners[i].observePos().toPVector();

      audioOut[i] =(float)(listenPos.x)* 0.2
          + (float)(listenPos.y)* 0.2
          + (float)(listenPos.z)* 0.8;
      
      channels[i] = audioOut[i];
    }
    currAudio = audioOut[0];
  }
}
