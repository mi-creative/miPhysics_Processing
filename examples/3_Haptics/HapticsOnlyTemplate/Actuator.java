/**
 **********************************************************************************************************************
 * @file       Actuator.java
 * @author     Steve Ding, Colin Gallacher
 * @version    V2.1.0
 * @date       19-September-2018
 * @brief      Actuator class definition
 **********************************************************************************************************************
 * @attention
 *
 *
 **********************************************************************************************************************
 */

public class Actuator{
	
	private int     actuator       = 0;
  private int     direction      = 0;
	private float   torque         = 0;
	private int     actuatorPort   = 0;

 /**
  * Creates an Actuator using motor port position 1
  */	
	public Actuator(){
		this(0, 0, 0);
	}
	

 /**
  * Creates an Actuator using the given motor port position
  *
  * @param	  actuator actuator index
  * @param    port motor port position for actuator
  */
	public Actuator(int actuator, int direction, int port){
		this.actuator = actuator;
    this.direction = direction;
		this.actuatorPort = port;
	}
	

 /**
  * Set actuator index parameter of sensor
  *
  * @param    actuator index
  */
	public void set_actuator(int actuator){
		this.actuator = actuator;
	}
	

 /**
  * Set actuator rotation direction
  *
  * @param    direction of rotation
  */
  public void set_direction(int direction){
    this.direction = direction;
  }
  
	
 /**
  * Sets motor port position to be used by Actuator
  * 
  * @param   port motor port position 
  */ 
	public void set_port(int port){
		this.actuatorPort = port;
	}
	

 /**
  * Sets torque variable to the given torque value
  *
  * @param   torque new torque value for update
  */
	public void set_torque(float torque){
		this.torque = torque;
	}

	
 /**
  * @return    actuator index
  */
	public int get_actuator(){
		return actuator;
	}


 /**
  * @return    actuator direction
  */
  public int get_direction(){
    return direction;
  }

	
 /**
  * @return   current motor port position in use
  */
	public int get_port(){
		return actuatorPort;
	}
	

 /**
  * @return   current torque information
  */
	public float get_torque(){
		return torque;
	}

}
