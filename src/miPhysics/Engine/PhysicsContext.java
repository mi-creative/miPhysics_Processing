package miPhysics.Engine;

import java.util.*;
import java.util.concurrent.locks.*;
import java.lang.Math;

//import miPhysics.Control.ParamController;

import processing.core.*;

public class PhysicsContext {

	// myParent is a reference to the parent sketch
	PApplet myParent;

	private Lock m_lock;

	/* List of Mats and Links that compose the physical model */
//	private ArrayList<Mass> m_masses;
//	private Map<String, Mass> m_massLabels;
//
//	private ArrayList<Interaction> m_interactions;
//	private Map<String, Interaction> m_intLabels;
//
//	private ArrayList<PhyModel> m_macros;
//	private Map<String, PhyModel> m_macroLabels;
//
//	private ArrayList<Interaction> m_interactions;
//	private Map<String, Interaction> m_intLabels;

//	private ArrayList<InOut> m_inOuts;
//	private Map<String, InOut> m_inOutLabels;

	/* The simulation rate (mono rate only) */
	private int simRate;
	/* The processing sketch display rate */
	private int displayRate;

	private double simDisplayFactor;
	private int nbStepsToSim;
	private double residue;

	private paramSystem m_unit_system;

	private Map<String, ArrayList<Mass>> m_mass_subsets;
	private Map<String, ArrayList<Interaction>> m_int_subsets;

	private Medium m_medium = new Medium();

	private velUnit m_velUnits = velUnit.PER_SEC;

	private int m_errorCode = 0;

	//private Map<String, ParamController> param_controllers;

	private PhyModel m_topLevelModel = new PhyModel("top");

	/* Library version */
	public final static String VERSION = "##library.prettyVersion##";

	public PhysicsContext(int sRate, int displayRate, paramSystem sys) {
		/* Create empty Mass and Interaction arrays */
//		m_masses = new ArrayList<Mass>();
//		m_massLabels = new HashMap<String, Mass>();
//
//		m_interactions = new ArrayList<Interaction>();
//		m_intLabels = new HashMap<String, Interaction>();
//
//		m_inOuts = new ArrayList<InOut>();
//		m_inOutLabels = new HashMap<String, InOut>();

		m_mass_subsets = new HashMap<String, ArrayList<Mass>>();
		m_int_subsets = new HashMap<String, ArrayList<Interaction>>();

		//Vect3D tmp = new Vect3D(0., 0., 0.);
		//fakePlaneMat = new Ground3D(0,tmp);

		m_unit_system = sys;

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

		//param_controllers = new HashMap<String,ParamController>();

		System.out.println("Physical Model Class Initialised");
	}

	/**
	 * Constructor without specifying the parameter system (defaults to algo
	 * parameters)
	 *
	 * @param sRate
	 *            the physics sample rate
	 *
	 */
	public PhysicsContext(int sRate, int displayRate) {
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
	public PhysicsContext(int sRate) {
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
	public PhysicsContext(int sRate, paramSystem sys) {
		this(sRate, 30, sys);
		System.out.println("No specified display Rate: defaulting to 30 FPS");
	}

	/**
	 * Delete all modules in the model and start from scratch.
	 */
	public void clearModel() {
		/*
		for (int i = m_masses.size() - 1; i >= 0; i--) {
			m_masses.remove(i);
		}
		for (int i = m_interactions.size() - 1; i >= 0; i--) {
			m_interactions.remove(i);
		}*/
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


	public void setVelUnit(velUnit v){
		this.m_velUnits = v;
	}

	public int getErrorCode(){
		return m_errorCode;
	}

	public PhyModel model(){
		return m_topLevelModel;
	}


//	public <T extends Mass> T addMass(String name, T m){
//		return addMass(name, m, m_medium);
//	}
//
//	public <T extends Mass> T addMass(String name, T m, Medium med){
//		if (m_massLabels.get(name) == null){
//			try {
//				m.setName(name);
//				m.setMedium(med);
//
//				// Small trickery to input velocities (either per sample or per second)
//				Vect3D pInit = new Vect3D(m.getPos());
//				Vect3D vInit = new Vect3D(m.getPosR());
//				if (m_velUnits == velUnit.PER_SEC)
//					m.setPosR(pInit.sub(vInit.div(this.getSimRate())));
//				else
//					m.setPosR(pInit.sub(vInit));
//
//				m_masses.add(m);
//				m_massLabels.put(name, m);
//
//			} catch (Exception e) {
//				System.out.println("Error adding mass module " + name + ": " + e);
//				this.m_errorCode = -2;
//				return null;
//			}
//		}
//		else {
//			System.out.println("Could not create " + m + ", " + name + " label already exists. ");
//			this.m_errorCode = -1;
//			return null;
//		}
//		this.m_errorCode = 0;
//		return m;
//	}
//
//
//
//	public <T extends Interaction> T addInteraction(String name, T inter, Mass m1){
//		if (inter.getType() == interType.PLANECONTACT3D){
//			return addInteraction(name, inter, m1.getPt(inter), m1.getPt(inter));
//		}
//		else{
//			System.out.println("Missing argument for " + name
//					+ " (connects to two masses).");
//			this.m_errorCode = -1;
//			return null;
//		}
//	}
//
//
//	public <T extends Interaction> T addInteraction(String name, T inter, String m_id1){
//		Mass m1 = m_massLabels.get(m_id1);
//		return addInteraction(name, inter, m1.getPt(inter));
//	}
//
//
//	public <T extends Interaction> T addInteraction(String name, T inter, Mass m1, Mass m2) {
//
//		if (m_intLabels.get(name) != null) {
//			System.out.println("Cannot create interaction " + name
//					+ ": " + name + " interaction already exists. ");
//			this.m_errorCode = -1;
//			return null;
//		}
//		if (m1 == null) {
//			System.out.println("Cannot create interaction " + name
//					+ ": " + m1.getName() + " mass doesn't exist. ");
//			this.m_errorCode = -2;
//			return null;
//		} else if (m2 == null) {
//			System.out.println("Cannot create interaction " + name
//					+ ": " + m2.getName() + " mass doesn't exist. ");
//			this.m_errorCode = -3;
//			return null;
//		}
//
//		try {
//			inter.setName(name);
//			inter.connect(m1.getPt(inter), m2.getPt(inter));
//			m_interactions.add(inter);
//			m_intLabels.put(name, inter);
//
//		} catch (Exception e) {
//			System.out.println("Error adding interaction module " + name + ": " + e);
//			this.m_errorCode = -4;
//			return null;
//		}
//		this.m_errorCode = 0;
//		return inter;
//	}
//
//
//	public <T extends Interaction> T addInteraction(String name, T inter, String m_id1, String m_id2) {
//		Mass m1 = m_massLabels.get(m_id1).getPt(inter);
//		Mass m2 = m_massLabels.get(m_id2).getPt(inter);
//		return addInteraction(name, inter, m1, m2);
//	}
//
//
//	public <T extends InOut> T addInOut(String name, T mod, Mass m) {
//		if (m_inOutLabels.get(name) != null) {
//			System.out.println("Cannot create InOut " + name
//					+ ": " + name + " extern already exists. ");
//			this.m_errorCode = -1;
//			return null;
//		}
//		if (m == null) {
//			System.out.println("Cannot create InOut " + name
//					+ ": " + m.getName() + " mass doesn't exist. ");
//			this.m_errorCode = -2;
//			return null;
//		}
//		try {
//			mod.setName(name);
//			mod.connect(m);
//			m_inOuts.add(mod);
//			m_inOutLabels.put(name, mod);
//		} catch (Exception e) {
//			System.out.println("Error adding InOut module " + name + ": " + e);
//			this.m_errorCode = -4;
//			return null;
//		}
//		this.m_errorCode = 0;
//		return mod;
//	}
//
//
//	public <T extends InOut> T addInOut(String name, T mod, String m_id) {
//		Mass m = m_massLabels.get(m_id).getPt(null);
//		return addInOut(name, mod, m);
//	}
//
//
//
//    public ArrayList<Mass> getMassList(){
//        return m_masses;
//    }
//
//    public ArrayList<Interaction> getInteractionList(){
//		return m_interactions;
//	}
//
//	public int getNumberOfMasses(){
//		return m_masses.size();
//	}
//
//	public int getNumberOfInteractions(){
//		return m_interactions.size();
//	}
//
//	public ArrayList<Observer3D> getObservers(){
//		ArrayList<Observer3D> list = new ArrayList<>();
//		for(InOut element : m_inOuts){
//			if(element.getType() == inOutType.OBSERVER3D) {
//				Observer3D tmp = ((Observer3D)element);
//				list.add(tmp);
//			}
//		}
//		return list;
//	}
//
//	public ArrayList<Driver3D> getDrivers(){
//		ArrayList<Driver3D> list = new ArrayList<>();
//		for(InOut element : m_inOuts){
//			if(element.getType() == inOutType.DRIVER3D) {
//				Driver3D tmp = ((Driver3D)element);
//				list.add(tmp);
//			}
//		}
//		return list;
//	}


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
	public void compute() {
		double floatFrames = this.simDisplayFactor + this.residue;
		int nbSteps = (int) Math.floor(floatFrames);
		this.residue = floatFrames - (double) nbSteps;

		this.computeNSteps(nbSteps);
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
				m_topLevelModel.compute();
				//param_controllers.forEach((k,v)-> v.updateParams());
//
//				for (int i = 0; i < m_masses.size(); i++) {
//					m_masses.get(i).compute();
//				}
//
//				for (int i = 0; i < m_interactions.size(); i++) {
//					m_interactions.get(i).compute();
//				}
//				for (int i = 0; i < m_inOuts.size(); i++) {
//					m_inOuts.get(i).compute();
//				}
			}
		}
	}

	/**
	 * Compute a single step of the physical simulation. Should be called once the
	 * model creation is finished and the init() method has been called.
	 */
	public void computeSingleStep() {
		computeNSteps(1);
	}

	public Lock getLock(){
		return m_lock;
	}


	public Medium getGlobalMedium(){
		return this.m_medium;
	}

	public void setGlobalFriction(double d){
		this.m_medium.setMediumFriction(d);
	}

	public void setGlobalGravity(Vect3D g){
		this.m_medium.setGravity(g);
	}

	public void setGlobalGravity(double gx, double gy, double gz){
		this.m_medium.setGravity(new Vect3D(gx, gy, gz));
	}

	public double getGlobalFriction(){
		return this.m_medium.getMediumFriction();
	}

	public Vect3D getGlobalGravity(){
		return this.m_medium.getGravity();
	}



	/**
	 * Initialise the physical model once all the modules have been created.
	 */
	public void init() {

		m_topLevelModel.init();

		System.out.println("Initialisation of the physical model: ");
		System.out.println("Nb of Mats int model: " + m_topLevelModel.getNumberOfMasses());
		System.out.println("Nb of Links in model: " + m_topLevelModel.getNumberOfInteractions());

//		/* Initialise the stored distances for the springs */
//		for(Interaction inter : m_interactions)
//			inter.initDistances();

		System.out.println("Finished model init.\n");
	}
//
//
//	public boolean massExists(String name) {
//		Mass m = m_massLabels.get(name);
//		if (m == null)
//			return false;
//		else
//			return true;
//	}
//
//
//	private int removeMass(Mass m){
//		try {
//			if(m_massLabels.remove(m.getName()) == null)
//				throw(new Exception("Couldn't remove Mass module " + m + "out of label list."));
//			if(m_masses.remove(m) == false)
//				throw(new Exception("Couldn't remove Mass module " + m + "out of Array list."));
//			return 0;
//		} catch (Exception e) {
//			System.out.println("Error removing Mass Module " + m + ": " + e);
//			return -1;
//		}
//	}
//
//
//	private int removeMass(String name) {
//		Mass m = m_massLabels.get(name);
//		return removeMass(m);
//	}
//
//
//	public int removeInteraction(Interaction l) {
//		synchronized (m_lock) {
//			try {
//				if(m_intLabels.remove(l.getName()) == null)
//					throw(new Exception("Couldn't remove Interaction module " + l + "out of label list."));
//				if(m_interactions.remove(l)== false)
//					throw(new Exception("Couldn't remove Interaction module " + l + "out of Array list."));
//				return 0;
//			} catch (Exception e) {
//				System.out.println("Error removing interaction Module " + l + ": " + e);
//				return -1;
//			}
//		}
//	}
//
//	public synchronized int removeInteraction(String name) {
//		Interaction l = m_intLabels.get(name);
//		return removeInteraction(l);
//	}
//
//
//	public int removeMassAndConnectedInteractions(Mass m) {
//		synchronized (m_lock) {
//			try {
//				for (int i = m_interactions.size() - 1; i >= 0; i--) {
//					Interaction cur = m_interactions.get(i);
//					if ((cur.getMat1() == m) || (cur.getMat2() == m))
//						if(removeInteraction(cur) != 0)
//							throw(new Exception("Couldn't remove Interaction module " + cur ));
//
//				}
//				if (removeMass(m) != 0)
//					throw(new Exception("Couldn't remove Mass module " + m));
//
//				return 0;
//
//			} catch (Exception e) {
//				System.out.println("Issue removing connected interactions and mass!" + e);
//				System.exit(1);
//			}
//		}
//		return -1;
//	}
//
//
//	public int removeMassAndConnectedInteractions(String mName) {
//		Mass m = m_massLabels.get(mName);
//		return removeMassAndConnectedInteractions(m.getPt(null));
//	}


	/**
	 * Create an empty Mass module subset item. Module references will be associated to
	 * this specific key later.
	 *
	 * @param name
	 *            the identifier for this subset.
	 * @return 0 if success, -1 otherwise.
	 */
	public int createMassSubset(String name) {
		if (!this.m_mass_subsets.containsKey(name)) {
			this.m_mass_subsets.put(name, new ArrayList<Mass>());
			return 0;
		}
		return -1;
	}

	/**
	 * Add a Mass module to a given subset.
	 *
	 * @param m the mass module to reference.
	 * @param subsetName
	 *            the subset to add the module to.
	 * @return 0 if success, -1 if fail.
	 */
//	public int addMassToSubset(Mass m, String subsetName) {
//		if (m != null) {
//			this.m_mass_subsets.get(subsetName).add(m);
//			return 0;
//		}
//		else
//			return -1;
//	}
//
//	public int addMassToSubset(String name, String subsetName) {
//		Mass m = m_massLabels.get(name);
//		if (m != null){
//			this.addMassToSubset(m, subsetName);
//			return 0;
//		}
//		else
//			return -1;
//	}


	/**
	 * Create an empty Interaction module subset item. Module references will be associated to
	 * this specific key later.
	 *
	 * @param name
	 *            the identifier for this subset.
	 * @return 0 if success, -1 otherwise.
	 */
	public int createInteractionSubset(String name) {
		if (!this.m_int_subsets.containsKey(name)) {
			this.m_int_subsets.put(name, new ArrayList<Interaction>());
			return 0;
		}
		return -1;
	}

//
//	public int addInteractionToSubset(Interaction l, String subsetName) {
//		if (l != null) {
//			this.m_int_subsets.get(subsetName).add(l);
//			return 0;
//		}
//		return -1;
//	}
//
//	public int addInteractionToSubset(String name, String subsetName) {
//		Interaction l = m_intLabels.get(name);
//		if (l != null){
//			this.addInteractionToSubset(l, subsetName);
//			return 0;
//		}
//		else
//			return -1;
//	}


	public int setParamForMassSubset(param p, double value, String subsetName){
		if (this.m_mass_subsets.containsKey(subsetName)) {
			ArrayList<Mass> mList = this.m_mass_subsets.get(subsetName);

			for(int i = mList.size()-1; i >= 0; i--){
				if(mList.get(i) == null)
					mList.remove(i);
				else
					mList.get(i).setParam(p, value);
			}
			return 0;
		}
		else return -1;
	}


	public int setParamForInteractionSubset(param p, double value, String subsetName){
		if (this.m_int_subsets.containsKey(subsetName)) {
			ArrayList<Interaction> iList = this.m_int_subsets.get(subsetName);

			for(int i = iList.size()-1; i >= 0; i--){
				if(iList.get(i) == null)
					iList.remove(i);
				else
					iList.get(i).setParam(p, value);
			}
			return 0;
		}
		else return -1;
	}

	// Shouldn't need these methods as we can now access the actual masses


//	public void triggerVelocityControl(int index, double vx, double vy, double vz) {
//		Vect3D force = new Vect3D(vx/simRate, vy/simRate, vz/simRate);
//		try {
//			mats.get(index).triggerVelocityControl(force);
//		} catch (Exception e) {
//			System.out.println("Issue during velocity control trigger");
//			System.exit(1);
//		}
//	}
//
//	/**
//	 * Trigger velocity control on a given Mass module.
//	 *
//	 * @param name
//	 *            the name of the module to trigger.
//	 * @param vx
//	 *            velocity in the X dimension.
//	 * @param vy
//	 *            velocity in the Y dimension.
//	 * @param vz
//	 *            velocity in the Z dimension.
//	 */
//	public void triggerVelocityControl(String name, double vx, double vy, double vz) {
//		int mat1_index = getMatIndex(name);
//		this.triggerVelocityControl(mat1_index, vx, vy, vz);
//	}

//	/**
//	 * Stop a force impulse on a given Mass module.
//	 *
//	 * @param name
//	 *            the name of the module to stop velocity control to.
//	 */
//
//	public void stopVelocityControl(String name)
//	{
//		this.stopVelocityControl(getMatIndex(name));
//	}
//
//	/**
//	 * Stop a force impulse on a given Mass module.
//	 *
//	 * @param index
//	 *            the index of the module to stop velocity control to.
//	 */
//
//	public void stopVelocityControl(int index)
//	{
//		try
//		{
//			mats.get(index).stopVelocityControl();
//		}catch (Exception e) {
//			System.out.println("Issue during stopping velocity control for mass at index " + index );
//			System.exit(1);
//		}
//	}

//	public void addParamController(String name,String subsetName,String paramName,float rampTime)
//	{
//		param_controllers.put(name,new ParamController(this,rampTime,subsetName,paramName));
//	}
//
//	public ParamController getParamController(String name) {return param_controllers.get(name);}






	public void welcome() {
		System.out.println("##library.name## ##library.prettyVersion## by ##author##");
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