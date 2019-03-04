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
 // float audioOut;
  
  
    float[] audioOut ={0, 0};
    float[] prevAudio ={0, 0};
    String[] listeners ={"none", "none"};


  PhysicalModel mdl;

  public PhyUGen(int sampleRate)
  {
    super();

    this.mdl = new PhysicalModel(sampleRate, (int)baseFrameRate);
    mdl.setGravity(0.000004);
    mdl.setFriction(0.00001);

    //audioOut = 0;


    TopoGenerator q = new TopoGenerator(mdl, "pebbleA", "springA");
    q.setDim(dimX, dimY, dimZ, overlap);
    q.setParams(1, 0.05, 0.0001);
    q.setGeometry(25, 25);
    
    q.setTranslation(1, 1,0);

    q.generate();
    
    q.conditionAlongSphere(40, true);
    q.conditionAlongSphere(20, false);
    
    int firstPebbleEnd = mdl.getNumberOfMats();

    
    TopoGenerator q2 = new TopoGenerator(mdl, "pebbleB", "springB");
    q2.setDim(dimX, dimY, dimZ, overlap);
    q2.setParams(1, 0.05, 0.0001);
    q2.setGeometry(25, 25);
    //q2.setTranslation(100,100,100);
    q2.generate();

    q2.conditionAlongSphere(40, true);
    q2.conditionAlongSphere(20, false);
    
    int secondPebbleEnd = mdl.getNumberOfMats();


    mdl.addOsc3D("gnd", 500, 0.0001, 0.07, new Vect3D(0, 0, 1000), new Vect3D(0, 0, 0));



    for (int i = 0; i < mdl.getNumberOfMats(); i++) {
      println(mdl.getMatNameAt(i));
      mdl.addBubble3D("bub"+i, 1000, 0.01, 0.1, "gnd", mdl.getMatNameAt(i));
    }
    
    for (int i = 0; i < firstPebbleEnd; i++) {
      for (int j = firstPebbleEnd ; j < secondPebbleEnd; j++) {
        println(mdl.getMatNameAt(i));
        mdl.addContact3D("cont"+i+"_"+j, 20, 0.01, 0.01, mdl.getMatNameAt(j), mdl.getMatNameAt(i));
      }
    }



    listeners[0] = "pebbleA_2_2_2"; 
    listeners[1] = "pebbleB_2_2_2";

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
            
        if(audioRamp < 1)
          audioRamp +=0.00001;
        

      for(int i = 0; i < listeners.length; i++){
        
      Vect3D listenPos = this.mdl.getMatPosition(listeners[i]);

      // calculate the sample value
      if (simUGen.mdl.matExists(listeners[i])) {
        sample =(float)(listenPos.x)* 0.2
               + (float)(listenPos.y)* 0.2
               + (float)(listenPos.z)* 0.8;

        /* High pass filter to remove the DC offset */
        audioOut[i] = (sample - prevAudio[i] + 0.85 * audioOut[i]) * audioRamp;
        prevAudio[i] = sample;

      } else
        audioOut[i] = 0;
      channels[i] = audioOut[i];
      }
      
    }
    currAudio = audioOut[0];
  }
}
