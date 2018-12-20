/**
 **********************************************************************************************************************
 * @file       Device.java
 * @author     Steve Ding, Colin Gallacher
 * @version    V2.2.0
 * @date       19-September-2018
 * @brief      Device class definition
 **********************************************************************************************************************
 * @attention
 *
 *
 **********************************************************************************************************************
 */
 
import java.util.Arrays;

public class Device{

	private Board           deviceLink;

	private byte            deviceID;
	private Mechanisms      mechanism;
	
	private byte            communicationType;
	
	private int             actuatorsActive    = 0;
	private Actuator[]      motors             = new Actuator[0];
	
	private int             encodersActive     = 0;
	private Sensor[]        encoders           = new Sensor[0];
	
	private int             sensorsActive      = 0;
	private Sensor[]        sensors            = new Sensor[0];
	
	private int				      pwmsActive		     = 0;
	private Pwm[]			      pwms 			         = new Pwm[0];
	
	private byte[]          actuatorPositions  = {0, 0, 0, 0};
	private byte[]          encoderPositions   = {0, 0, 0, 0};
	

 /**
  * Constructs a Device with the defined <code>deviceID</code>, connected on the specified <code>Board</code>
  *
  * @param    deviceID ID 
  * @param    deviceLink: serial link used by device
  */	
	public Device(byte deviceID, Board deviceLink){
		this.deviceID = deviceID;
		this.deviceLink = deviceLink;
	}
	
	
	// device setup functions
 /**
  * add new actuator to platform
  *
  * @param    actuator index of actuator (and index of 1-4)
  * @param    roatation positive direction of actuator rotation
  * @param    port specified motor port to be used (motor ports 1-4 on the Haply board) 
  */
	public void add_actuator(int actuator, int rotation, int port){
	
		boolean error = false;
	
		if(port < 1 || port > 4){
			System.err.println("error: encoder port index out of bounds");
			error = true;
		}
	
		if(actuator < 1 || actuator > 4){
			System.err.println("error: encoder index out of bound!");
			error = true;
		}
		
		int j = 0;
		for(int i = 0; i < actuatorsActive; i++){
			if(motors[i].get_actuator() < actuator){
				j++;
			}
			
			if(motors[i].get_actuator() == actuator){
				System.err.println("error: actuator " + actuator + " has already been set");
				error = true;
			}
		}
		
		if(!error){
			Actuator[] temp = new Actuator[actuatorsActive + 1];

			System.arraycopy(motors, 0, temp, 0, motors.length);
			
			if(j < actuatorsActive){
				System.arraycopy(motors, j, temp, j+1, motors.length - j);
			}
			
			temp[j] = new Actuator(actuator, rotation, port);
			actuator_assignment(actuator, port);
			
			motors = temp;  
			actuatorsActive++;
		}
	}


 /**
  * Add a new encoder to the platform
  *
  * @param    actuator index of actuator (an index of 1-4)
  * @param    positive direction of rotation detection
  * @param    offset encoder offset in degrees
  * @param    resolution encoder resolution
  * @param    port specified motor port to be used (motor ports 1-4 on the Haply board) 
  */  	
	public void add_encoder(int encoder, int rotation, float offset, float resolution, int port){
	
		boolean error = false;
		
		if(port < 1 || port > 4){
			System.err.println("error: encoder port index out of bounds");
			error = true;
		}
		
		if(encoder < 1 || encoder > 4){
			System.err.println("error: encoder index out of bound!");
			error = true;
		}
		
		// determine index for copying
		int j = 0;
		for(int i = 0; i < encodersActive; i++){
			if(encoders[i].get_encoder() < encoder){
				j++;
			}
			
			if(encoders[i].get_encoder() == encoder){
				System.err.println("error: encoder " + encoder + " has already been set");
				error = true;
			}
		}
		
		if(!error){
			Sensor[] temp = new Sensor[encodersActive + 1];
			
			System.arraycopy(encoders, 0, temp, 0, encoders.length);
      
			if(j < encodersActive){
				System.arraycopy(encoders, j, temp, j+1, encoders.length - j);
			}
			
			temp[j] = new Sensor(encoder, rotation, offset, resolution, port);
			encoder_assignment(encoder, port);
			
			encoders = temp;
			encodersActive++;
		}
	}
	
	
 /**
  * Add an analog sensor to platform
  *
  * @param    pin the analog pin on haply board to be used for sensor input (Ex: A0)
  */    
	public void add_analog_sensor(String pin){
		// set sensor to be size zero
		boolean error = false;
		
		char port = pin.charAt(0);
		String number = pin.substring(1);
		
		int value = Integer.parseInt(number);
		value = value + 54;
		
		for(int i = 0; i < sensorsActive; i++){
			if(value == sensors[i].get_port()){
				System.err.println("error: Analog pin: A" + (value - 54) + " has already been set");
				error = true;
			}
		}
		
		if(port != 'A' || value < 54 || value > 65){
				System.err.println("error: outside analog pin range");
				error = true;
		}
		
		if(!error){
			Sensor[] temp = Arrays.copyOf(sensors, sensors.length + 1);
			temp[sensorsActive] = new Sensor();
			temp[sensorsActive].set_port(value);
			sensors = temp;
			sensorsActive++;
		}
	}

	
 /**
  * Add a PWM output pin to the platform
  *
  * @param		pin the pin on the haply board to use as the PWM output pin 
  */
	public void add_pwm_pin(int pin){
		
		boolean error = false;
		
		for(int i = 0; i < pwmsActive; i++){
			if(pin == pwms[i].get_pin()){
				System.err.println("error: pwm pin: " + pin + " has already been set");
				error = true;
			}
		}
		
		if(pin < 0 || pin > 13){
				System.err.println("error: outside pwn pin range");
				error = true;
		}

    if(pin == 0 || pin == 1){
        System.out.println("warning: 0 and 1 are not pwm pins on Haply M3 or Haply original");
    }
		
		
		if(!error){
			Pwm[] temp = Arrays.copyOf(pwms, pwms.length + 1);
			temp[pwmsActive] = new Pwm();
			temp[pwmsActive].set_pin(pin);
			pwms = temp;
			pwmsActive++;
		}
		
		
	}
	

 /**
  * Set the device mechanism that is to be used
  *
  * @param    mechanisms new Mechanisms for use
  */	
	public void set_mechanism(Mechanisms mechanism){
		this.mechanism = mechanism;
	}
	
	

 /**
  * Gathers all encoder, sensor, pwm setup inforamation of all encoders, sensors, and pwm pins that are 
  * initialized and sequentialy formats the data based on specified sensor index positions to send over 
  * serial port interface for hardware device initialization
  */
	public void device_set_parameters(){
		
		communicationType = 1;
		
		int control;
		
		float[] encoderParameters;
    
		byte[] encoderParams;
		byte[] motorParams;
		byte[] sensorParams;
		byte[] pwmParams;
		
		if(encodersActive > 0){	
      encoderParams = new byte[encodersActive + 1];
			control = 0;		

			for(int i = 0; i < encoders.length; i++){
				if(encoders[i].get_encoder() != (i+1)){
					System.err.println("warning, improper encoder indexing");
					encoders[i].set_encoder(i+1);
					encoderPositions[encoders[i].get_port() - 1] = (byte)encoders[i].get_encoder();
				}
			}
			
			for(int i = 0; i < encoderPositions.length; i++){
				control = control >> 1;
				
				if(encoderPositions[i] > 0){
					control = control | 0x0008;
				}
			}
			
			encoderParams[0] = (byte)control;
		
			encoderParameters = new float[2*encodersActive];
			
			int j = 0;
			for(int i = 0; i < encoderPositions.length; i++){
				if(encoderPositions[i] > 0){
					encoderParameters[2*j] = encoders[encoderPositions[i]-1].get_offset(); 
					encoderParameters[2*j+1] = encoders[encoderPositions[i]-1].get_resolution();
					j++;
          encoderParams[j] = (byte)encoders[encoderPositions[i]-1].get_direction(); 
				}
			}
		}
		else{
      encoderParams = new byte[1];
      encoderParams[0] = 0;
			encoderParameters = new float[0];
		}
		
		
		if(actuatorsActive > 0){
      motorParams = new byte[actuatorsActive + 1];
			control = 0;
			
			for(int i = 0; i < motors.length; i++){
				if(motors[i].get_actuator() != (i+1)){
					System.err.println("warning, improper actuator indexing");
					motors[i].set_actuator(i+1);
					actuatorPositions[motors[i].get_port() - 1] = (byte)motors[i].get_actuator();
				}
			}
			
			for(int i = 0; i < actuatorPositions.length; i++){
				control = control >> 1;
				
				if(actuatorPositions[i] > 0){
					control = control | 0x0008;
				}
			}
			
			motorParams[0] = (byte)control;
      
      int j = 1;
      for(int i = 0; i < actuatorPositions.length; i++){
        if(actuatorPositions[i] > 0){
          motorParams[j] = (byte)motors[actuatorPositions[i]-1].get_direction();
          j++;
        }
      }
		}
    else{
      motorParams = new byte[1];
      motorParams[0] = 0;
    }
		
		
		if(sensorsActive > 0){
			sensorParams = new byte[sensorsActive + 1];
			sensorParams[0] = (byte)sensorsActive;
			
			for(int i = 0; i < sensorsActive; i++){
				sensorParams[i+1] = (byte)sensors[i].get_port();
			}
			
			Arrays.sort(sensorParams);
			
			for(int i = 0; i < sensorsActive; i++){
				sensors[i].set_port(sensorParams[i+1]);
			}
			
		}
		else{
			sensorParams = new byte[1];
			sensorParams[0] = 0;
		}

    
    if(pwmsActive > 0){
      byte[] temp = new byte[pwmsActive];
      
      pwmParams = new byte[pwmsActive + 1];
      pwmParams[0] = (byte)pwmsActive;
      
      
      for(int i = 0; i < pwmsActive; i++){
        temp[i] = (byte)pwms[i].get_pin();
      }
      
      Arrays.sort(temp);
      
      for(int i = 0; i < pwmsActive; i++){
        pwms[i].set_pin(temp[i]);
        pwmParams[i+1] = (byte)pwms[i].get_pin();
      }
      
    }
    else{
      pwmParams = new byte[1];
      pwmParams[0] = 0;
    }
			
		
		byte[] encMtrSenPwm = new byte[motorParams.length  + encoderParams.length + sensorParams.length + pwmParams.length];
		System.arraycopy(motorParams, 0, encMtrSenPwm, 0, motorParams.length);
    System.arraycopy(encoderParams, 0, encMtrSenPwm, motorParams.length, encoderParams.length);
		System.arraycopy(sensorParams, 0, encMtrSenPwm, motorParams.length+encoderParams.length, sensorParams.length);
    System.arraycopy(pwmParams, 0, encMtrSenPwm, motorParams.length+encoderParams.length+sensorParams.length, pwmParams.length);
		
		deviceLink.transmit(communicationType, deviceID, encMtrSenPwm, encoderParameters);	
	}
	

 /**
  * assigns actuator positions based on actuator port
  */
	private void actuator_assignment(int actuator, int port){
		if(actuatorPositions[port - 1] > 0){
			System.err.println("warning, double check actuator port usage");
		}
		
		this.actuatorPositions[port - 1] = (byte) actuator;
	}


 /**
  * assigns encoder positions based on actuator port
  */	
	private void encoder_assignment(int encoder, int port){
		
		if(encoderPositions[port - 1] > 0){
			System.err.println("warning, double check encoder port usage");
		}
		
		this.encoderPositions[port - 1] = (byte) encoder;
	}
	
	
	
	// device communication functions
 /**
  * Receives angle position and sensor inforamation from the serial port interface and updates each indexed encoder 
  * sensor to their respective received angle and any analog sensor that may be setup
  */	
	public void device_read_data(){
		communicationType = 2;
		int dataCount = 0;
		
		//float[] device_data = new float[sensorUse + encodersActive];
		float[] device_data = deviceLink.receive(communicationType, deviceID, sensorsActive + encodersActive);
	
		for(int i = 0; i < sensorsActive; i++){
			sensors[i].set_value(device_data[dataCount]);
			dataCount++;
		}
		
		for(int i = 0; i < encoderPositions.length; i++){
			if(encoderPositions[i] > 0){
				encoders[encoderPositions[i]-1].set_value(device_data[dataCount]);
				dataCount++;
			}
		}
	}
	
	
 /**
  * Requests data from the hardware based on the initialized setup. function also sends a torque output 
  * command of zero torque for each actuator in use
  */
	public void device_read_request(){
		communicationType = 2;
		byte[] pulses = new byte[pwmsActive];
		float[] encoderRequest = new float[actuatorsActive];
		
    for(int i = 0; i < pwms.length; i++){
      pulses[i] = (byte)pwms[i].get_value();
    }

		// think about this more encoder is detached from actuators
		int j = 0;
		for(int i = 0; i < actuatorPositions.length; i++){
			if(actuatorPositions[i] > 0){
				encoderRequest[j] = 0;
				j++;
			}
		}
		
		deviceLink.transmit(communicationType, deviceID, pulses, encoderRequest);
	}
	
	
 /**
  * Transmits specific torques that has been calculated and stored for each actuator over the serial
  * port interface, also transmits specified pwm outputs on pwm pins
  */
	public void device_write_torques(){
		communicationType = 2;
		byte[] pulses = new byte[pwmsActive];
		float[] deviceTorques = new float[actuatorsActive];
		
    for(int i = 0; i < pwms.length; i++){
      pulses[i] = (byte)pwms[i].get_value();
    }
		
		int j = 0;
		for(int i = 0; i < actuatorPositions.length; i++){
			if(actuatorPositions[i] > 0){
				deviceTorques[j] = motors[actuatorPositions[i]-1].get_torque();
				j++;
			}
		}
		
		deviceLink.transmit(communicationType, deviceID, pulses, deviceTorques);
	}
	

 /**
  * Set pulse of specified PWM pin
  */ 
  public void set_pwm_pulse(int pin, float pulse){
    
    for(int i = 0; i < pwms.length; i++){
      if(pwms[i].get_pin() == pin){
        pwms[i].set_pulse(pulse);
      }
    }
  }	


/**
 * Gets percent PWM pulse value of specified pin
 */
 public float get_pwm_pulse(int pin){
   
   float pulse = 0;
   
   for(int i = 0; i < pwms.length; i++){
     if(pwms[i].get_pin() == pin){
       pulse = pwms[i].get_pulse();
     }
   }
   
   return pulse;
 }

 /**
  * Gathers current state of angles information from encoder objects
  *
  * @returns    most recent angles information from encoder objects
  */
	public float[] get_device_angles(){
		float[] angles = new float[encodersActive];
		
		for(int i = 0; i < encodersActive; i++){
			angles[i] = encoders[i].get_value();
		}
		
		return angles;
	}
	
	
 /**
  * Gathers current data from sensor objects
  *
  * @returns    most recent analog sensor information from sensor objects
  */
	public float[] get_sensor_data(){
		float[] data = new float[sensorsActive];
		
		int j = 0;
		for(int i = 0; i < sensorsActive; i++){
			data[i] = sensors[i].get_value();
		}

		return data;
	}
	
	
 /**
  * Performs physics calculations based on the given angle values
  *
  * @param      angles angles to be used for physics position calculation
  * @returns    end-effector coordinate position
  */
	public float[] get_device_position(float[] angles){
		this.mechanism.forwardKinematics(angles);
		float[] endEffectorPosition = this.mechanism.get_coordinate();
		
		return endEffectorPosition;
	}
	
	
 /**
  * Calculates the needed output torques based on forces input and updates each initialized 
  * actuator respectively
  *
  * @param     forces forces that need to be generated
  * @returns   torques that need to be outputted to the physical device
  */
	public float[] set_device_torques(float[] forces){
		this.mechanism.torqueCalculation(forces);
		float[] torques = this.mechanism.get_torque();
		
		for(int i = 0; i < actuatorsActive; i++){
			motors[i].set_torque(torques[i]);
		}
		
		return torques;
	}
	
}
