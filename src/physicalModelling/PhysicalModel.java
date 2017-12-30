package physicalModelling;

import java.util.*;

import processing.core.*;

import processing.core.PVector;

/**
 * This is a template class and can be used to start a new processing Library.
 * Make sure you rename this class as well as the name of the example package 'template' 
 * to your own Library naming convention.
 * 
 * (the tag example followed by the name of an example included in folder 'examples' will
 * automatically include the example in the javadoc.)
 *
 * @example Hello 
 */

public class PhysicalModel {
	
	// myParent is a reference to the parent sketch
	PApplet myParent;

	int myVariable = 0;
	
	private ArrayList<Mat> mats;
	private ArrayList<Link> links;  

	private Mat fakePlaneMat; // super dirty but works as a dummy for plane-based interactions

	private Hashtable<String, Integer> matIndexList;
	// should always be the same as mats.size(), eventually get rid of this variable
	private int numberOfMats;
	  
	private Hashtable<String, Integer> linkIndexList;
	// should always be the same as links.size(), eventually get rid of this variable
	private int numberOfLinks;

	private int simRate;

	private double friction;
	private Vect3D g_vector;
	private Vect3D g_scaled;

	//private Vector3d test;
	
	
	public final static String VERSION = "##library.prettyVersion##";
	

	/**
	 * a Constructor, usually called in the setup() method in your sketch to
	 * initialize and start the Library.
	 * 
	 * @example Hello
	 * @param theParent
	 */
	  /*************************************************/
	  /*   Constructor: simulation rate as argument    */
	  /*************************************************/

	  public PhysicalModel(int sRate) {
	    // Create the Mat and Link arrays
	    mats = new ArrayList<Mat>();
	    links = new ArrayList<Link>();

	    Vect3D random = new Vect3D(0., 0., 0.);
	    fakePlaneMat = new Ground3D(random);

	    matIndexList = new Hashtable<String, Integer>();
	    numberOfMats = 0;
	    
	    linkIndexList = new Hashtable<String, Integer>();
	    numberOfLinks = 0;

	    g_vector = new Vect3D(0., 0., 1.);
	    g_scaled = new Vect3D(0., 0., 0.);


	    if (sRate > 0)
	      setSimRate(sRate);
	    else {
	      System.out.println("Invalid simulation Rate: defaulting to 50 Hz");
	      setSimRate(50);
	    }

	    System.out.println("Initialised the Phsical Model Class");
	  }

	  /*************************************************/
	  /*     Some utility functions for the class      */
	  /*************************************************/

	  /* set/get for the simulation Rate: should we be able to modify the simRate publicly? */
	  public int getSimRate() { return simRate; }
	  public void setSimRate(int rate) { simRate = rate; }

	  /* Clear the model data structure. Currently unused */
	  public void clearModel() {
	    // Delete the Mat and Link arrays
	    for (int i = mats.size() - 1; i >= 0; i--) {
	      mats.remove(i);
	    } 
	    for (int i = links.size() - 1; i >= 0; i--) {
	      links.remove(i);
	    } 
	    // Will need to clear the hashtable at some point
	  }

	  public void init() {
	    // Initialise the stored distances for the springs
	    
	    System.out.println("Initialisation of the physical model: ");
	    System.out.println("Nb of Mats int model: " + getNumberOfMats());
	    System.out.println("Nb of Links in model: " + getNumberOfLinks());

	    
	    for (int i = 0; i < links.size(); i++) {
	      links.get(i).initDistances();
	    }
	    
	    // Should init grav and friction here, in case they were set after the module creation...
	    
	    System.out.println("Finished model init.\n");
	  }


	  public Vect3D getMatPosition(String masName) {
	    int mat_index = matIndexList.get(masName);
	    return mats.get(mat_index).getPos();
	  }

	  private void AddMatToList(String name) {
	    matIndexList.put(name, numberOfMats);
	    numberOfMats++;
	  }
	  
	  private void AddLinkToList(String name) {
	    linkIndexList.put(name, numberOfLinks);
	    numberOfLinks++;
	  }

	  private Vect3D constructDelayedPos(Vect3D pos, Vect3D vel_mps) {
	    // Convert the velocity in [distance unit]/[second] to [distance unit]/[sample]
	    // Then calculate the delayed position for the initialisation of the masses.
	    Vect3D velPerSample = new Vect3D();
	    Vect3D initPosR = new Vect3D();

	    velPerSample.set(vel_mps);
	    velPerSample.div(this.getSimRate());

	    initPosR.set(pos);
	    initPosR.sub(velPerSample);

	    return initPosR;
	  }


	  private int getMatIndex(String name) {
	    int mat_index = -1;
	    try {
	      mat_index = matIndexList.get(name);
	    }
	    catch (NullPointerException e) {
	      System.out.println("Link Error: the connected mat " + name +" does not exist!");
	      System.exit(1);
	    }
	    return mat_index;
	  }
	  
	  public int getNumberOfMats() { return mats.size(); }
	  public int getNumberOfLinks() { return links.size(); }
	  
	  public matModuleType getMatTypeAt(int i) { 
	    if(getNumberOfMats() > i)
	      return mats.get(i).getType();
	    else return matModuleType.UNDEFINED;}
	  
	  
	  public Vect3D getMatPosAt(int i) { 
	    if(getNumberOfMats() > i)
	      return mats.get(i).getPos(); 
	    else return new Vect3D(0.,0.,0.);}
	  

	  public linkModuleType getLinkTypeAt(int i) { 
	    if(getNumberOfLinks() > i)
	      return links.get(i).getType();
	    else return linkModuleType.UNDEFINED;}
	  
	  public Vect3D getLinkPos1At(int i) { 
	        if(getNumberOfLinks() > i)
	          return links.get(i).getMat1().getPos(); 
	        else return new Vect3D(0.,0.,0.);
	      }

	  public Vect3D getLinkPos2At(int i) { 
	        if(getNumberOfLinks() > i)
	          return links.get(i).getMat2().getPos(); 
	        else return new Vect3D(0.,0.,0.);
	  }
	  
	  
	  /*************************************************/
	  /*          Compute simulation steps             */
	  /*************************************************/

	  public void computeNSteps(int N) {
	    for (int j = 0; j < N; j++) {
	      for (int i = 0; i < mats.size(); i++) {
	        mats.get(i).compute();
	      } 
	      for (int i = 0; i < links.size(); i++) {
	        links.get(i).compute();
	      }
	    }
	  }

	  public void computeStep() { computeNSteps(1); }


	  /*************************************************/
	  /*          Add modules to the model !           */
	  /*************************************************/


	  /* Add a 3D Mass module to the model */
	  public int addMass3D(String name, double mass, Vect3D initPos, Vect3D initVel) {
	    try {
	      if (matIndexList.containsKey(name)== true) {
	        System.out.println("The module name already exists!");
	        throw new Exception ("The module name already exists!");
	      }
	      mats.add(new Mass3D(mass, initPos, constructDelayedPos(initPos, initVel), 
	        friction, g_scaled));
	      AddMatToList(name);
	    }
	    catch (Exception e) {
	      System.out.println("Error adding Module " + name + ": " + e);
	      System.exit(1);
	    }
	    return 0;
	  }
	  

	  public int addMass3DSimple(String name, double mass, Vect3D initPos, Vect3D initVel) {
	    try {
	      if (matIndexList.containsKey(name)== true) {
	        System.out.println("The module name already exists!");
	        throw new Exception ("The module name already exists!");
	      }
	      mats.add(new Mass3DSimple(mass, initPos, constructDelayedPos(initPos, initVel)));
	      AddMatToList(name);
	    }
	    catch (Exception e) {
	      System.out.println("Error adding Module " + name + ": " + e);
	      System.exit(1);
	    }
	    return 0;
	  }

	  public int addGround3D(String name, Vect3D initPos) {
	    try {
	      if (matIndexList.containsKey(name)== true) {
	        System.out.println("The module name already exists!");
	        throw new Exception ("The module name already exists!");
	      }
	      mats.add(new Ground3D(initPos));
	      AddMatToList(name);
	    }
	    catch (Exception e) {
	      System.out.println("Error adding Module " + name + ": " + e);
	      System.exit(1);
	    }
	    return 0;
	  }
	  
	  public int addOsc3D(String name, double mass, double K, double Z, Vect3D initPos, Vect3D initVel) {
	    try {
	      if (matIndexList.containsKey(name)== true) {
	        System.out.println("The module name already exists!");
	        throw new Exception ("The module name already exists!");
	      }
	      mats.add(new Osc3D(mass, K, Z, initPos, constructDelayedPos(initPos, initVel), 
	        friction, g_scaled));
	      AddMatToList(name);
	    }
	    catch (Exception e) {
	      System.out.println("Error adding Module " + name + ": " + e);
	      System.exit(1);
	    }
	    return 0;
	  }



	  /* Add a 3D Spring module to the model */
	  public int addSpring3D(String name, double dist, double paramK, String m1_Name, String m2_Name) {

	    int mat1_index = getMatIndex(m1_Name);
	    int mat2_index = getMatIndex(m2_Name);
	    try {
	      links.add(new Spring3D(dist, paramK, mats.get(mat1_index), mats.get(mat2_index)));
	      AddLinkToList(name);
	    }
	    catch (Exception e) {
	      System.out.println("Error allocating the Spring module");
	      System.exit(1);
	    }
	    return 0;
	  }
	  

	  /* Add a 3D SpringDamper module to the model */
	  public int addSpringDamper3D(String name, double dist, double paramK, double paramZ, String m1_Name, String m2_Name) {

	    int mat1_index = getMatIndex(m1_Name);
	    int mat2_index = getMatIndex(m2_Name);
	    try {
	      links.add(new SpringDamper3D(dist, paramK, paramZ, mats.get(mat1_index), mats.get(mat2_index)));
	      AddLinkToList(name);
	    }
	    catch (Exception e) {
	      System.out.println("Error allocating the SpringDamper module");
	      System.exit(1);
	    }
	    return 0;
	  }
	  


	  /* Add a 3D "rope-like" SpringDamper module to the model */
	  public int addRope3D(String name, double dist, double paramK, double paramZ, String m1_Name, String m2_Name) {

	    int mat1_index = getMatIndex(m1_Name);
	    int mat2_index = getMatIndex(m2_Name);
	    try {
	      links.add(new Rope3D(dist, paramK, paramZ, mats.get(mat1_index), mats.get(mat2_index)));
	      AddLinkToList(name);

	    }
	    catch (Exception e) {
	      System.out.println("Error allocating the SpringDamper module");
	      System.exit(1);
	    }
	    return 0;
	  }



	  /* Add a 3D "rope-like" SpringDamper module to the model */
	  public int addContact3D(String name, double dist, double paramK, double paramZ, String m1_Name, String m2_Name) {

	    int mat1_index = getMatIndex(m1_Name);
	    int mat2_index = getMatIndex(m2_Name);
	    try {
	      links.add(new Contact3D(dist, paramK, paramZ, mats.get(mat1_index), mats.get(mat2_index)));
	      AddLinkToList(name);

	    }
	    catch (Exception e) {
	      System.out.println("Error allocating the SpringDamper module");
	      System.exit(1);
	    }
	    return 0;
	  }
	  


	  /* Add a 3D Damper module to the model */
	  public int addDamper3D(String name, double paramZ, String m1_Name, String m2_Name) {

	    int mat1_index = getMatIndex(m1_Name);
	    int mat2_index = getMatIndex(m2_Name);
	    try {
	      links.add(new Damper3D(paramZ, mats.get(mat1_index), mats.get(mat2_index)));
	      AddLinkToList(name);

	    }
	    catch (Exception e) {
	      System.out.println("Error allocating the Damper module");
	      System.exit(1);
	    }
	    return 0;
	  }
	  


	  /* Add a 3D Damper module to the model */
	  public int addPlaneInteraction(String name, double l0, double param_K, double paramZ, int or, double pos, String m1_Name) {

	    int mat1_index = getMatIndex(m1_Name);
	    try {
	      links.add(new PlaneContact(l0, param_K, paramZ, mats.get(mat1_index), fakePlaneMat, or, pos));
	      AddLinkToList(name);

	    }
	    catch (Exception e) {
	      System.out.println("Error allocating the Bounce on Plane module");
	      System.exit(1);
	    }
	    return 0;
	  }
	  
	  

	  /*************************************************/
	  /*  META Parameters: air friction and gravit     */
	  /*************************************************/

	  public void setFriction(double frZ) {
	    friction = frZ;

	    // Some shady typecasting going on here...
	    Mass3D tmp;
	    Osc3D tmp2;
	    for (int i = 0; i < mats.size(); i++) {
	      if (mats.get(i).getType() == matModuleType.Mass3D) {
	        tmp = (Mass3D)mats.get(i);
	        tmp.updateFriction(frZ);
	      }
	      if (mats.get(i).getType() == matModuleType.Osc3D) {
	        tmp2 = (Osc3D)mats.get(i);
	        tmp2.updateFriction(frZ);
	      }
	    }
	  }


	  public void triggerForceImpulse(String name, double fx, double fy, double fz){
		  
		  Vect3D force = new Vect3D(fx,fy,fz);
	    try{
	      int mat1_index = getMatIndex(name);
	      mats.get(mat1_index).applyExtForce(force);
	    }
	    catch (Exception e){
	      System.out.println("Issue during force impuse trigger");
	      System.exit(1);
	    }
	  }

	  public void setGravityDirection(PVector grav) {
		  Vect3D gravDir = new Vect3D(grav.x, grav.y,grav.z);
	    g_vector.set(gravDir);
	  }

	  public void setGravity(double grav) {
	    g_scaled.set(g_vector);
	    g_scaled.mult(grav);
	    System.out.println("G scaled: " + g_scaled);

	    // Some shady typecasting going on here...
	    Mass3D tmp;
	    for (int i = 0; i < mats.size(); i++) {
	      if (mats.get(i).getType() == matModuleType.Mass3D) {
	        tmp = (Mass3D)mats.get(i);
	        tmp.updateGravity(g_scaled);
	      }
	    }
	  }
	  
	  
	  
	public double getOsc3DDeltaPos(int i) {
		Osc3D tmp;
	    if (mats.get(i).getType() == matModuleType.Osc3D) {
	    	tmp = (Osc3D)mats.get(i);
	    	double dist = tmp.distRest();
		    return dist;
	    }
	    return 0;
	}
	
	private void welcome() {
		System.out.println("##library.name## ##library.prettyVersion## by ##author##");
	}
	
	
	public String sayHello() {
		return "hello library.";
	}
	/**
	 * return the version of the Library.
	 * 
	 * @return String
	 */
	public static String version() {
		return VERSION;
	}

}

