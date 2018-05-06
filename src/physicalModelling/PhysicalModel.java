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

	private ArrayList<String> matIndexList;
	private ArrayList<String> linkIndexList;

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

	    //matIndexList = new Hashtable<String, Integer>();
	    matIndexList = new ArrayList<String>();
	    //numberOfMats = 0;
	    
	    linkIndexList = new ArrayList<String>();

	    //linkIndexList = new Hashtable<String, Integer>();
	    //numberOfLinks = 0;

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

	  
	  private int getMatIndex(String name) {
			return matIndexList.indexOf(name);
	
		    /*int mat_index = -1;
		    try {
		      mat_index = matIndexList.get(name);
		    }
		    catch (NullPointerException e) {
		      System.out.println("Link Error: the connected mat " + name +" does not exist!");
		      System.exit(1);
		    }
		    return mat_index;*/
		  }
	  
	  private int getLinkIndex(String name) {
			return linkIndexList.indexOf(name);
		  }

	  
	  public Vect3D getMatPosition(String masName) {
		  try {
			int mat_index = getMatIndex(masName);
			if (mat_index > -1) {
				return mats.get(mat_index).getPos();
			} else {
		        throw new Exception ("The module name already exists!");
			}
		    //int mat_index = matIndexList.get(masName);
		    //return mats.get(mat_index).getPos();
		  } catch (Exception e) {
		      System.out.println("Error accessing Module " + masName + ": " + e);
		      System.exit(1);
		  }
		  return new Vect3D();
	  }
	  
/*
	  private void AddMatToList(String name) {
	    matIndexList.put(name, numberOfMats);
	    numberOfMats++;
	  }
*/  
	/*  private void AddLinkToList(String name) {
	    linkIndexList.put(name, numberOfLinks);
	    numberOfLinks++;
	  }*/


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



	  
	  public int getNumberOfMats() { return mats.size(); }
	  public int getNumberOfLinks() { return links.size(); }
	  
	  public boolean matExists(String mName) {
		  if(getMatIndex(mName)<0)
			  return false;
		  else
			  return true;
		  }
	  
	  public boolean linkExists(String lName){
		  if(getLinkIndex(lName)<0)
			  return false;
		  else
			  return true;
		  }
	  
	  // create and return a new list with links matching a name pattern
	  // used for parameter modification
	  private ArrayList<Link> findAllLinksContaining(String tag){
		
		  ArrayList<Link> newlist = new ArrayList<Link>();
		  		  
		  for (int i = 0; i < links.size(); i++) {
			  if (linkIndexList.get(i).contains(tag))
				  newlist.add(links.get(i));
		    }
		  return newlist;
	  }
	  
	  // create and return a new list with mats matching a name pattern
	  // used for parameter modification
	  private ArrayList<Mat> findAllMatsContaining(String tag){
		
		  ArrayList<Mat> newlist = new ArrayList<Mat>();
		  		  
		  for (int i = 0; i < mats.size(); i++) {
			  if (matIndexList.get(i).contains(tag))
				  newlist.add(mats.get(i));
		    }
		  return newlist;
	  }
	  
	  
	  
	  public matModuleType getMatTypeAt(int i) { 
	    if(getNumberOfMats() > i)
	      return mats.get(i).getType();
	    else return matModuleType.UNDEFINED;}	  
	  
	  
	  public String getMatNameAt(int i) { 
		    if(getNumberOfMats() > i)
			      return matIndexList.get(i);
			    else return "None";}
	  
	  
	  
	  public Vect3D getMatPosAt(int i) { 
	    if(getNumberOfMats() > i)
	      return mats.get(i).getPos(); 
	    else return new Vect3D(0.,0.,0.);}
	  

	  public linkModuleType getLinkTypeAt(int i) { 
	    if(getNumberOfLinks() > i)
	      return links.get(i).getType();
	    else return linkModuleType.UNDEFINED;}
	  
	  public String getLinkNameAt(int i) { 
		    if(getNumberOfLinks() > i)
			      return linkIndexList.get(i);
			    else return "None";}	  
	  
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
	      //if (matIndexList.containsKey(name)== true) {
		  if (matIndexList.contains(name)== true) {

	        System.out.println("The module name already exists!");
	        throw new Exception ("The module name already exists!");
	      }
	      mats.add(new Mass3D(mass, initPos, constructDelayedPos(initPos, initVel), 
	        friction, g_scaled));
	      //AddMatToList(name);
	      matIndexList.add(name);
	    }
	    catch (Exception e) {
	      System.out.println("Error adding Module " + name + ": " + e);
	      System.exit(1);
	    }
	    return 0;
	  }
	  

	  public int addMass3DSimple(String name, double mass, Vect3D initPos, Vect3D initVel) {
	    try {
	      //if (matIndexList.containsKey(name)== true) {
	        if (matIndexList.contains(name)== true) {

	        System.out.println("The module name already exists!");
	        throw new Exception ("The module name already exists!");
	      }
	      mats.add(new Mass3DSimple(mass, initPos, constructDelayedPos(initPos, initVel)));
	      //AddMatToList(name);
	      matIndexList.add(name);

	    }
	    catch (Exception e) {
	      System.out.println("Error adding Module " + name + ": " + e);
	      System.exit(1);
	    }
	    return 0;
	  }

	  public int addGround3D(String name, Vect3D initPos) {
	    try {
	      //if (matIndexList.containsKey(name)== true) {
		   if (matIndexList.contains(name)== true) {

	        System.out.println("The module name already exists!");
	        throw new Exception ("The module name already exists!");
	      }
	      mats.add(new Ground3D(initPos));
	      //AddMatToList(name);
	      matIndexList.add(name);

	    }
	    catch (Exception e) {
	      System.out.println("Error adding Module " + name + ": " + e);
	      System.exit(1);
	    }
	    return 0;
	  }
	  
	  public int addOsc3D(String name, double mass, double K, double Z, Vect3D initPos, Vect3D initVel) {
	    try {
	    	if (matIndexList.contains(name)== true) {
	      //if (matIndexList.containsKey(name)== true) {
	        System.out.println("The module name already exists!");
	        throw new Exception ("The module name already exists!");
	      }
	      mats.add(new Osc3D(mass, K, Z, initPos, constructDelayedPos(initPos, initVel), 
	        friction, g_scaled));
	      //AddMatToList(name);
	      matIndexList.add(name);

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
	      linkIndexList.add(name);
	      //AddLinkToList(name);
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
	      linkIndexList.add(name);
	      //AddLinkToList(name);
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
	      linkIndexList.add(name);
	      //AddLinkToList(name);

	    }
	    catch (Exception e) {
	      System.out.println("Error allocating the SpringDamper module");
	      System.exit(1);
	    }
	    return 0;
	  }



	  /* Add a 3D contact module to the model */
	  public int addContact3D(String name, double dist, double paramK, double paramZ, String m1_Name, String m2_Name) {

	    int mat1_index = getMatIndex(m1_Name);
	    int mat2_index = getMatIndex(m2_Name);
	    try {
	      links.add(new Contact3D(dist, paramK, paramZ, mats.get(mat1_index), mats.get(mat2_index)));
	      linkIndexList.add(name);
	      //AddLinkToList(name);

	    }
	    catch (Exception e) {
	      System.out.println("Error allocating the Contact module");
	      System.exit(1);
	    }
	    return 0;
	  }
	  
	  /* Add a 3D bubble (enclosing circle) module to the model */
	  public int addBubble3D(String name, double dist, double paramK, double paramZ, String m1_Name, String m2_Name) {

	    int mat1_index = getMatIndex(m1_Name);
	    int mat2_index = getMatIndex(m2_Name);
	    try {
	      links.add(new Bubble3D(dist, paramK, paramZ, mats.get(mat1_index), mats.get(mat2_index)));
	      linkIndexList.add(name);
	      //AddLinkToList(name);

	    }
	    catch (Exception e) {
	      System.out.println("Error allocating the Bubble module");
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
	      linkIndexList.add(name);
	      //AddLinkToList(name);

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
	      linkIndexList.add(name);
	      //AddLinkToList(name);

	    }
	    catch (Exception e) {
	      System.out.println("Error allocating the Bounce on Plane module");
	      System.exit(1);
	    }
	    return 0;
	  }
	  
	  
	  /***************************************************/
	  
	  private int removeMat(int mIndex) {
		  // Risky business
		  // find mat and remove from the mat array list.
		    try {
		    		// first check if the index can be in the list
		    		if((mats.size() > mIndex) && (matIndexList.size() > mIndex))
		    			mats.remove(mIndex);
		    			matIndexList.remove(mIndex);
			    }
			    catch (Exception e) {
			      System.out.println("Error removing mat Module at " + mIndex + ": " + e);
			      System.exit(1);
			    }
			    return 0;		  
	  }
	  
	  private int removeMat(String name) {
		  int mat_index = getMatIndex(name);
		  return removeMat(mat_index);
	  }
	  
	  
	  // Links can be removed without further steps: public function  
	  public int removeLink(int lIndex) {
		    try {
	    		// first check if the index can be in the list
	    		if((links.size() > lIndex) && (linkIndexList.size() > lIndex))
	    			links.remove(lIndex);
	    			linkIndexList.remove(lIndex);
		    }
		    catch (Exception e) {
		      System.out.println("Error removing link Module at " + lIndex + ": " + e);
		      System.exit(1);
		    }
		    return 0;			  
	  }
	  
	  // Links can be removed without further steps: public function
	  public int removeLink(String name) {
		  int mat_index = getLinkIndex(name);
		  return removeLink(mat_index);
	  }
	  
	  
	  public int removeMatAndConnectedLinks(int mIndex) {
		  try {
		   for (int i = links.size()-1 ; i >= 0 ; i--) {
			  // Will this work? 
		      if (links.get(i).getMat1() == mats.get(mIndex))
		    	  removeLink(i);
		      else if (links.get(i).getMat2() == mats.get(mIndex))
		    	  removeLink(i);
		   }
		   removeMat(mIndex);
		   return 0;

		  } catch (Exception e){
		      System.out.println("Issue removing connected links to mass!");
		      System.exit(1);		  
		  }
		  return -1;  
	  }
	  
	  public int removeMatAndConnectedLinks(String mName) {
		  int mat_index = getMatIndex(mName);
		  return removeMatAndConnectedLinks(mat_index);
	  }
	  
	  
	  public void setLinkDRest(String name, double d) {
		  int link_index = getLinkIndex(name);
		  try {
		  links.get(link_index).changeDRest(d);
		  } catch (Exception e) {
			  System.out.println("Issue changing link distance!");
		      System.exit(1);    
		  }
	  }
	  
	  
	  public void setLinkParamsForName(String tag, double stiff, double damp, double dist) {
		  
		  // Create a list with all the links to modify
		  ArrayList<Link> tmplist = findAllLinksContaining(tag);
		 
		  // Update the parameters of all these links
		  for(Link ln : tmplist) {
			  ln.changeStiffness(stiff);
			  ln.changeDamping(damp);
			  ln.changeDRest(dist); 
		  }
	  }
	  
	  public void setMatParamsForName(String tag, double mass) {
		  
		  // Create a list with all the links to modify
		  ArrayList<Mat> tmplist = findAllMatsContaining(tag);
		 
		  // Update the parameters of all these links
		  for(Mat ma : tmplist) {
			  ma.setMass(mass);
		  }
	  }
	  
	  
	  
	  public void setLinkParams(String name, double stiff, double damp, double dist) {
		  int link_index = getLinkIndex(name);
		  try {
			  links.get(link_index).changeStiffness(stiff);
			  links.get(link_index).changeDamping(damp);
			  links.get(link_index).changeDRest(dist);
		  } catch (Exception e) {
			  System.out.println("Issue changing link params!");
		      System.exit(1);    
		  }
	  }
	  
	  public void setLinkStiffness(String name, double stiff) {
		  int link_index = getLinkIndex(name);
		  try {
			  links.get(link_index).changeStiffness(stiff);
		  } catch (Exception e) {
			  System.out.println("Issue changing link stiffness!");
		      System.exit(1);    
		  }
	  }
	  
	  public void setLinkDamping(String name, double damp) {
		  int link_index = getLinkIndex(name);
		  try {
			  links.get(link_index).changeDamping(damp);
		  } catch (Exception e) {
			  System.out.println("Issue changing link damping!");
		      System.exit(1);    
		  }
	  }
	  
	  public void setMatMass(String name, double val) {
		  int mas_index = getMatIndex(name);
		  try {
			  mats.get(mas_index).setMass(val);
		  } catch (Exception e) {
			  System.out.println("Issue changing link damping!");
		      System.exit(1);    
		  }
	  }
	  
	  
	  
	  /**************************************************/
	  /*		Methods so that we can draw the model	*/
	  /**************************************************/
	  
	  public void getAllMatsOfType(ArrayList<PVector> mArray, matModuleType m) {
		  mArray.clear();
		  Mat mat;
		  Vect3D pos = new Vect3D();
		  for (int i = 0; i < mats.size(); i++) {
		  	  	mat = mats.get(i);	
			      if (mat.getType() == m) {
			    	pos.set(mat.getPos());
			        mArray.add(new PVector((float)pos.x, (float)pos.y, (float)pos.z));
			      }
		  }		  	  
	  }
	  
	  
	  public void getAllMatSpeedsOfType(ArrayList<PVector> pArray, ArrayList<PVector> vArray, matModuleType m) {
		  pArray.clear();
		  vArray.clear();
		  Mat mat;
		  Vect3D pos = new Vect3D();
		  for (int i = 0; i < mats.size(); i++) {
			  	  mat = mats.get(i);	
			      if (mat.getType() == m) {
			    	pos.set(mat.getPos());
			    	pArray.add(new PVector((float)pos.x, (float)pos.y, (float)pos.z));
			        pos.sub(mat.getPosR());
			        vArray.add(new PVector((float)pos.x, (float)pos.y, (float)pos.z));
			      }
		  }		  	  
	  }
	  
	  public void createPosSpeedArraysForModType(ArrayList<PVector> pArray, ArrayList<PVector> vArray, matModuleType m) {
		  pArray.clear();
		  vArray.clear();
		  Mat mat;
		  Vect3D pos = new Vect3D();
		  for (int i = 0; i < mats.size(); i++) {
			  	  mat = mats.get(i);	
			      if (mat.getType() == m) {
			    	pos.set(mat.getPos());
			    	pArray.add(new PVector((float)pos.x, (float)pos.y, (float)pos.z));
			        pos.sub(mat.getPosR());
			        vArray.add(new PVector((float)pos.x, (float)pos.y, (float)pos.z));
			      }
		  }	  	  
	  }
	  
	  public void updatePosSpeedArraysForModType(ArrayList<PVector> pArray, ArrayList<PVector> vArray, matModuleType m) {
		  Mat mat;
		  Vect3D pos = new Vect3D();
		  int arrayIndex = 0;
		  for (int i = 0; i < mats.size(); i++) {
			  	  mat = mats.get(i);	
			      if (mat.getType() == m) {
			    	pos.set(mat.getPos());
			    	pArray.set(arrayIndex, new PVector((float)pos.x, (float)pos.y, (float)pos.z));
			        pos.sub(mat.getPosR());
			    	vArray.set(arrayIndex, new PVector((float)pos.x, (float)pos.y, (float)pos.z));
			        arrayIndex++;
			      }
		  }	  	  
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

