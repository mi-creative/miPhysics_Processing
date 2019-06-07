package miPhysics;

import java.util.*;
import java.util.concurrent.locks.*;
import java.lang.Math;

import processing.core.*;
import processing.core.PVector;

/**
 * This is the main class in which to create a 3D mass-interaction physical
 * model. A global physical context is created, then populated with modules,
 * which can then be computed.
 *
 * Within this physical context, modules can be accessed in two ways: by using
 * their identification String (a unique name for each module) or by using their
 * index in the Mat and Link module tables. See example: HelloMass
 *
 *
 *
 */

// removed until sorting out taglet compile in new Java:
// (the tag example followed by the name of an example included in folder
// 'examples' will automatically include the example in the javadoc.)
// @example HelloMass

public class PhysicalModel {

	// dummy comment

	// myParent is a reference to the parent sketch
	PApplet myParent;

	private Lock m_lock;

	/* List of Mats and Links that compose the physical model */
	private ArrayList<Mat> mats;
	private ArrayList<Link> links;

	/*
	 * Mat and Link index lists: matches module name to index of module in ArrayList
	 */
	private ArrayList<String> matIndexList;
	private ArrayList<String> linkIndexList;

	/* Super dirty but works as a dummy for plane-based interactions */
	private Mat fakePlaneMat;

	/* The simulation rate (mono rate only) */
	private int simRate;

	/* The processing sketch display rate */
	private int displayRate;

	private double simDisplayFactor;
	private int nbStepsToSim;
	private double residue;

	/* Global friction and gravity characteristics for the model */
	private double friction;

	private Vect3D g_vector;
	private double g_magnitude;
	private Vect3D g_scaled;

	private paramSystem unit_system;

	private Map<String, ArrayList<Integer>> mat_subsets;
	private Map<String, ArrayList<Integer>> link_subsets;

	/* Library version */
	public final static String VERSION = "##library.prettyVersion##";

	/**
	 * Constructor method. Call this in the setup to create a physical context with
	 * a given simulation rate.
	 *
	 * @param sRate
	 *            the sample rate for the physics simulation
	 * @param displayRate
	 *            the display Rate for the processing sketch
	 */
	public PhysicalModel(int sRate, int displayRate, paramSystem sys) {
		/* Create empty Mat and Link arrays */
		mats = new ArrayList<Mat>();
		links = new ArrayList<Link>();
		matIndexList = new ArrayList<String>();
		linkIndexList = new ArrayList<String>();

		/* Initialise the Mat and Link subset groups */
		mat_subsets = new HashMap<String, ArrayList<Integer>>();
		link_subsets = new HashMap<String, ArrayList<Integer>>();

		Vect3D tmp = new Vect3D(0., 0., 0.);
		fakePlaneMat = new Ground3D(tmp);

		g_vector = new Vect3D(0., 0., 1.);
		g_scaled = new Vect3D(0., 0., 0.);

		unit_system = sys;

		if (sRate > 0)
			setSimRate(sRate);
		else {
			System.out.println("Invalid simulation Rate: defaulting to 50 Hz");
			setSimRate(50);
		}

		this.displayRate = displayRate;
		this.residue = 0;

		this.calculateSimDisplayFactor();

		m_lock = new ReentrantLock();


		System.out.println("Initialised the Phsical Model Class");
	}

	/**
	 * Constructor without specifying the parameter system (defaults to algo
	 * parameters)
	 *
	 * @param sRate
	 *            the physics sample rate
	 *
	 */
	public PhysicalModel(int sRate, int displayRate) {
		this(sRate, displayRate, paramSystem.ALGO_UNITS);
		System.out.println("No specified display Rate: defaulting to 30 FPS");
	}

	/**
	 * Constructor without specifying the sketch display rate (defaults to 30 FPS),
	 * or the parameter system (defaults to algo parameters)
	 *
	 * @param sRate
	 *            the physics sample rate
	 *
	 */
	public PhysicalModel(int sRate) {
		this(sRate, 30, paramSystem.ALGO_UNITS);
		System.out.println("No specified display Rate: defaulting to 30 FPS");
	}

	/**
	 * Constructor without specifying the sketch display rate (defaults to 30 FPS).
	 *
	 * @param sRate
	 *            the physics sample rate
	 *
	 */
	public PhysicalModel(int sRate, paramSystem sys) {
		this(sRate, 30, sys);
		System.out.println("No specified display Rate: defaulting to 30 FPS");
	}

	private void calculateSimDisplayFactor() {
		simDisplayFactor = (float) simRate / (float) displayRate;
	}

	/*************************************************/
	/* Some utility functions for the class */
	/*************************************************/

	/**
	 * Get the simulation's sample rate.
	 *
	 * @return the simulation rate
	 */
	public int getSimRate() {
		return simRate;
	}

	/**
	 * Set the simulation's sample rate.
	 *
	 * @param rate
	 *            the rate to set the simulation to (physics frame-per-second).
	 */
	public void setSimRate(int rate) {
		simRate = rate;
		this.calculateSimDisplayFactor();
	}

	/**
	 * Get the simulation's display rate (should be same as Sketch's frame rate).
	 *
	 * @return the simulation rate
	 */
	public int getDisplayRate() {
		return displayRate;
	}

	/**
	 * Set the simulation's display rate (should be same as Sketch's frame rate).
	 *
	 * @param rate
	 *            the rate to set the display to (FPS).
	 */
	public void setDisplayRate(int rate) {
		displayRate = rate;
		this.calculateSimDisplayFactor();
	}

	/**
	 * Delete all modules in the model and start from scratch.
	 */
	public void clearModel() {
		for (int i = mats.size() - 1; i >= 0; i--) {
			mats.remove(i);
		}
		for (int i = links.size() - 1; i >= 0; i--) {
			links.remove(i);
		}
	}

	/**
	 * Initialise the physical model once all the modules have been created.
	 */
	public void init() {

		System.out.println("Initialisation of the physical model: ");
		System.out.println("Nb of Mats int model: " + getNumberOfMats());
		System.out.println("Nb of Links in model: " + getNumberOfLinks());

		/* Initialise the stored distances for the springs */
		for (int i = 0; i < links.size(); i++) {
			links.get(i).initDistances();
		}

		// Should init grav and friction here, in case they were set after the module
		// creation...
		System.out.println("Finished model init.\n");
	}

	/**
	 * Get the index of a Mat module identified by a given string.
	 *
	 * @param name
	 *            Mat module identifier.
	 * @return
	 */
	public int getMatIndex(String name) {
		return matIndexList.indexOf(name);
	}

	/**
	 * Get the index of a Link module identified by a given string.
	 *
	 * @param name
	 *            Link module identifier.
	 * @return
	 */
	public int getLinkIndex(String name) {
		return linkIndexList.indexOf(name);
	}

	/**
	 * Get the position of a Mat module identified by its name.
	 *
	 * @param masName
	 *            identifier of the Mat module.
	 * @return a Vect3D containing the position (in double format)
	 */
	public Vect3D getMatPosition(String masName) {
		try {
			int mat_index = getMatIndex(masName);
			if (mat_index > -1) {
				return mats.get(mat_index).getPos();
			} else {
				throw new Exception("The module name already exists!");
			}
		} catch (Exception e) {
			System.out.println("Error accessing Module " + masName + ": " + e);
			System.exit(1);
		}
		return new Vect3D();
	}


	/**
	 * Get the position of a Mat module identified by its name.
	 *
	 * @param masName
	 *            identifier of the Mat module.
	 * @return a PVector containing the position (in float format).
	 */
	public PVector getMatPVector(String masName) {
		try {
			int mat_index = getMatIndex(masName);
			if (mat_index > -1) {
				return mats.get(mat_index).getPos().toPVector();
			} else {
				throw new Exception("The module name already exists!");
			}
		} catch (Exception e) {
			System.out.println("Error accessing Module " + masName + ": " + e);
			System.exit(1);
		}
		return new PVector();
	}

	/**
	 * Get the force of a Mat module identified by its index.
	 *
	 * @param mat_index
	 *            index of the Mat module.
	 * @return a PVector containing the force (in float format).
	 */
	public PVector getMatForcePVector(int mat_index) {
		try {
			if (mat_index > -1) {
				return mats.get(mat_index).getFrc().toPVector();
			} else {
				throw new Exception("The module name already exists!");
			}
		} catch (Exception e) {
			System.out.println("Error accessing Module " + mat_index + ": " + e);
			System.exit(1);
		}
		return new PVector();
	}

	/**
	 * Get the force of a Mat module identified by its index.
	 *
	 * @param matName
	 *            identifier of the Mat module.
	 * @return a PVector containing the force (in float format).
	 */
	public PVector getMatForcePVector(String matName) {
		try {
			int mat_index = getMatIndex(matName);
			if (mat_index > -1) {
				return mats.get(mat_index).getFrc().toPVector();
			} else {
				throw new Exception("The module name already exists!");
			}
		} catch (Exception e) {
			System.out.println("Error accessing Module " + matName + ": " + e);
			System.exit(1);
		}
		return new PVector();
	}

	/**
	 * Construct delayed position values based on initial position and initial
	 * velocity. Converts the velocity in [distance unit]/[second] to [distance
	 * unit]/[sample] then calculates the delayed position for the initialisation of
	 * the masses.
	 *
	 * @param pos
	 *            initial position
	 * @param vel_mps
	 *            initial velocity in distance unit per second
	 * @return
	 */
	private Vect3D constructDelayedPos(Vect3D pos, Vect3D vel_mps) {
		Vect3D velPerSample = new Vect3D();
		Vect3D initPosR = new Vect3D();

		velPerSample.set(vel_mps);
		velPerSample.div(this.getSimRate());

		initPosR.set(pos);
		initPosR.sub(velPerSample);

		return initPosR;
	}

	/**
	 * Get number of Mat modules in current model.
	 *
	 * @return the number of Mat modules in this model.
	 */
	public int getNumberOfMats() {
		return mats.size();
	}

	/**
	 * get number of Link modules in current model.
	 *
	 * @return the number of Link modules in this model.
	 */
	public int getNumberOfLinks() {
		return links.size();
	}

	/**
	 * Check if a Mat module with a given identifier exists in the current model.
	 *
	 * @param mName
	 *            the identifier of the Mat module.
	 * @return True of the module exists, False otherwise.
	 */
	public boolean matExists(String mName) {
		if (getMatIndex(mName) < 0)
			return false;
		else
			return true;
	}

	/**
	 * Check if a Link module with a given identifier exists in the current model.
	 *
	 * @param lName
	 *            the identifier of the Link module.
	 * @return True of the module exists, False otherwise.
	 */
	public boolean linkExists(String lName) {
		if (getLinkIndex(lName) < 0)
			return false;
		else
			return true;
	}

	/**
	 * Find and return a list of all Link modules that match a given name pattern.
	 * This can be used to group modules with a given label in order to manipulate
	 * them together (modify parameters, etc.) Note: This method is probably very
	 * slooooow.
	 *
	 * @param tag
	 *            the String that is searched for within the link name tags.
	 * @return the Link ArrayList of all the modules that contain the identifier
	 *         tag.
	 */
	private ArrayList<Link> findAllLinksContaining(String tag) {

		ArrayList<Link> newlist = new ArrayList<Link>();

		for (int i = 0; i < links.size(); i++) {
			if (linkIndexList.get(i).contains(tag))
				newlist.add(links.get(i));
		}
		return newlist;
	}

	/**
	 * Find and return a list of all Mat modules that match a given name pattern.
	 * This can be used to group modules with a given label in order to manipulate
	 * them together (modify parameters, etc.) Note: This method is probably very
	 * slooooow.
	 *
	 * @param tag
	 *            the String that is searched for within the Mat name tags.
	 * @return the Mat ArrayList of all the modules that contain the identifier tag.
	 */
	private ArrayList<Mat> findAllMatsContaining(String tag) {

		ArrayList<Mat> newlist = new ArrayList<Mat>();

		for (int i = 0; i < mats.size(); i++) {
			if (matIndexList.get(i).contains(tag))
				newlist.add(mats.get(i));
		}
		return newlist;
	}

	/**
	 * Check the type (mass, ground, osc) of Mat module at index i
	 *
	 * @param i
	 *            the index of the Mat module.
	 * @return the type of the Mat module.
	 */
	public matModuleType getMatTypeAt(int i) {
		if (getNumberOfMats() > i)
			return mats.get(i).getType();
		else
			return matModuleType.UNDEFINED;
	}

	/**
	 * Get the name (identifier) of the Mat module at index i
	 *
	 * @param i
	 *            the index of the Mat module.
	 * @return the identifier String.
	 */
	public String getMatNameAt(int i) {
		if (getNumberOfMats() > i)
			return matIndexList.get(i);
		else
			return "None";
	}

	/**
	 * Get the 3D position of Mat module at index i. Returns a zero filled 3D Vector
	 * if the Mat is not found.
	 *
	 * @param i
	 *            the index of the Mat module
	 * @return the 3D X,Y,Z coordinates of the module.
	 */
	public Vect3D getMatPosAt(int i) {
		if (getNumberOfMats() > i)
			return mats.get(i).getPos();
		else
			return new Vect3D(0., 0., 0.);
	}


	/**
	 * Get the 3D delayed position of the Mat module at index i. Returns a zero filled 3D Vector
	 * if the Mat is not found.
	 *
	 * @param i
	 *            the index of the Mat module
	 * @return the delayed 3D X,Y,Z coordinates of the module.
	 */
	public Vect3D getMatDelayedPosAt(int i) {
		if (getNumberOfMats() > i)
			return mats.get(i).getPosR();
		else
			return new Vect3D(0., 0., 0.);
	}

	/**
	 * Get the velocity of the Mat module at index i. Returns a zero filled 3D Vector
	 * if the Mat is not found.
	 *
	 * @param i
	 *            the index of the Mat module
	 * @return the 3D X,Y,Z velocity coordinates of the module.
	 */
	public Vect3D getMatVelAt(int i) {
		if (getNumberOfMats() > i) {
			Vect3D vel = new Vect3D();
			vel.set(mats.get(i).getPos());
			return (vel.sub(mats.get(i).getPosR()).mult(simRate));
		}
		else
			return new Vect3D(0., 0., 0.);
	}

	/**
	 * Get the 3D force of Mat module at index i. Returns a zero filled 3D Vector
	 * is the Mat is not found.
	 *
	 * @param i
	 *            the index of the Mat module
	 * @return the 3D X,Y,Z coordinates of the module.
	 */
	public Vect3D getMatFrcAt(int i) {
		if (getNumberOfMats() > i)
			return mats.get(i).getFrc();
		else
			return new Vect3D(0., 0., 0.);
	}

	/**
	 * Check the type (spring, rope, contact...) of Link module at index i
	 *
	 * @param i
	 *            index of the Link module.
	 * @return the module type.
	 */
	public linkModuleType getLinkTypeAt(int i) {
		if (getNumberOfLinks() > i)
			return links.get(i).getType();
		else
			return linkModuleType.UNDEFINED;
	}

	/**
	 * Get the name (identifier) of the Link module at index i
	 *
	 * @param i
	 *            index of the Link module.
	 * @return the identifier String for the module.
	 */
	public String getLinkNameAt(int i) {
		if (getNumberOfLinks() > i)
			return linkIndexList.get(i);
		else
			return "None";
	}

	/**
	 * Get the position of the Mat connected to the 1st end of the Link at index i.
	 *
	 * @param i
	 *            the index of the Link.
	 * @return the 3D position of the Mat connected to the 1st end of this Link.
	 */
	public Vect3D getLinkPos1At(int i) {
		if (getNumberOfLinks() > i)
			return links.get(i).getMat1().getPos();
		else
			return new Vect3D(0., 0., 0.);
	}

	/**
	 * Get the position of the Mat connected to the 2nd end of the Link at index i.
	 *
	 * @param i
	 *            the index of the Link.
	 * @return the 3D position of the Mat connected to the 2nd end of this Link.
	 */
	public Vect3D getLinkPos2At(int i) {
		if (getNumberOfLinks() > i)
			return links.get(i).getMat2().getPos();
		else
			return new Vect3D(0., 0., 0.);
	}


	/**
	 * Get the index of the Mat connected to the first input of a Link Module
	 * @param i index of the Link Module.
	 * @return the index of the Mat module (in the Mat list)
	 */
	public int getLinkMat1IdxAt(int i) {
		if (getNumberOfLinks() > i) {
			Mat theMat1 = links.get(i).getMat1();
			return mats.indexOf(theMat1);
		}
		else
			return -1;
	}

	/**
	 * Get the index of the Mat connected to the second input of a Link Module
	 * @param i index of the Link Module.
	 * @return the index of the Mat module (in the Mat list)
	 */
	public int getLinkMat2IdxAt(int i) {
		if (getNumberOfLinks() > i) {
			Mat theMat2 = links.get(i).getMat2();
			return mats.indexOf(theMat2);
		}
		else
			return -1;
	}

	/**
	 * Get the name of the Mat connected to the first input of a Link Module
	 * @param i index of the Link Module
	 * @return the name of the Mat
	 */
	public String getLinkMat1NameAt(int i) {
		if (getLinkMat1IdxAt(i) > -1)
			return getMatNameAt(getLinkMat1IdxAt(i));
		else
			return "";
	}

	/**
	 * Get the name of the Mat connected to the second input of a Link Module
	 * @param i index of the Link Module
	 * @return the name of the Mat
	 */
	public String getLinkMat2NameAt(int i) {
		if (getLinkMat2IdxAt(i) > -1)
			return getMatNameAt(getLinkMat2IdxAt(i));
		else
			return "";
	}


	/*************************************************/
	/* Compute simulation steps */
	/*************************************************/

	/**
	 * Run the physics simulation (call once every draw method). Automatically
	 * computes the correct number of steps depending on the simulation rate /
	 * display rate ratio. Should be called once the model creation is finished and
	 * the init() method has been called.
	 *
	 */
	public void draw_physics() {
		synchronized (m_lock) {
			double floatFrames = this.simDisplayFactor + this.residue;
			int nbSteps = (int) Math.floor(floatFrames);
			this.residue = floatFrames - (double) nbSteps;

			for (int j = 0; j < nbSteps; j++) {
				//mats.parallelStream().forEach(o -> o.compute());
				//links.parallelStream().forEach(o ->o.compute());
				for (int i = 0; i < mats.size(); i++) {
					mats.get(i).compute();
				}
				for (int i = 0; i < links.size(); i++) {
					links.get(i).compute();
				}
			}
		}
	}

	/**
	 * Explicitly compute N steps of the physical simulation. Should be called once
	 * the model creation is finished and the init() method has been called.
	 *
	 * @param N
	 *            number of steps to compute.
	 */
	public void computeNSteps(int N) {
		synchronized (m_lock) {
			for (int j = 0; j < N; j++) {
				for (int i = 0; i < mats.size(); i++) {
					mats.get(i).compute();
				}
				for (int i = 0; i < links.size(); i++) {
					links.get(i).compute();
				}
				//mats.parallelStream().forEach(o -> o.compute());
				//links.parallelStream().forEach(o ->o.compute());
				}
		}
	}

	/**
	 * Compute a single step of the physical simulation. Should be called once the
	 * model creation is finished and the init() method has been called.
	 */
	public void computeStep() {
		computeNSteps(1);
	}

	/*************************************************/
	/* Add modules to the model ! */
	/*************************************************/

	/**
	 * Add a 3D Mass module to the model (this Mass is subject to gravity).
	 *
	 * @param name
	 *            the identifier of the Mass
	 * @param mass
	 *            the mass' inertia value.
	 * @param initPos
	 *            the mass' initial position
	 * @param initVel
	 *            the mass' initial velocity (in distance unit per second)
	 * @return 0 if everything goes well.
	 */
	public int addMass3D(String name, double mass, Vect3D initPos, Vect3D initVel) {
		try {
			if (matIndexList.contains(name) == true) {

				System.out.println("The module name already exists!");
				throw new Exception("The module name already exists!");
			}
			mats.add(new Mass3D(mass, initPos, constructDelayedPos(initPos, initVel), friction, g_scaled));
			matIndexList.add(name);
		} catch (Exception e) {
			System.out.println("Error adding Module " + name + ": " + e);
			System.exit(1);
		}
		return 0;
	}

	/**
	 * Add a 2D Mass module (constant on Z plane) to the model.
	 *
	 * @param name
	 *            the identifier of the Mass
	 * @param mass
	 *            the mass' inertia value.
	 * @param initPos
	 *            the mass' initial position
	 * @param initVel
	 *            the mass' initial velocity (in distance unit per second)
	 * @return 0 if everything goes well.
	 */
	public int addMass2DPlane(String name, double mass, Vect3D initPos, Vect3D initVel) {
		try {
			if (matIndexList.contains(name) == true) {

				System.out.println("The module name already exists!");
				throw new Exception("The module name already exists!");
			}
			mats.add(new Mass2DPlane(mass, initPos, constructDelayedPos(initPos, initVel), friction, g_scaled));
			matIndexList.add(name);
		} catch (Exception e) {
			System.out.println("Error adding Module " + name + ": " + e);
			System.exit(1);
		}
		return 0;
	}

	/**
	 * Add a 1D Mass module (that only moves along the Z axis) to the model
	 *
	 * @param name
	 *            the identifier of the Mass
	 * @param mass
	 *            the mass' inertia value.
	 * @param initPos
	 *            the mass' initial position
	 * @param initVel
	 *            the mass' initial velocity (in distance unit per second)
	 * @return 0 if everything goes well.
	 */
	public int addMass1D(String name, double mass, Vect3D initPos, Vect3D initVel) {
		try {
			if (matIndexList.contains(name) == true) {

				System.out.println("The module name already exists!");
				throw new Exception("The module name already exists!");
			}
			mats.add(new Mass1D(mass, initPos, constructDelayedPos(initPos, initVel), friction, g_scaled));
			matIndexList.add(name);
		} catch (Exception e) {
			System.out.println("Error adding Module " + name + ": " + e);
			System.exit(1);
		}
		return 0;
	}

	/**
	 * Add a 3D Simple Mass module to the model (this Mass not subject to gravity).
	 *
	 * @param name
	 *            the identifier of the Mass
	 * @param mass
	 *            the mass' inertia value.
	 * @param initPos
	 *            the mass' initial position
	 * @param initVel
	 *            the mass' initial velocity (in distance unit per second)
	 * @return 0 if everything goes well.
	 */
	public int addMass3DSimple(String name, double mass, Vect3D initPos, Vect3D initVel) {
		try {
			if (matIndexList.contains(name) == true) {

				System.out.println("The module name already exists!");
				throw new Exception("The module name already exists!");
			}
			mats.add(new Mass3DSimple(mass, initPos, constructDelayedPos(initPos, initVel)));
			matIndexList.add(name);

		} catch (Exception e) {
			System.out.println("Error adding Module " + name + ": " + e);
			System.exit(1);
		}
		return 0;
	}

	/**
	 * Add a fixed point to the model (a Mat module that will never move from it's
	 * initial position).
	 *
	 * @param name
	 *            the name of the Ground module.
	 * @param initPos
	 *            initial position of the Ground module.
	 * @return 0 if everything goes well.
	 */
	public int addGround3D(String name, Vect3D initPos) {
		try {
			if (matIndexList.contains(name) == true) {

				System.out.println("The module name already exists!");
				throw new Exception("The module name already exists!");
			}
			mats.add(new Ground3D(initPos));
			matIndexList.add(name);

		} catch (Exception e) {
			System.out.println("Error adding Module " + name + ": " + e);
			System.exit(1);
		}
		return 0;
	}

	public int addGround1D(String name, Vect3D initPos) {
		try {
			if (matIndexList.contains(name) == true) {

				System.out.println("The module name already exists!");
				throw new Exception("The module name already exists!");
			}
			mats.add(new Ground1D(initPos));
			matIndexList.add(name);

		} catch (Exception e) {
			System.out.println("Error adding Module " + name + ": " + e);
			System.exit(1);
		}
		return 0;
	}

	/**
	 * Add a 3D oscillator (mass-spring-ground) to the model model.
	 *
	 * @param name
	 *            the name of the Oscillator module.
	 * @param mass
	 *            the Oscillator's mass value
	 * @param K
	 *            the Oscillator's stiffness value
	 * @param Z
	 *            the Oscillator's damping value
	 * @param initPos
	 *            initial position of the Oscillator module.
	 * @param initVel
	 *            initial velocity of the Oscillator module (in distance unit per
	 *            second).
	 * @return 0 if everything goes well.
	 */
	public int addOsc3D(String name, double mass, double K, double Z, Vect3D initPos, Vect3D initVel) {

		if (unit_system == paramSystem.REAL_UNITS) {
			K = K / (simRate * simRate);
			Z = Z / simRate;
		}

		try {
			if (matIndexList.contains(name) == true) {
				System.out.println("The module name already exists!");
				throw new Exception("The module name already exists!");
			}
			mats.add(new Osc3D(mass, K, Z, initPos, constructDelayedPos(initPos, initVel), friction, g_scaled));
			matIndexList.add(name);

		} catch (Exception e) {
			System.out.println("Error adding Module " + name + ": " + e);
			System.exit(1);
		}
		return 0;
	}

	public int addOsc1D(String name, double mass, double K, double Z, Vect3D initPos, Vect3D initVel) {

		if (unit_system == paramSystem.REAL_UNITS) {
			K = K / (simRate * simRate);
			Z = Z / simRate;
		}

		try {
			if (matIndexList.contains(name) == true) {
				System.out.println("The module name already exists!");
				throw new Exception("The module name already exists!");
			}
			mats.add(new Osc1D(mass, K, Z, initPos, constructDelayedPos(initPos, initVel), friction, g_scaled));
			matIndexList.add(name);

		} catch (Exception e) {
			System.out.println("Error adding Module " + name + ": " + e);
			System.exit(1);
		}
		return 0;
	}

	/* Add a 3D Spring module to the model */
	/**
	 * Add a 3D Spring to the model.
	 *
	 * @param name
	 *            identifier of the Spring.
	 * @param dist
	 *            resting distance.
	 * @param paramK
	 *            stiffness.
	 * @param m1_Name
	 *            name of Mat module connected to 1st end
	 * @param m2_Name
	 *            name of Mat module connected to 2nd end
	 * @return O if all goes well.
	 */
	public int addSpring3D(String name, double dist, double paramK, String m1_Name, String m2_Name) {

		if (unit_system == paramSystem.REAL_UNITS) {
			paramK = paramK / (simRate * simRate);
		}

		int mat1_index = getMatIndex(m1_Name);
		int mat2_index = getMatIndex(m2_Name);
		try {
			links.add(new Spring3D(dist, paramK, mats.get(mat1_index), mats.get(mat2_index)));
			linkIndexList.add(name);
		} catch (Exception e) {
			System.out.println("Error allocating the Spring module");
			System.exit(1);
		}
		return 0;
	}

	/**
	 * Add a 3D Spring and Damper module to the model.
	 *
	 * @param name
	 *            identifier of the Spring-Damper.
	 * @param dist
	 *            resting distance.
	 * @param paramK
	 *            stiffness value.
	 * @param paramZ
	 *            damping value.
	 * @param m1_Name
	 *            name of Mat module connected to 1st end
	 * @param m2_Name
	 *            name of Mat module connected to 2nd end
	 * @return O if all goes well.
	 */
	public int addSpringDamper3D(String name, double dist, double paramK, double paramZ, String m1_Name,
								 String m2_Name) {

		if (unit_system == paramSystem.REAL_UNITS) {
			paramK = paramK / (simRate * simRate);
			paramZ = paramZ / simRate;
		}

		int mat1_index = getMatIndex(m1_Name);
		int mat2_index = getMatIndex(m2_Name);
		try {
			links.add(new SpringDamper3D(dist, paramK, paramZ, mats.get(mat1_index), mats.get(mat2_index)));
			linkIndexList.add(name);
		} catch (Exception e) {
			System.out.println("Error allocating the SpringDamper module");
			System.exit(1);
		}
		return 0;
	}

	public int addSpringDamper1D(String name, double dist, double paramK, double paramZ, String m1_Name,
								 String m2_Name) {

		if (unit_system == paramSystem.REAL_UNITS) {
			paramK = paramK / (simRate * simRate);
			paramZ = paramZ / simRate;
		}

		int mat1_index = getMatIndex(m1_Name);
		int mat2_index = getMatIndex(m2_Name);
		try {
			links.add(new SpringDamper1D(dist, paramK, paramZ, mats.get(mat1_index), mats.get(mat2_index)));
			linkIndexList.add(name);
		} catch (Exception e) {
			System.out.println("Error allocating the SpringDamper module");
			System.exit(1);
		}
		return 0;
	}

	/**
	 * Add a 3D "rope-like" Spring  and Damper module to the model. This interaction
	 * will only be active in case of a positive elongation. If the rope is not
	 * tight (elongation smaller than resting distance) the interaction does
	 * nothing.
	 *
	 * @param name
	 *            identifier of the Rope.
	 * @param dist
	 *            resting distance.
	 * @param paramK
	 *            stiffness value.
	 * @param paramZ
	 *            damping value.
	 * @param m1_Name
	 *            name of Mat module connected to 1st end
	 * @param m2_Name
	 *            name of Mat module connected to 2nd end
	 * @return O if all goes well.
	 */
	public int addRope3D(String name, double dist, double paramK, double paramZ, String m1_Name, String m2_Name) {

		if (unit_system == paramSystem.REAL_UNITS) {
			paramK = paramK / (simRate * simRate);
			paramZ = paramZ / simRate;
		}

		int mat1_index = getMatIndex(m1_Name);
		int mat2_index = getMatIndex(m2_Name);
		try {
			links.add(new Rope3D(dist, paramK, paramZ, mats.get(mat1_index), mats.get(mat2_index)));
			linkIndexList.add(name);
		} catch (Exception e) {
			System.out.println("Error allocating the SpringDamper module");
			System.exit(1);
		}
		return 0;
	}

	/**
	 * Add a 3D Contact module to the model.
	 *
	 * @param name
	 *            identifier of the Contact module.
	 * @param dist
	 *            (threshold) below which the Contact becomes active.
	 * @param paramK
	 *            stiffness value.
	 * @param paramZ
	 *            damping value.
	 * @param m1_Name
	 *            name of Mat module connected to 1st end
	 * @param m2_Name
	 *            name of Mat module connected to 2nd end
	 * @return O if all goes well.
	 */
	public int addContact3D(String name, double dist, double paramK, double paramZ, String m1_Name, String m2_Name) {

		if (unit_system == paramSystem.REAL_UNITS) {
			paramK = paramK / (simRate * simRate);
			paramZ = paramZ / simRate;
		}

		int mat1_index = getMatIndex(m1_Name);
		int mat2_index = getMatIndex(m2_Name);
		try {
			links.add(new Contact3D(dist, paramK, paramZ, mats.get(mat1_index), mats.get(mat2_index)));
			linkIndexList.add(name);
		} catch (Exception e) {
			System.out.println("Error allocating the Contact module");
			System.exit(1);
		}
		return 0;
	}


	/**
	 * Add a 3D Bubble (enclosing circle module to the model.
	 *
	 * @param name
	 *            identifier of the Bubble module.
	 * @param dist
	 *            radius of the circle (distance above which the interaction will become
	 *            active).
	 * @param paramK
	 *            stiffness value.
	 * @param paramZ
	 *            damping value.
	 * @param m1_Name
	 *            name of Mat module connected to 1st end
	 * @param m2_Name
	 *            name of Mat module connected to 2nd end
	 * @return O if all goes well.
	 */
	public int addBubble3D(String name, double dist, double paramK, double paramZ, String m1_Name, String m2_Name) {

		if (unit_system == paramSystem.REAL_UNITS) {
			paramK = paramK / (simRate * simRate);
			paramZ = paramZ / simRate;
		}

		int mat1_index = getMatIndex(m1_Name);
		int mat2_index = getMatIndex(m2_Name);
		try {
			links.add(new Bubble3D(dist, paramK, paramZ, mats.get(mat1_index), mats.get(mat2_index)));
			linkIndexList.add(name);
		} catch (Exception e) {
			System.out.println("Error allocating the Bubble module");
			System.exit(1);
		}
		return 0;
	}

	/**
	 * Add a 3D Friction-based Damper module to the model.
	 *
	 * @param name
	 *            identifier of the Damper.
	 * @param paramZ
	 *            damping value.
	 * @param m1_Name
	 *            name of Mat module connected to 1st end
	 * @param m2_Name
	 *            name of Mat module connected to 2nd end
	 * @return O if all goes well.
	 */
	public int addDamper3D(String name, double paramZ, String m1_Name, String m2_Name) {

		if (unit_system == paramSystem.REAL_UNITS) {
			paramZ = paramZ / simRate;
		}

		int mat1_index = getMatIndex(m1_Name);
		int mat2_index = getMatIndex(m2_Name);
		try {
			links.add(new Damper3D(paramZ, mats.get(mat1_index), mats.get(mat2_index)));
			linkIndexList.add(name);
		} catch (Exception e) {
			System.out.println("Error allocating the Damper module");
			System.exit(1);
		}
		return 0;
	}

	/**
	 * Add an interaction with a 2D plane.
	 *
	 * @param name
	 *            name of the Plane Interaction module.
	 * @param l0
	 *            distance below which the interaction becomes active.
	 * @param paramK
	 *            stiffness value.
	 * @param paramZ
	 *            damping value.
	 * @param or
	 *            orientation of the plane (0: x-plane, 1: y-plane, 2: z-plane)
	 * @param pos
	 *            position of the plane along the axis defined by or.
	 * @param m1_Name
	 *            name of the Mat module connected to this Plane.
	 * @return
	 */
	public int addPlaneContact(String name, double l0, double paramK, double paramZ, int or, double pos,
							   String m1_Name) {

		if (unit_system == paramSystem.REAL_UNITS) {
			paramK = paramK / (simRate * simRate);
			paramZ = paramZ / simRate;
		}

		int mat1_index = getMatIndex(m1_Name);
		try {
			links.add(new PlaneContact(l0, paramK, paramZ, mats.get(mat1_index), fakePlaneMat, or, pos));
			linkIndexList.add(name);
		} catch (Exception e) {
			System.out.println("Error allocating the Bounce on Plane module");
			System.exit(1);
		}
		return 0;
	}




	/**
	 * Add a 3D Attractor module to the model.

	 * @return O if all goes well.
	 */
	public int addAttractor3D(String name, double dLim, double attr, String m1_Name, String m2_Name) {

		/*if (unit_system == paramSystem.REAL_UNITS) {
			paramK = paramK / (simRate * simRate);
			paramZ = paramZ / simRate;
		}*/

		int mat1_index = getMatIndex(m1_Name);
		int mat2_index = getMatIndex(m2_Name);
		try {
			links.add(new Attractor3D(dLim, attr, mats.get(mat1_index), mats.get(mat2_index)));
			linkIndexList.add(name);
		} catch (Exception e) {
			System.out.println("Error allocating the Attractor module: " + e);
			System.exit(1);
		}
		return 0;
	}


	/***************************************************/

	/**
	 * Remove Mat module at index mIndex from the model. This function is private: a
	 * Mat module cannot safely be removed without removing associated Links,
	 * therefore a higher level function is provided for the user.
	 *
	 * @param mIndex
	 *            index of the Mat module to remove.
	 * @return 0 if success, throws error if Mat cannot be found or removed.
	 */
	private int removeMat(int mIndex) {
		// find mat and remove from the mat array list.
		try {
			// first check if the index can be in the list
			if ((mats.size() > mIndex) && (matIndexList.size() > mIndex))
				mats.remove(mIndex);
			matIndexList.remove(mIndex);
		} catch (Exception e) {
			System.out.println("Error removing mat Module at " + mIndex + ": " + e);
			System.exit(1);
		}
		return 0;
	}

	/**
	 * Remove Mat module (identified by name) from the Model This function is
	 * private: a Mat module cannot safely be removed without removing associated
	 * Links, therefore a higher level function is provided for the user.
	 *
	 * @param name
	 *            identifier of the Mat module to remove.
	 * @return 0 if success, throws error otherwise.
	 */
	private int removeMat(String name) {
		int mat_index = getMatIndex(name);
		return removeMat(mat_index);
	}

	// Links can be removed without further steps: public function
	/**
	 * Remove a Link module from the Model (at lIndex)
	 *
	 * @param lIndex
	 *            the index of the Link module to remove
	 * @return 0 if success, throws error otherwise.
	 */
	public int removeLink(int lIndex) {
		synchronized (m_lock) {
			try {
				// first check if the index can be in the list
				if ((links.size() > lIndex) && (linkIndexList.size() > lIndex))
					links.remove(lIndex);
				linkIndexList.remove(lIndex);
			} catch (Exception e) {
				System.out.println("Error removing link Module at " + lIndex + ": " + e);
				System.exit(1);
			}
		}
		return 0;
	}

	// Links can be removed without further steps: public function
	/**
	 * Remove a Link module from the Model (by name)
	 *
	 * @param name
	 *            identifier of the Link module to remove.
	 * @return 0 if success, throws error otherwise.
	 */
	public synchronized int removeLink(String name) {
		int mat_index = getLinkIndex(name);
		return removeLink(mat_index);
	}

	/**
	 * Remove a Mat module along with any connected Links.
	 *
	 * @param mIndex
	 *            the index of the Mat module to remove.
	 * @return 0 if success, throws error otherwise.
	 */
	public int removeMatAndConnectedLinks(int mIndex) {
		synchronized (m_lock) {
			try {
				for (int i = links.size() - 1; i >= 0; i--) {
					// Will this work?
					if (links.get(i).getMat1() == mats.get(mIndex))
						removeLink(i);
					else if (links.get(i).getMat2() == mats.get(mIndex))
						removeLink(i);
				}
				removeMat(mIndex);
				return 0;

			} catch (Exception e) {
				System.out.println("Issue removing connected links to mass!" + e);
				System.exit(1);
			}
		}
		return -1;
	}

	/**
	 * Remove a Mat module along with any connected Links.
	 *
	 * @param mName
	 *            name of the Mat module to remove.
	 * @return 0 if success, throw error otherwise.
	 */
	public int removeMatAndConnectedLinks(String mName) {
		int mat_index = getMatIndex(mName);
		return removeMatAndConnectedLinks(mat_index);
	}





	/**
	 * Quick module substitution (for boundary conditions).
	 *
	 * @param masName
	 *            identifier of the Mat module.
	 * @return
	 */
	public void changeToFixedPoint(String masName) {

		int mat_index = getMatIndex(masName);

		try {

			Vect3D pos = new Vect3D(0,0,0);
			pos = getMatPosAt(mat_index);

			mats.set(mat_index, new Ground3D(pos));

		} catch (Exception e) {
			System.out.println("Couldn't change into fixed point:  " + masName + ": " + e);
			System.exit(1);
		}
		return;
	}



	/**
	 * Set (or change) the resting distance of a Link module.
	 *
	 * @param name
	 *            the identifier of the module.
	 * @param d
	 *            new resting distance.
	 */
	public void setLinkDRest(String name, double d) {
		int link_index = getLinkIndex(name);
		try {
			links.get(link_index).changeDRest(d);
		} catch (Exception e) {
			System.out.println("Issue changing link distance!");
			System.exit(1);
		}
	}

	/**
	 * Set all parameters of a Link module with given name identifier.
	 *
	 * @param tag
	 *            the identifier tag for the modules.
	 * @param stiff
	 *            stiffness value.
	 * @param damp
	 *            damping value.
	 * @param dist
	 *            distance value.
	 */
	public void setLinkParamsForName(String tag, double stiff, double damp, double dist) {
		// Create a list with all the links to modify
		ArrayList<Link> tmplist = findAllLinksContaining(tag);

		// Update the parameters of all these links
		for (Link ln : tmplist) {
			ln.changeStiffness(stiff);
			ln.changeDamping(damp);
			ln.changeDRest(dist);
		}
	}

	/**
	 * Set mass parameters for Mat modules with a given name pattern.
	 *
	 * @param tag
	 *            the name pattern to match.
	 * @param mass
	 *            mass value.
	 */
	public void setMatParamsForName(String tag, double mass) {

		// Create a list with all the links to modify
		ArrayList<Mat> tmplist = findAllMatsContaining(tag);

		// Update the parameters of all these links
		for (Mat ma : tmplist) {
			ma.changeMass(mass);
		}
	}

	/**
	 * Set Link parameters for the module with a given identifier
	 *
	 * @param name
	 *            name of the module to search for.
	 * @param stiff
	 *            stiffness value.
	 * @param damp
	 *            damping value.
	 * @param dist
	 *            distance value.
	 */
	public void setLinkParams(String name, double stiff, double damp, double dist) {

		if (unit_system == paramSystem.REAL_UNITS) {
			stiff = stiff / (simRate * simRate);
			damp = damp / simRate;
		}

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

	/**
	 * Set the stiffness value for a Link module at a given index.
	 *
	 * @param index
	 *            index of the Link module to modify
	 * @param stiff
	 *            stiffness value.setMatMass
	 */
	public void setLinkStiffnessAt(int index, double stiff) {

		if (unit_system == paramSystem.REAL_UNITS) {
			stiff = stiff / (simRate * simRate);
		}

		try {
			links.get(index).changeStiffness(stiff);
		} catch (Exception e) {
			System.out.println("Issue changing link stiffness!");
			System.exit(1);
		}
	}


	/**
	 * Get stiffness of a link module at given index
	 * @param index
	 * @return the stiffness parameter
	 */
	public double getLinkStiffnessAt(int index) {

		if (index >= links.size()) {
			System.out.println("Trying to get stiffness in out of bounds link.");
			return 0;
		}

		double stiff = links.get(index).getStiffness();

		if (unit_system == paramSystem.REAL_UNITS)
			return stiff / (simRate * simRate);
		else
			return stiff;
	}

	/**
	 * Set the stiffness value for a Link module with given identifier.
	 *
	 * @param name
	 *            name of the Link module.
	 * @param stiff
	 *            stiffness value.
	 */
	public void setLinkStiffness(String name, double stiff) {

		this.setLinkStiffnessAt(getLinkIndex(name), stiff);
	}

	/**
	 * Set the damping value for a Link module with given identifier.
	 *
	 * @param index
	 *            identifier of the Link module.
	 * @param damp
	 *            damping parameter.
	 */
	public void setLinkDampingAt(int index, double damp) {

		if (unit_system == paramSystem.REAL_UNITS) {
			damp = damp / simRate;
		}

		try {
			links.get(index).changeDamping(damp);
		} catch (Exception e) {
			System.out.println("Issue changing link damping!");
			System.exit(1);
		}
	}


	/**
	 * Get damping of a link module at given index
	 * @param index
	 * @return the damping parameter
	 */
	public double getLinkDampingAt(int index) {

		if (index >= links.size()) {
			System.out.println("Trying to get damping in out of bounds link.");
			return 0;
		}

		double damp = links.get(index).getDamping();

		if (unit_system == paramSystem.REAL_UNITS)
			return damp / simRate;
		else
			return damp;
	}

	/**
	 * Set the damping value for a Link module with given name.
	 *
	 * @param name
	 *            name of the Link module.
	 * @param damp
	 *            damping parameter.
	 */
	public void setLinkDamping(String name, double damp) {

		this.setLinkDampingAt(getLinkIndex(name), damp);
	}

	/**
	 * Change mass parameter for a given Mat module identified by index.
	 *
	 * @param index
	 *            the index of the Mat module.
	 * @param mass
	 *            the mass value to change
	 */
	public void setMatMassAt(int index, double mass) {
		try {
			mats.get(index).changeMass(mass);
		} catch (Exception e) {
			System.out.println("Issue changing mass inertia!");
			System.exit(1);
		}
	}

	/**
	 * Get mass of a Mat module at given index
	 * @param index
	 * @return the stiffness parameter
	 */
	public double getMatMassAt(int index) {

		if (index >= mats.size()) {
			System.out.println("Trying to get mass in out of bounds mat.");
			return 0;
		}

		return mats.get(index).getMass();

	}

	/**
	 * Get stiffness of a Mat module at given index (if it has a stiffness value)
	 * @param index
	 * @return the stiffness parameter
	 */
	public double getMatStiffnessAt(int index) {

		if (index >= mats.size()) {
			System.out.println("Trying to get stiffness value in out of bounds mat.");
			return 0;
		}

		matModuleType type = getMatTypeAt(index);

		if (type == matModuleType.Osc3D)
			return ((Osc3D) mats.get(index)).getStiffness();
		else if (type == matModuleType.Osc1D)
			return ((Osc1D) mats.get(index)).getStiffness();
		else{
			System.out.println("The module does not have a stiffness value!");
			return 0;
		}
	}

//	/**
//	 * Get damping of a Mat module at given index (if it has a stiffness value)
//	 * @param index
//	 * @return the damping parameter
//	 */
//	public double getMatDampingAt(int index) {
//
//		if (index >= mats.size()) {
//			System.out.println("Trying to get damping value in out of bounds mat.");
//			return 0;
//		}
//
//		matModuleType type = getMatTypeAt(index);
//
//		if (type == matModuleType.Osc3D)
//			return ((Osc3D) mats.get(index)).getDamping();
//		else if (type == matModuleType.Osc1D)
//			return ((Osc1D) mats.get(index)).getDamping();
//		else{
//			System.out.println("The module does not have a damping value!");
//			return 0;
//		}
//	}


	/**
	 * Change mass parameter for a given Mat module identified by name.
	 *
	 * @param name
	 *            identifier of the mat module.
	 * @param mass
	 *            mass value.
	 */
	public void setMatMass(String name, double mass) {

		this.setMatMassAt(getMatIndex(name), mass);
	}


	/**
	 * Set stiffness of a Mat module at given index (if it has a stiffness value)
	 * @param index index of the module
	 * @param stiffness stiffness parameter to set
	 */
	public void setMatStiffnessAt(int index, double paramK) {

		if (unit_system == paramSystem.REAL_UNITS) {
			paramK = paramK / (simRate * simRate);
		}

		if (index >= mats.size()) {
			System.out.println("Trying to set stiffness value in out of bounds mat.");
			return;
		}

		matModuleType type = getMatTypeAt(index);

		if (type == matModuleType.Osc3D)
			((Osc3D) mats.get(index)).setStiffness(paramK);
		else if (type == matModuleType.Osc1D)
			((Osc1D) mats.get(index)).setStiffness(paramK);
		else{
			System.out.println("The module does not have a stiffness value!");
			return;
		}
	}

	/**
	 * Get damping of a Mat module at given index (if it has a stiffness value)
	 * @param index
	 * @return the damping parameter
	 */
	public double getMatDampingAt(int index) {

		if (index >= mats.size()) {
			System.out.println("Trying to get damping value in out of bounds mat.");
			return 0;
		}

		matModuleType type = getMatTypeAt(index);

		if (type == matModuleType.Osc3D)
			return ((Osc3D) mats.get(index)).getDamping();
		else if (type == matModuleType.Osc1D)
			return ((Osc1D) mats.get(index)).getDamping();
		else{
			System.out.println("The module does not have a damping value!");
			return 0;
		}
	}

	/**
	 * Set damping of a Mat module at given index (if it has a stiffness value)
	 * @param index index of the module
	 * @param damping stiffness parameter to set
	 */
	public void setMatDampingAt(int index, double paramZ) {

		if (unit_system == paramSystem.REAL_UNITS) {
			paramZ = paramZ / simRate;
		}

		if (index >= mats.size()) {
			System.out.println("Trying to set damping value in out of bounds mat.");
			return;
		}

		matModuleType type = getMatTypeAt(index);

		if (type == matModuleType.Osc3D)
			((Osc3D) mats.get(index)).setDamping(paramZ);
		else if (type == matModuleType.Osc1D)
			((Osc1D) mats.get(index)).setDamping(paramZ);
		else{
			System.out.println("The module does not have a damping value!");
			return;
		}
	}



	/**
	 * DIRTY !!
	 * Get orientation of a plane contact module at given index
	 * @param index
	 * @return the orientation parameter
	 */
	public int getPlaneOrientationAt(int index) {

		if (index >= links.size()) {
			System.out.println("Trying to get orientation value in out of bounds link.");
			return 0;
		}

		linkModuleType type = getLinkTypeAt(index);

		if (type == linkModuleType.PlaneContact3D)
			return ((PlaneContact) links.get(index)).getOrientation();

		else{
			System.out.println("The module does not have an orientation value (not a Plane Contact)!");
			return 0;
		}
	}


	/**
	 * DIRTY !!
	 * Get position of a plane contact module at given index
	 * @param index
	 * @return the position parameter
	 */
	public double getPlanePositionAt(int index) {

		if (index >= links.size()) {
			System.out.println("Trying to get position value in out of bounds link.");
			return 0;
		}

		linkModuleType type = getLinkTypeAt(index);

		if (type == linkModuleType.PlaneContact3D)
			return ((PlaneContact) links.get(index)).getPosition();

		else{
			System.out.println("The module does not have an position value (not a Plane Contact)!");
			return 0;
		}
	}


	/**************************************************/
	/* Methods so that we can draw the model */
	/**************************************************/

	/**
	 * Fill an ArrayList with the positions of all masses of a given type.
	 *
	 * @param mArray
	 *            the ArrayList (that will be cleared and refilled).
	 * @param m
	 *            the module type that we are looking for.
	 */
	public void getAllMatsOfType(ArrayList<PVector> mArray, matModuleType m) {
		mArray.clear();
		Mat mat;
		Vect3D pos = new Vect3D();
		for (int i = 0; i < mats.size(); i++) {
			mat = mats.get(i);
			if (mat.getType() == m) {
				pos.set(mat.getPos());
				mArray.add(new PVector((float) pos.x, (float) pos.y, (float) pos.z));
			}
		}
	}

	/**
	 * Create and fill two Array Lists with the positions and velocities (per
	 * sample) of all modules of a given type. DEPRECEATED FUNCTION, use
	 * createPosSpeedArraysForModType and update instead.
	 *
	 * @param pArray
	 *            the position ArrayList (that will be cleared and refilled).
	 * @param vArray
	 *            the velocity ArrayList (that will be cleared and refilled).
	 * @param m
	 *            the module type that we are looking for.
	 */
	public void getAllMatSpeedsOfType(ArrayList<PVector> pArray, ArrayList<PVector> vArray, matModuleType m) {
		pArray.clear();
		vArray.clear();
		Mat mat;
		Vect3D pos = new Vect3D();
		for (int i = 0; i < mats.size(); i++) {
			mat = mats.get(i);
			if (mat.getType() == m) {
				pos.set(mat.getPos());
				pArray.add(new PVector((float) pos.x, (float) pos.y, (float) pos.z));
				pos.sub(mat.getPosR());
				vArray.add(new PVector((float) pos.x, (float) pos.y, (float) pos.z));
			}
		}
	}

	/**
	 * Create and fill two Array Lists with the positions and velocities (per
	 * sample) of all modules of a given type. Use this for creating the new arrays
	 * before the simulation is launched. Once the simulation is running, use the
	 * updatePosSpeedArraysForModType method to update the existing ArrayLists.
	 *
	 * Quite inefficient method (checks all Mat modules for a given type)
	 *
	 * @param pArray
	 *            the position ArrayList (that will be cleared and refilled).
	 * @param vArray
	 *            the velocity ArrayList (that will be cleared and refilled).
	 * @param m
	 *            the module type that we are looking for.
	 */
	public void createPosSpeedArraysForModType(ArrayList<PVector> pArray, ArrayList<PVector> vArray, matModuleType m) {
		pArray.clear();
		vArray.clear();
		Mat mat;
		Vect3D pos = new Vect3D();
		for (int i = 0; i < mats.size(); i++) {
			mat = mats.get(i);
			if (mat.getType() == m) {
				pos.set(mat.getPos());
				pArray.add(new PVector((float) pos.x, (float) pos.y, (float) pos.z));
				pos.sub(mat.getPosR());
				vArray.add(new PVector((float) pos.x, (float) pos.y, (float) pos.z));
			}
		}
	}

	/**
	 * Update two Array Lists with the positions and velocities (per sample) of all
	 * modules of a given type. Use this after createPosSpeedArraysForModType, once
	 * the simulation is running to update existing arrays.
	 *
	 * Quite inefficient method (checks all Mat modules for a given type)
	 *
	 * @param pArray
	 *            the position ArrayList.
	 * @param vArray
	 *            the velocity ArrayList.
	 * @param m
	 *            m the module type that we are looking for.
	 */
	public void updatePosSpeedArraysForModType(ArrayList<PVector> pArray, ArrayList<PVector> vArray, matModuleType m) {
		Mat mat;
		Vect3D pos = new Vect3D();
		int arrayIndex = 0;
		for (int i = 0; i < mats.size(); i++) {
			mat = mats.get(i);
			if (mat.getType() == m) {
				pos.set(mat.getPos());
				pArray.set(arrayIndex, new PVector((float) pos.x, (float) pos.y, (float) pos.z));
				pos.sub(mat.getPosR());
				vArray.set(arrayIndex, new PVector((float) pos.x, (float) pos.y, (float) pos.z));
				arrayIndex++;
			}
		}
	}

	/*************************************************/
	/* META Parameters: air friction and gravit */
	/*************************************************/

	/**
	 * Set the friction (globally) for the complete model.
	 *
	 * @param frZ
	 *            the friction value.
	 */
	public void setFriction(double frZ) {

		if (unit_system == paramSystem.REAL_UNITS) {
			frZ = frZ / simRate;
		}

		friction = frZ;

		// Some shady typecasting going on here...
		Mass3D tmp;
		Osc3D tmp2;
		Mass1D tmp3;
		Osc1D tmp4;
		Mass2DPlane tmp5;
		for (int i = 0; i < mats.size(); i++) {
			if (mats.get(i).getType() == matModuleType.Mass3D) {
				tmp = (Mass3D) mats.get(i);
				tmp.updateFriction(frZ);
			} else if (mats.get(i).getType() == matModuleType.Osc3D) {
				tmp2 = (Osc3D) mats.get(i);
				tmp2.updateFriction(frZ);
			} else if (mats.get(i).getType() == matModuleType.Mass1D) {
				tmp3 = (Mass1D) mats.get(i);
				tmp3.updateFriction(frZ);
			} else if (mats.get(i).getType() == matModuleType.Osc1D) {
				tmp4 = (Osc1D) mats.get(i);
				tmp4.updateFriction(frZ);
			} else if (mats.get(i).getType() == matModuleType.Mass2DPlane) {
				tmp5 = (Mass2DPlane) mats.get(i);
				tmp5.updateFriction(frZ);
			}
		}
	}


	public double getFriction(){
		return friction;
	}

	/**
	 * Trigger a force impulse on a given Mat module (identified by index).
	 *
	 * @param index
	 *            index of the module to apply a force to.
	 * @param fx
	 *            force in the X dimension.
	 * @param fy
	 *            force in the Y dimension.
	 * @param fz
	 *            force in the Z dimension.
	 */
	public void triggerForceImpulse(int index, double fx, double fy, double fz) {
		Vect3D force = new Vect3D(fx, fy, fz);
		try {
			mats.get(index).applyExtForce(force);
		} catch (Exception e) {
			System.out.println("Issue during force impuse trigger");
			System.exit(1);
		}
	}

	/**
	 * Trigger a force impulse on a given Mat module.
	 *
	 * @param name
	 *            the name of the module to apply a force to.
	 * @param fx
	 *            force in the X dimension.
	 * @param fy
	 *            force in the Y dimension.
	 * @param fz
	 *            force in the Z dimension.
	 */
	public void triggerForceImpulse(String name, double fx, double fy, double fz) {
		int mat1_index = getMatIndex(name);
		this.triggerForceImpulse(mat1_index, fx, fy, fz);
	}

	/**
	 * Set the gravity direction for this model (using a 3D vector)
	 *
	 * @param grav
	 *            The PVector defining the orientation of the gravity.
	 */
	public void setGravityDirection(PVector grav) {
		Vect3D gravDir = new Vect3D(grav.x, grav.y, grav.z);
		g_vector.set(gravDir.div(gravDir.norm()));
	}

	/**
	 * Get the normalised gravity vector for this physical model
	 * @return the gravity direction vector
	 */
	public Vect3D getGravityDirection(){
		return g_vector;
	}

	/**
	 * Set the value of the gravity for the model (scalar value).
	 *
	 * @param grav
	 *            the scalar value of the gravity applied to Mat modules within the
	 *            model.
	 */
	public void setGravity(double grav) {

		g_magnitude = grav;

		//Vect3D g_scaled = new Vect3D();

		g_scaled.set(g_vector);
		g_scaled.mult(g_magnitude);
		System.out.println("G scaled: " + g_scaled);

		// Some shady typecasting going on here...
		Mass3D tmp;
		Osc3D tmp2;
		Mass1D tmp3;
		Osc1D tmp4;
		Mass2DPlane tmp5;
		for (int i = 0; i < mats.size(); i++) {
			if (mats.get(i).getType() == matModuleType.Mass3D) {
				tmp = (Mass3D) mats.get(i);
				tmp.updateGravity(g_scaled);
			} else if (mats.get(i).getType() == matModuleType.Osc3D) {
				tmp2 = (Osc3D) mats.get(i);
				tmp2.updateGravity(g_scaled);
			} else if (mats.get(i).getType() == matModuleType.Mass1D) {
				tmp3 = (Mass1D) mats.get(i);
				tmp3.updateGravity(g_scaled);
			} else if (mats.get(i).getType() == matModuleType.Osc1D) {
				tmp4 = (Osc1D) mats.get(i);
				tmp4.updateGravity(g_scaled);
			} else if (mats.get(i).getType() == matModuleType.Mass2DPlane) {
				tmp5 = (Mass2DPlane) mats.get(i);
				tmp5.updateGravity(g_scaled);
			}
		}
	}

	/**
	 * Get the gravity magnitude for this model
	 * @return the magnitude
	 */
	public double getGravity(){
		return g_magnitude;
	}


	public void setParamSystem(paramSystem sys){
		unit_system = sys;
	}

	public paramSystem getParamSystem(){
		return unit_system;
	}

	/**
	 * Get the differentiated position of an Osc module at a given index. (This is a
	 * prototype function, should ideally be removed or replaced).
	 *
	 * @param i
	 *            index of the Osc Module to observe.
	 * @return the speed (differentiated position) of the module.
	 */
	public double getOsc3DDeltaPos(int i) {
		Osc3D tmp;
		if (mats.get(i).getType() == matModuleType.Osc3D) {
			tmp = (Osc3D) mats.get(i);
			double dist = tmp.distRest();
			return dist;
		}
		return 0;
	}

	/**
	 * Get the current distance (length) of a Link type module
	 *
	 * @param i
	 *            index of the Link to observe.
	 * @return the current distance value.
	 */
	public double getLinkDistanceAt(int i) {

		if (getNumberOfLinks() > i)
			return links.get(i).getDist();
		else
			return 0;
	}


	/**
	 * Get the current elongation (length minus resting length) of a Link type module
	 *
	 * @param i
	 *            index of the Link to observe.
	 * @return the current elongation value.
	 */
	public double getLinkElongationAt(int i) {

		if (getNumberOfLinks() > i)
			return links.get(i).getElong();
		else
			return 0;
	}

	/**
	 * Get the resting distance of a Link type module
	 *
	 * @param i
	 *            index of the Link to observe.
	 * @return the resting distance value.
	 */
	public double getLinkDRestAt(int i) {

		if (getNumberOfLinks() > i)
			return links.get(i).getDRest();
		else
			return 0;
	}


	/**
	 * Force a Mat module to a given position (with null velocity).
	 *
	 * @param matName
	 *            identifier of the module.
	 * @param newPos
	 *            target position.
	 */
	public void setMatPosition(String matName, Vect3D newPos) {
		int mat_index = getMatIndex(matName);
		if (mat_index > -1)
			this.mats.get(mat_index).setPos(newPos);
	}


	/**
	 * Force a Mat module to a given position (with null velocity).
	 *
	 * @param index
	 *            identifier of the mat module.
	 * @param newPos
	 *            target position.
	 */
	public void setMatPosAt(int index, Vect3D newPos) {
		if ((index > -1) && index < mats.size())
			this.mats.get(index).setPos(newPos);
	}


	/**
	 * Create an empty Mat module subset item. Module indexes will be associated to
	 * this specific key later.
	 *
	 * @param name
	 *            the identifier for this subset.
	 * @return 0 if success, -1 otherwise.
	 */
	public int createMatSubset(String name) {
		if (!this.mat_subsets.containsKey(name)) {
			this.mat_subsets.put(name, new ArrayList<Integer>());
			return 0;
		}
		return -1;
	}

	/**
	 * Add a Mat module to a given subset.
	 *
	 * @param matIndex
	 *            index of the Mat module.
	 * @param subsetName
	 *            the subset to add the module to.
	 * @return 0 if success, -1 if fail.
	 */
	public int addMatToSubset(int matIndex, String subsetName) {
		if (matIndex != -1) {
			this.mat_subsets.get(subsetName).add(matIndex);
			return 0;
		}
		return -1;
	}

	/**
	 * Add a Mat module to a given subset.
	 *
	 * @param matName
	 *            identifier of the Mat module.
	 * @param subsetName
	 *            the subset to add the module to.
	 * @return 0 if success, -1 if fail.
	 */
	public int addMatToSubset(String matName, String subsetName) {
		int matIndex = this.getMatIndex(matName);
		return this.addMatToSubset(matIndex, subsetName);
	}

	/**
	 * Create an empty Link module subset item. Module indexes will be associated to
	 * this specific key later.
	 *
	 * @param name
	 *            the identifier for this subset.
	 * @return 0 if success, -1 otherwise.
	 */
	public int createLinkSubset(String name) {
		if (!this.link_subsets.containsKey(name)) {
			this.link_subsets.put(name, new ArrayList<Integer>());
			return 0;
		}
		return -1;
	}

	/**
	 * Add a Link module to a given subset.
	 *
	 * @param linkIndex
	 *            index of the Link module.
	 * @param subsetName
	 *            the subset to add the module to.
	 * @return 0 if success, -1 if fail.
	 */
	public int addLinkToSubset(int linkIndex, String subsetName) {
		if (linkIndex != -1) {
			this.link_subsets.get(subsetName).add(linkIndex);
			return 0;
		}
		return -1;
	}

	/**
	 * Add a Link module to a given subset.
	 *
	 * @param linkName
	 *            identifier of the Link module.
	 * @param subsetName
	 *            the subset to add the module to.
	 * @return 0 if success, -1 if fail.
	 */
	public int addLinkToSubset(String linkName, String subsetName) {
		int linkIndex = this.getLinkIndex(linkName);
		return this.addLinkToSubset(linkIndex, subsetName);
	}

	/**
	 * Change the mass parameters for a subset of Mat modules.
	 *
	 * @param newParam
	 *            the new mass value to apply.
	 * @param subsetName
	 *            the name of the subset of modules to address.
	 */
	public void changeMassParamOfSubset(double newParam, String subsetName) {
		for (int matIndex : this.mat_subsets.get(subsetName)) {
			mats.get(matIndex).changeMass(newParam);
		}
	}

	/**
	 * Change the stiffness parameters for a subset of Link modules.
	 *
	 * @param newParam
	 *            the new stiffness value to apply.
	 * @param subsetName
	 *            the name of the subset of modules to address.
	 */
	public void changeStiffnessParamOfSubset(double newParam, String subsetName) {

		if (unit_system == paramSystem.REAL_UNITS) {
			newParam = newParam / (simRate * simRate);
		}
		if(this.link_subsets.containsKey(subsetName))
		{
			for (int linkIndex : this.link_subsets.get(subsetName)) {
				links.get(linkIndex).changeStiffness(newParam);
			}
		}
		if(this.mat_subsets.containsKey(subsetName)) {
			for (int matIndex : this.mat_subsets.get(subsetName)) {

				if(!mats.get(matIndex).changeStiffness(newParam)) System.out.println("ouïe !!!!");
			}
		}
	}

	/**
	 * Change the damping parameters for a subset of Link modules.
	 *
	 * @param newParam
	 *            the new damping value to apply.
	 * @param subsetName
	 *            the name of the subset of modules to address.
	 */
	public void changeDampingParamOfSubset(double newParam, String subsetName) {

		if (unit_system == paramSystem.REAL_UNITS) {
			newParam = newParam / (simRate * simRate);
		}
		if(this.link_subsets.containsKey(subsetName)) {
			for (int linkIndex : this.link_subsets.get(subsetName)) {
				links.get(linkIndex).changeDamping(newParam);
			}
		}
		if(this.mat_subsets.containsKey(subsetName)) {

			for (int matIndex : this.mat_subsets.get(subsetName)) {
				mats.get(matIndex).changeDamping(newParam);
			}
		}
	}

	/**
	 * Change the resting distance parameters for a subset of Link modules.
	 *
	 * @param newParam
	 *            the new resting distance value to apply.
	 * @param subsetName
	 *            the name of the subset of modules to address.
	 */
	public void changeDistParamOfSubset(double newParam, String subsetName) {
		for (int linkIndex : this.link_subsets.get(subsetName)) {
			links.get(linkIndex).changeDRest(newParam);
		}
	}



	/* HAPTIC INPUT ELEMENTS */

	/**
	 * Add a haptic input "avatar" module (or any position input module) to the physical model.
	 *
	 * @param name
	 *            the name of the module.
	 * @param initPos
	 *            the initial position of the module.
	 * @param smoothing
	 * 			  EWMA smoothing factor for incoming position data (1 = no smoothing)
	 *
	 */

	public HapticInput3D addHapticInput3D(String name, Vect3D initPos, int smoothing) {
		HapticInput3D inputMod;
		try {
			if (matIndexList.contains(name) == true) {

				System.out.println("The module name already exists!");
				throw new Exception("The module name already exists!");
			}
			inputMod = new HapticInput3D(initPos, smoothing);
			mats.add(inputMod);
			matIndexList.add(name);
			return inputMod;

		} catch (Exception e) {
			System.out.println("Error adding Module " + name + ": " + e);
			System.exit(1);
		}
		return null;
	}

	/**
	 * Set the position of a haptic input module ("avatar") from the outside world
	 *
	 * @param matName
	 * 			  the name of the haptic module
	 * @param newPos
	 * 			  the new position value.
	 */
	public void setHapticPosition(String matName, Vect3D newPos) {
		synchronized (m_lock) {
			int mat_index = getMatIndex(matName);
			HapticInput3D tmp;
			if (mats.get(mat_index).getType() == matModuleType.HapticInput3D) {
				tmp = (HapticInput3D) mats.get(mat_index);
				tmp.applyInputPosition(newPos);
			} else {
				System.out.println("The module is not a haptic input!");
			}
		}
	}


	/**
	 * Get the force accumulated in a haptic "avatar" (to apply it to the haptic device)
	 *
	 * @param matName
	 * 			  the name of the haptic module
	 * @return the force vector.
	 */
	public Vect3D getHapticForce(String matName) {
		synchronized (m_lock) {
			int mat_index = getMatIndex(matName);
			HapticInput3D tmp;
			if (mats.get(mat_index).getType() == matModuleType.HapticInput3D) {
				tmp = (HapticInput3D) mats.get(mat_index);
				return tmp.applyOutputForce();
			} else {
				System.out.println("The module is not a haptic input!");
				return new Vect3D(0, 0, 0);
			}
		}
	}

	/**
	 * Trigger a force impulse on a given Mat module (identified by index).
	 *
	 * @param index
	 *            index of the module to apply a force to.
	 * @param fx
	 *            force in the X dimension.
	 * @param fy
	 *            force in the Y dimension.
	 * @param fz
	 *            force in the Z dimension.
	 */
	public void triggerVelocityControl(int index, double vx, double vy, double vz) {
		Vect3D force = new Vect3D(vx/simRate, vy/simRate, vz/simRate);
		try {
			mats.get(index).triggerVelocityControl(force);
		} catch (Exception e) {
			System.out.println("Issue during velocity control trigger");
			System.exit(1);
		}
	}

	/**
	 * Trigger a force impulse on a given Mat module.
	 *
	 * @param name
	 *            the name of the module to apply a force to.
	 * @param fx
	 *            force in the X dimension.
	 * @param fy
	 *            force in the Y dimension.
	 * @param fz
	 *            force in the Z dimension.
	 */
	public void triggerVelocityControl(String name, double vx, double vy, double vz) {
		int mat1_index = getMatIndex(name);
		this.triggerVelocityControl(mat1_index, vx, vy, vz);
	}


	public void stopVelocityControl(String name)
	{
		this.stopVelocityControl(getMatIndex(name));
	}

	public void stopVelocityControl(int index)
	{
		try
		{
			mats.get(index).stopVelocityControl();
		}catch (Exception e) {
			System.out.println("Issue during force impuse trigger");
			System.exit(1);
		}
	}



	private void welcome() {
		System.out.println("##library.name## ##library.prettyVersion## by ##author##");
	}

	public Lock getLock(){
		return m_lock;
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
