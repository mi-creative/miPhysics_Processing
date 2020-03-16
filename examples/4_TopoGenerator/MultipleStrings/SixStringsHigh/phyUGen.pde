double grav = 0.000004;
int nbStrings = 6;

public class PhyUGen extends UGen
{
  private float    oneOverSampleRate;

  PhysicalModel mdl;

  Driver3D drivers[];
  Observer3D listeners[];

  public PhyUGen(int sampleRate)
  {
    super();

    this.mdl = new PhysicalModel(sampleRate, (int)baseFrameRate);
    mdl.setGlobalGravity(0., 0., 0.);
    mdl.setGlobalFriction(0.00003);

    drivers = new Driver3D[nbStrings];
    listeners = new Observer3D[nbStrings];

    int len = 25;

    for (int i = 0; i < nbStrings; i++) {

      TopoGenerator q = new TopoGenerator(mdl, ("str"+str(i)), ("spring"+str(i)));

      q.setDim(len, 1, 1, 2);
      q.setParams(1, 0.4, 0.05);
      q.setGeometry(10, 0.1);
      q.setTranslation(-400, -600 + 130 * i, 0);
      q.addBoundaryCondition(Bound.X_LEFT);
      q.addBoundaryCondition(Bound.X_RIGHT);
      q.setMassRadius(3);
      q.generate();

      // Calculate next string length (approximately guitar tuning intervals)
      if (i == 1)
        len = round(len*pow(1.059463, 4));
      else
        len = round(len*pow(1.059463, 5));

      drivers[i] = mdl.addInOut("driver_"+i, new Driver3D(), "str"+ i +"_" + (len/5 + 5 * i)+ "_0_0");
      listeners[i] = mdl.addInOut("listener_"+i, new Observer3D(filterType.HIGH_PASS), "str"+i+"_" + floor(len/3)+ "_" + 0 + "_" + 0);
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

    // Triggered linear ramp forces (for "plucking")
    for (int i = 0; i < nbStrings; i++) {
      if (triggerForceRamp[i]) {
        frc[i] = frc[i] + frcRate[i] * 0.1;
        drivers[i].applyFrc(new Vect3D(0, frc[i], 0));

        if (frc[i] > forcePeak[i]) {
          triggerForceRamp[i] = false;
          frc[i] = 0;
        }
      }
    }

    this.mdl.computeSingleStep();

    float allAudio = 0;

    for (int i = 0; i < listeners.length; i++)
      allAudio += (float)listeners[i].observePos().y * (0.01 - 0.001 * i);

    channels[1] = allAudio;
    channels[0] = allAudio;
    currAudio = allAudio;
  }
}
