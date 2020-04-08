//import java.util.Arrays;
//import ddf.minim.UGen;

//import miPhysics.Engine.*;

///* Phyiscal parameters for the model */
///* The general approach her is to use general/homogeneus parameters for mass (m), stifness (k), internal viscosity (z)
///* dist is the value defining the distance between to mass modules when generating the structure
///* fric is the global external viscoty
///* l0 is the resting lenght for all interaction modules
///* grav is a general parameters of gravity
///* c_dist, c_gnd, c_k and c_z are the parameters of the interaction model and mass
// */
//float m, k, z, dist, fric, l0, grav, c_k, c_z;

//public class PhyUGen extends UGen
//{
//  private float    oneOverSampleRate;
//  float audioOut;
//  PhysicalModel mdl;
//  PosInput3D input;
//  Observer3D listener;
//  private String listeningPoint;
//  int smoothing = 100;

//  public PhyUGen(int sampleRate)
//  {
//    super();

//    this.mdl = new PhysicalModel(sampleRate, (int)baseFrameRate);
//    mdl.setGlobalGravity(0,0,grav);
//    mdl.setGlobalFriction(fric);

//    audioOut = 0;


//    // Just a good old beam
//    m = 1.0; 
//    k = 0.3; 
//    z = 0.0001; 
//    dist = 0.24; 
//    fric = 0.00003; 
//    l0 = 0.3; 
//    grav = 0.; 
//    c_k = 0.03; 
//    c_z = 0.01; 
//    generateVolume(this.mdl, 3, 30, 1, "mass", "spring", m, 0.05, dist, dist, k, z);
//    listeningPoint = "mass20";

//    // Metal Hurlant / 
//    //m = 1.0; k = 0.35; z = 0.01; dist = 0.4; fric = 0.0003; l0 = 0.2; grav = 0.; c_dist = 1.8; c_gnd = 0.65; c_k = 0.07; c_z = -0.04;
//    //generateVolume(this.mdl, 3, 40, 1, "mass", "spring", m, 0.05, dist, dist, k, z);
//    //listeningPoint = "mass30";

//    // Fat Woden Stick / 
//    // m = 1.0; k = 0.35; z = 0.1; dist = 1.; fric = 0.0003; l0 = 0.2; grav = 0.; c_dist = .9; c_gnd = 0.65; c_k = 0.07; c_z = 0.04; 
//    // generateVolume(this.mdl, 3, 40, 1, "mass", "spring", m, 0.05, dist, dist, k, z);
//    // listeningPoint = "mass30";

//    // Udu
//    //m = 1.0; k = 0.39; z = 0.02; dist = 1.; fric = 0.0003; l0 = 0.2; grav = 0.; c_dist = 1.9; c_gnd = 0.65; c_k = 0.07; c_z = 0.04; 
//    //generateVolume(this.mdl, 2, 10, 1, "mass", "spring", m, 0.05, dist, dist, k, z);
//    //listeningPoint = "mass10";

//    // Balafon
//    //m = 1.0; k = 0.39; z = 0.02; dist = 1.; fric = 0.0003; l0 = 0.2; grav = 0.; c_dist = 1.9; c_gnd = 0.65; c_k = 0.07; c_z = 0.04; 
//    //generateVolume(this.mdl, 3, 10, 1, "mass", "spring", m, 0.05, dist, dist, k, z);
//    //listeningPoint = "mass20";

//    // Tabla
//    //m = 1.0; k = 0.39; z = 0.01; dist = 1.; fric = 0.0003; l0 = 0.2; grav = 0.; c_dist = 1.9; c_gnd = 0.65; c_k = 0.07; c_z = 0.04; 
//    //generateVolume(this.mdl, 5, 20, 1, "mass", "spring", m, 1, dist, dist, k, z);
//    //listeningPoint = "mass20";

//    // Tiberian Crotals
//    //m = 1.0; k = 0.39; z = 0.0001; dist = 1.; fric = 0.00003; l0 = 0.2; grav = 0.; c_dist = 1.9; c_gnd = 0.65; c_k = 0.07; c_z = 0.04; 
//    //generateVolume(this.mdl, 20, 5, 1, "mass", "spring", m, 0.05, dist, dist, k, z);
//    //listeningPoint = "mass30";

//    // Cow Bell
//    //m = 1.0; k = 0.35; z = 0.001; dist = 1.; fric = 0.003; l0 = 0.2; grav = 0.; c_dist = 1.9; c_gnd = 0.65; c_k = 0.07; c_z = 0.04;
//    //generateVolume(this.mdl, 5, 20, 1, "mass", "spring", m, 0.05, dist, dist, k, z);
//    //listeningPoint = "mass30";

//    // Screaming Bitch
//    //m = 1.0; k = 0.1; z = 0.00001; dist = 1.; fric = 0.000003; l0 = 0.2; grav = 0.; c_dist = 4.9; c_gnd = 0.65; c_k = 0.07; c_z = 0.04; 
//    //generateVolume(this.mdl, 20, 5, 1, "mass", "spring", m, 0.05, dist, dist, k, z);
//    //listeningPoint = "mass30";

//    // Try and make it scream
//    //m = 1.0; k = 0.35; z = 0.00001; dist = 1.; fric = 0.0003; l0 = 0.2; grav = 0.; c_dist = 6.9; c_gnd = 0.65; c_k = 0.07; c_z = 0.04; 
//    //generateVolume(this.mdl, 2, 2, 1, "mass", "spring", m, 0.05, dist, dist, k, z);
//    //listeningPoint = "mass3";

//    input = this.mdl.addMass("percMass", new PosInput3D(1., new Vect3D(3, -4, 0.), smoothing));
    
    
//    // it is also possible to set interactions by using module references directly and not names
//    for (int i = 0; i< mdl.getNumberOfMasses()-1; i++)
//      this.mdl.addInteraction("col"+i, new Contact3D(c_k, c_z), input, mdl.getMassList().get(i));
   
//    this.listener = this.mdl.addInOut("obs1", new Observer3D(filterType.HIGH_PASS), listeningPoint);


//    this.mdl.init();
//  }

//  /*
//   * This routine will be called any time the sample rate changes.
//   */
//  protected void sampleRateChanged()
//  {
//    oneOverSampleRate = 1 / sampleRate();
//    this.mdl.setSimRate((int)sampleRate());
//  }

//  // Some variable dealing with mouse movement smoothing
//  float smooth = 0.01;
//  float x_avg=0, y_avg=0;

//  @Override
//    protected void uGenerate(float[] channels)
//  {
//    float x = 30 * (float)mouseX / width - 15;
//    float y = 30 * (float)mouseY / height - 15;
//    input.drivePosition(new Vect3D(x, y, 0));
    
//    this.mdl.computeSingleStep();
    
//    audioOut = (float)listener.observePos().y * 1.4;
//    Arrays.fill( channels, audioOut );
//    currAudio = audioOut;
//  }
//}
