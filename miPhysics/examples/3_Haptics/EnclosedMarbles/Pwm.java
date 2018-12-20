/**
 **********************************************************************************************************************
 * @file       Pwm.java
 * @author     Steve Ding, Colin Gallacher
 * @version    V1.0.0
 * @date       19-September-2018
 * @brief      Pwm class definition
 **********************************************************************************************************************
 * @attention
 *
 *
 **********************************************************************************************************************
 */

public class Pwm{
	
  private int       pin         = 0;
  private int       value       = 0;
	
	
	/**
	 * Constructs an empty PWM output for use
	 */
	 public Pwm(){
		this(0, 0);
	 }
	 
	 /**
	  * Constructs a PWM output at the specified pin and at the desired percentage 
	  * 
	  *	@param	pin pin to output pwm signal
	  * @param 	pulseWidth percent of pwm output, value between 0 to 100
	  */
	  public Pwm(int pin, float pulseWidth){
		  this.pin = pin;
		  
		  if(pulseWidth > 100.0){
			  this.value = 255;
		  }
		  else{
			  this.value = (int)(pulseWidth * 255 / 100);
		  }
	  }
	  
	  
	/**
	 * Set pin parameter of pwm
	 * 
	 * @param	pin pin to output pwm signal
	 */
	 public void set_pin(int pin){
		this.pin = pin;
	 }
	
	
	/**
	 * Set value variable of pwm
	 */
	 public void set_pulse(float percent){
		 
		if(percent > 100.0){
			this.value = 255;
		}	else if(percent < 0){
  	  this.value = 0;
    }	
		else{
			this.value = (int)(percent * 255 / 100);
		}			
	 }
	  
	
	/**
	 * @return	pin pwm signal is outputting
	 */
	 public int get_pin(){
		return pin;
	 }
	  

  /**
   * @return raw value of pwm signal between 0 to 255   
   */
   public int get_value(){    
    return value;
   }

	  
	/**
	 * @return percent value of pwm signal	 
	 */
	 public float get_pulse(){
		 
		float percent = value * 100 / 255;
		
		return percent;
	 }

}
