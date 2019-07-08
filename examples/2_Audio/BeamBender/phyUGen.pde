import java.util.Arrays;
import ddf.minim.UGen;

import miPhysics.*;

/* Phyiscal parameters for the model */
float m = 1.0;
float k = 0.01;
float z = 0.00001;

// slight pre-strain on the beam by using a shorter l0
float l0 = 25.;

// spacing between the masses, imposed by the fixed points at each end
float dist = 25.;

float fric = 0.00001;
float grav = 0.;

int dimX = 15;
int dimY = 3;
int dimZ = 3;

boolean triggerForceRamp = false;
float forcePeak = 10;

boolean lenghtStrech = false;
boolean sectionStrech = false;
boolean twist = false;


float frc = 0;
float frcRate = 0.01;

float gainControl = 0;

StringList groundsL = new StringList();

StringList groundsR = new StringList();

public class PhyUGen extends UGen
{

  private String listeningPoint;
  private String excitationPoint;

  private float oneOverSampleRate;

  float prevSample;
  float audioOut;
  float audioRamp;

  PhysicalModel mdl;

  public PhyUGen(int sampleRate)
  {
    super();

    this.mdl = new PhysicalModel(sampleRate, (int)baseFrameRate);
    mdl.setGravity(grav);
    mdl.setFriction(fric);

    audioOut = 0;
    audioRamp = 0;


    generateVolume(mdl, dimX, dimY, dimZ, "mass", "spring", "myBeam", m, l0, dist, k, z);
    listeningPoint = "mass85";
    excitationPoint = "mass5";

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
    if(lenghtStrech){
      for (int k = 0; k < groundsL.size(); k++) {
        this.mdl.setMatPosition(groundsL.get(k), new Vect3D(mdl.getMatPosition(groundsL.get(k)).x+(mouseX-pmouseX)/100., mdl.getMatPosition(groundsL.get(k)).y, mdl.getMatPosition(groundsL.get(k)).z));
        this.mdl.setMatPosition(groundsR.get(k), new Vect3D(mdl.getMatPosition(groundsR.get(k)).x-(mouseX-pmouseX)/100., mdl.getMatPosition(groundsR.get(k)).y, mdl.getMatPosition(groundsR.get(k)).z));
      }
    }
    
    if(sectionStrech){
      for (int k = 0; k < groundsL.size(); k++) {
         this.mdl.setMatPosition(groundsL.get(k), new Vect3D(mdl.getMatPosition(groundsL.get(k)).x, mdl.getMatPosition(groundsL.get(k)).y*(1+(mouseY-pmouseY)/100000.), mdl.getMatPosition(groundsL.get(k)).z));
         this.mdl.setMatPosition(groundsL.get(k), new Vect3D(mdl.getMatPosition(groundsL.get(k)).x, mdl.getMatPosition(groundsL.get(k)).y, mdl.getMatPosition(groundsL.get(k)).z*(1+(mouseY-pmouseY)/100000.)));
         this.mdl.setMatPosition(groundsR.get(k), new Vect3D(mdl.getMatPosition(groundsR.get(k)).x, mdl.getMatPosition(groundsR.get(k)).y*(1+(mouseY-pmouseY)/100000.), mdl.getMatPosition(groundsR.get(k)).z));
         this.mdl.setMatPosition(groundsR.get(k), new Vect3D(mdl.getMatPosition(groundsR.get(k)).x, mdl.getMatPosition(groundsR.get(k)).y, mdl.getMatPosition(groundsR.get(k)).z*(1+(mouseY-pmouseY)/100000.)));
      }
    }

    if(twist){
      for (int k = 0; k < groundsL.size(); k++) {
        this.mdl.setMatPosition(groundsL.get(k), new Vect3D(  mdl.getMatPosition(groundsL.get(k)).x, 
                               (cos((mouseY-pmouseY)/10000.)*(mdl.getMatPosition(groundsL.get(k)).y - (dist*(dimY-1))/2.) - sin((mouseY-pmouseY)/10000.)*(mdl.getMatPosition(groundsL.get(k)).z - (dist*(dimZ-1))/2.) + (dist*(dimY-1))/2.), 
                               (sin((mouseY-pmouseY)/10000.)*(mdl.getMatPosition(groundsL.get(k)).y - (dist*(dimY-1))/2.) + cos((mouseY-pmouseY)/10000.)*(mdl.getMatPosition(groundsL.get(k)).z - (dist*(dimZ-1))/2.) + (dist*(dimZ-1))/2.)));
      }
    }

      this.mdl.computeStep();
      
      if (audioRamp < 1)
        audioRamp +=0.00001;

      // Triggered force (for "plucking")
      if(triggerForceRamp){
        frc = frc + frcRate * 0.1;
        simUGen.mdl.triggerForceImpulse(excitationPoint,0,frc,0);

        if (frc > forcePeak){
          triggerForceRamp = false;
          frc = 0;
        }
      }

      // calculate the sample value
      if (simUGen.mdl.matExists(listeningPoint)) {
        sample =(float)(this.mdl.getMatPosition(listeningPoint).x)* 0.15
               + (float)(this.mdl.getMatPosition(listeningPoint).y)* 0.15
               + (float)(this.mdl.getMatPosition(listeningPoint).z)* 0.15;

        sample*=gainControl;

        /* High pass filter to remove the DC offset */
        audioOut = (sample - prevSample + 0.95 * audioOut) * audioRamp;;
        prevSample = sample;
      } else
        sample = 0;
    
    Arrays.fill( channels, audioOut );
    currAudio = audioOut;
  }
}
