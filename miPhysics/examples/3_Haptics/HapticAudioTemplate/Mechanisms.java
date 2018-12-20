/**
 **********************************************************************************************************************
 * @file       Mechanisms.java
 * @author     Steve Ding, Colin Gallacher
 * @version    V2.0.0
 * @date       19-September-2018
 * @brief      Mechanisms abstract class designed for use as a template. 
 **********************************************************************************************************************
 * @attention
 *
 *
 **********************************************************************************************************************
 */

import static java.lang.Math.*;

public abstract class Mechanisms{
		
  /**
   * Performs the forward kinematics physics calculation of a specific physical mechanism
   *
   * @param    angles angular inpujts of physical mechanisms (array element length based
   *           on the degree of freedom of the mechanism in question)
   */
	public abstract void forwardKinematics(float[] angles);
	

  /**
   * Performs torque calculations that actuators need to output
   *
   * @param    force force values calculated from physics simulation that needs to be conteracted 
   *           
   */
	public abstract void torqueCalculation(float[] forces);


  /**
   * Performs force calculations
   */
	public abstract void forceCalculation();
	

  /**
   * Performs calculations for position control
   */
	public abstract void positionControl();
	

  /**
   * Performs inverse kinematics calculations
   */
	public abstract void inverseKinematics();
	
	
  /**
   * Initializes or changes mechanisms parameters
   *
   * @param    parameters mechanism parameters 
   */
	public abstract void set_mechanism_parameters(float[] parameters);
	
	
  /**
   * Sets and updates sensor data that may be used by the mechanism
   *
   * @param    data sensor data from sensors attached to Haply board
   */
	public abstract void set_sensor_data(float[] data);
	
	
  /**
   * @return   end-effector coordinate position
   */
	public abstract float[] get_coordinate();

	
  /**
   * @return   torque values from physics calculations
   */	
	public abstract float[] get_torque();
	

  /**
   * @return   angle values from physics calculations
   */
	public abstract float[] get_angle();
	

}
