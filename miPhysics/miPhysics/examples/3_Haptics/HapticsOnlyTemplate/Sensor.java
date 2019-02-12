/**
 **********************************************************************************************************************
 * @file       Sensor.java
 * @author     Steve Ding, Colin Gallacher
 * @version    V2.1.0
 * @date       19-September-2018
 * @brief      Sensor class definition
 **********************************************************************************************************************
 * @attention
 *
 *
 **********************************************************************************************************************
 */

public class Sensor{

	private int     encoder              = 0;
  private int     direction            = 0;
	private float   encoder_offset       = 0;
	private float   encoder_resolution   = 0;
	private float   value                = 0;
	private int     port                 = 0;
	

 /**
  * Constructs a Sensor set using motor port position one
  */
	public Sensor(){
		this(0, 0, 0, 0, 0);	
	}
	

 /**
  * Constructs a Sensor with the given motor port position, to be initialized with the given angular offset,
  * at the specified step resolution (used for construction of encoder sensor)
  *
  * @param    encoder encoder index
  * @param    offset initial offset in degrees that the encoder sensor should be initialized at
  * @param    resolution step resolution of the encoder sensor
  * @param    port specific motor port the encoder sensor is connect at (usually same as actuator)
  */
	public Sensor(int encoder, int direction, float offset, float resolution, int port){
		this.encoder = encoder;
    this.direction = direction;
		this.encoder_offset = offset;
		this.encoder_resolution = resolution;
		this.port = port;
	}
	
 
 /**
  * Set encoder index parameter of sensor
  *
  * @param    encoder index
  */
	public void set_encoder(int encoder){
		this.encoder = encoder;
	}


 /**
  * Set encoder direction of detection 
  *
  * @param    encoder index
  */
  public void set_direction(int direction){
    this.direction = direction;
  }
	
	
 /**
  * Set encoder offset parameter of sensor
  *
  * @param    offset initial angular offset in degrees
  */
	public void set_offset(float offset){
		this.encoder_offset = offset;
	}


 /**
  * Set encoder resolution parameter of sensor
  *
  * @param    resolution step resolution of encoder sensor
  */	
	public void set_resolution(float resolution){
		this.encoder_resolution = resolution;
	}
	

 /**
  * Set motor port position to be used by sensor
  *
  * @param    port motor port position (motor port connection on Haply board)
  */
	public void set_port(int port){
		this.port = port;
	}
	

 /**
  * Set sensor value variable to the specified input
  *
  * @param    value sensor value
  */  
	public void set_value(float value){
		this.value = value;
	}
	

 /**
  * @return    encoder index
  */
	public int get_encoder(){
		return encoder;
	}


 /**
  * @return    encoder direction
  */
  public int get_direction(){
    return direction;
  }
	
	
 /**
  * @return    current offset parameter
  */
	public float get_offset(){
		return encoder_offset;
	}
	

 /**
  * @return    encoder resolution of encoder sensor being used
  */
	public float get_resolution(){
		return encoder_resolution;
	}
	

 /**
  * @return    current motor port position
  */
	public int get_port(){
		return port;
	}


 /**
  * @return    current sensor value information
  */	
	public float get_value(){
		return value;
	}

}
