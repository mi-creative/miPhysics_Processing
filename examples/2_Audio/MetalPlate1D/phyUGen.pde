import java.util.Arrays;
import ddf.minim.UGen;

import miPhysics.*;

int dimX = 25;
int dimY = 25;

float m = 1.0;
float k = 0.2;
float z = 0.0001;
float dist = 25;
float z_tension = 25;
float fric = 0.00001;
float grav = 0.;

int listeningPoint = 15;
int excitationPoint = 10;

int maxListeningPt;

public class PhyUGen extends UGen
{
  
  private String listeningPoint;

  private float    oneOverSampleRate;
  public ArrayList <PVector> modelPos;
  public ArrayList <PVector> modelVel;

  PhysicalModel mdl;

  // strat with ony one constructor for the function.
  public PhyUGen(int sampleRate /* any other arguments?*/)
  {
    super();

    this.mdl = new PhysicalModel(sampleRate, displayRate);
    mdl.setGravity(0.000);
    mdl.setFriction(fric);

    gridSpacing = (int)((height/dimX)*2);
    generateMesh(mdl, dimX, dimY, "osc", "spring", 1., gridSpacing, 0.006, 0.00001, 0.09, 0.0001);

    listeningPoint = "osc5_5";

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
    float sample;
    synchronized(mdl.getLock()) {
    this.mdl.computeStep();

    // calculate the sample value
    if(simUGen.mdl.matExists(listeningPoint))
      sample =(float)(this.mdl.getMatPosition(listeningPoint).z * 0.01);
    else
      sample = 0;
    }
    //this.mdl.updatePosSpeedArraysForModType(modelPos, modelVel, matModuleType.Mass3D);
    Arrays.fill( channels, sample );
    
  }
}
