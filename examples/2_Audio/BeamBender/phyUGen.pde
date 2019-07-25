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

int dimX = 18;
int dimY = 3;
int dimZ = 2;

boolean triggerForceRamp = false;
float forcePeak = 10;

boolean lenghtStrech = false;
boolean sectionStrech = false;
boolean twist = false;


float frcX = 0;
float frcY = 0;
float frcZ = 0;

float frcRate = 0.01;

long nbStepSimul = 0;

StringList groundsL = new StringList();
StringList groundsR = new StringList();

String massToExcite = "";
String massToListenTo = "";


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
      
      if (audioRamp < 1){
        audioRamp +=0.00001;
      }

      // Triggered force (for "plucking")
      if(triggerForceRamp){
        
        frcX = frcX + frcRate * 0.1 * excitingX ;
        frcY = frcY + frcRate * 0.1 * excitingY ;
        frcZ = frcZ + frcRate * 0.1 * excitingZ ;

        simUGen.mdl.triggerForceImpulse(massToExcite,frcX,frcY,frcZ);

        if (frcX+frcY+frcZ > forcePeak){
          triggerForceRamp = false;
          frcX = 0;
          frcY = 0;
          frcZ = 0;
        }
       
      }    
      if (toggleInput==true){
        simUGen.mdl.triggerForceImpulse(massToExcite,0,(double)in.right.get((int)nbStepSimul%1)*Ctrl_inGain,0);
        nbStepSimul += 1;
      }

      // calculate the sample value
      if (simUGen.mdl.matExists(massToListenTo)) {
        sample = (float)(this.mdl.getMatPosition(massToListenTo).x * listeningX)
               + (float)(this.mdl.getMatPosition(massToListenTo).y * listeningY)
               + (float)(this.mdl.getMatPosition(massToListenTo).z * listeningZ);

        /* High pass filter to remove the DC offset */
        if (toggleOutput==true){
          audioOut = (sample - prevSample + 0.95 * audioOut) * audioRamp * Ctrl_outGain/10;
          prevSample = sample;
        }
        
      } else
        sample = 0;
    
    Arrays.fill( channels, audioOut );
    currAudio = audioOut;
  }
}
