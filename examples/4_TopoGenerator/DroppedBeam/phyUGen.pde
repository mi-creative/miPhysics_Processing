import java.util.Arrays;
import ddf.minim.UGen;

import miPhysics.*;

int dimX = 2;
int dimY = 2;
int dimZ = 10;
int overlap = 3;
double grav = 0.000004;

public class PhyUGen extends UGen
{

  private float    oneOverSampleRate;

  float[] audioOut ={0, 0};
  float[] prevAudio ={0, 0};
  String[] listeners ={"none", "none"};

  PhysicalModel mdl;

  public PhyUGen(int sampleRate)
  {
    super();

    this.mdl = new PhysicalModel(sampleRate, (int)baseFrameRate);
    mdl.setGravity(0.);
    mdl.setFriction(0.00001);

    TopoGenerator q = new TopoGenerator(mdl, "mass", "spring");
    q.setDim(dimX, dimY, dimZ, overlap);
    q.setParams(1, 0.006, 0.00003);
    q.setGeometry(25, 25);

    //q.addBoundaryCondition(Bound.X_LEFT);
    //q.addBoundaryCondition(Bound.X_RIGHT);
    //q.addBoundaryCondition(Bound.Y_LEFT);
    //q.addBoundaryCondition(Bound.Y_RIGHT);
    //q.addBoundaryCondition(Bound.Z_LEFT);
    //q.addBoundaryCondition(Bound.Z_RIGHT);

    q.generate();

    for (int i = 0; i < mdl.getNumberOfMats(); i++) {
      println(mdl.getMatNameAt(i));
      mdl.addPlaneContact("plane"+i, 0, 0.1, 0.05, 2, 0, mdl.getMatNameAt(i));
    }

    listeners[0] = "mass_" + (dimX/2)+ "_" + (dimY/2) + "_" + (dimZ-1); 
    listeners[1] = "mass_" + (dimX/2)+ "_" + (dimY/2) + "_" + 0; 

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


    for (int i = 0; i < listeners.length; i++) {

      Vect3D listenPos = this.mdl.getMatPosition(listeners[i]);

      // calculate the sample value
      if (simUGen.mdl.matExists(listeners[i])) {
        sample =(float)(listenPos.x)* 0.1
          + (float)(listenPos.y)* 0.1
          + (float)(listenPos.z)* 0.1;

        /* High pass filter to remove the DC offset */
        audioOut[i] = (sample - prevAudio[i] + 0.95 * audioOut[i]) * audioRamp;
        prevAudio[i] = sample;
      } else
        audioOut[i] = 0;
      channels[i] = audioOut[i];
    }

    currAudio = audioOut[0];
  }
}
