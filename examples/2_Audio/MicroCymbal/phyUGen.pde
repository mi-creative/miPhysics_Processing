import java.util.Arrays;
import ddf.minim.UGen;

import miPhysics.*;

public class PhyUGen extends UGen
{
  private float    oneOverSampleRate;

  float audioOut = 0;
  int smoothing = 100;

  PhysicalModel mdl; 
  Observer3D listener;
  PosInput3D input;
  Driver3D driver;

  float audioRamp = 0;


  public PhyUGen(int sampleRate)
  {
    super();

    this.mdl = new PhysicalModel(sampleRate, (int)baseFrameRate);

    mdl.setGlobalGravity(0, 0, 0);
    mdl.setGlobalFriction(0.00001);

    int DIM = 20;
    double dist = 10;
    double K = 0.2;
    double Z = 0.01;

    double radius = ((DIM/2)-1)*dist; 
    Vect3D center = new Vect3D(dist*DIM/2, dist*DIM/2, 0);

    generateMesh(mdl, DIM, DIM, "osc", "spring", 1., dist, K, Z);

    ArrayList<Mass> toRemove = new ArrayList<Mass>();

    for (Mass m : mdl.getMassList()) {
      if (m.getPos().dist(center) > radius)
        toRemove.add(m);
    }
    for (Mass m : toRemove)
      mdl.removeMassAndConnectedInteractions(m);

    mdl.addMass("perc", new Osc3D(10, 15, 0.00001, 0.01, new Vect3D(DIM/2.5*dist, DIM/3.5*dist, 50)), new Medium(0, new Vect3D(0, 0, 0))); 
    driver = mdl.addInOut("drive", new Driver3D(), "perc");

    for (int i = 0; i < mdl.getNumberOfMasses()-1; i++) {
      if (mdl.getMassList().get(i) != null) {
        println(mdl.getMassList().get(i).getName());
        mdl.addInteraction("col_"+i, new Contact3D(0.1, 0.01), "perc", mdl.getMassList().get(i).getName());
      }
    }

    mdl.addInOut("list_", new Observer3D(filterType.HIGH_PASS), "osc3_8");
    mdl.init();
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
    audioOut = 0;
    this.mdl.computeSingleStep();
    for (Observer3D l : mdl.getObservers())
      audioOut += (float)l.observePos().z * 0.05;

    //audioOut = ((float)listener.observePos().y) * 0.9;
    Arrays.fill( channels, audioOut);
    currAudio = audioOut;
  }
}




void generateMesh(PhysicalModel mdl, int dimX, int dimY, String mName, String lName, double masValue, double dist, double K, double Z) {
  // add the masses to the model: name, mass, initial pos, init speed
  String masName;
  Vect3D X0, V0;

  for (int i = 0; i < dimY; i++) {
    for (int j = 0; j < dimX; j++) {
      masName = mName + j +"_"+ i;
      //println(masName);
      X0 = new Vect3D((float)j*dist, (float)i*dist, 0.);
      if ((i==dimY/2) && (j == dimX/2))
        mdl.addMass(masName, new Ground3D(1, X0));
      else
        mdl.addMass(masName, new Mass1D(masValue, 10, X0));
    }
  }
  // add the spring to the model: length, stiffness, connected mats
  String masName1, masName2;

  for (int i = 0; i < dimX; i++) {
    for (int j = 0; j < dimY-1; j++) {
      masName1 = mName + i +"_"+ j;
      masName2 = mName + i +"_"+ str(j+1);
      mdl.addInteraction(lName + "1_" +i+"_"+j, new SpringDamper3D(dist*0.8, K, Z), masName1, masName2);
    }
  }

  for (int i = 0; i < dimX-1; i++) {
    for (int j = 0; j < dimY; j++) {
      masName1 = mName + i +"_"+ j;
      masName2 = mName + str(i+1) +"_"+ j;
      mdl.addInteraction(lName + "2_" +i+"_"+j, new SpringDamper3D(dist*0.6, K, Z), masName1, masName2);
    }
  }
}
