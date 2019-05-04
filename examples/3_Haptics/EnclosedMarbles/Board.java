/**
 **********************************************************************************************************************
 * @file       Board.java
 * @author     Steve Ding, Colin Gallacher
 * @version    V2.1.0
 * @date       19-September-2018
 * @brief      Board class definition
 **********************************************************************************************************************
 * @attention
 *
 *
 **********************************************************************************************************************
 */

import processing.core.PApplet;
import processing.serial.*;

public class Board{

	private Serial     port;
	private PApplet    applet;
	
	private byte       deviceID;
	

 /**
  * Constructs a Board linking to the specified serial port at the given serial data speed (baud rate)
  * 
  * @param    app the parent Applet this class runs inside (this is your Processing sketch)
  * @param    portname serial port name that the hardware board is connected to (eg, "com10")
  * @param    speed the baud rate of serial data transfer
  */	
	public Board(PApplet app, String portName, int baud){
		this.applet = app;
		port = new Serial(applet, portName, baud);
		port.clear();
		reset_board();
	}
	

 /**
  * Formats and transmits data over the serial port
  * 
  * @param     communicationType type of communication taking place
  * @param     deviceID ID of device transmitting the information
  * @param     bData byte inforamation to be transmitted
  * @param     fData float information to be transmitted
  */	
	public void transmit(byte communicationType, byte deviceID, byte[] bData, float[] fData){
		byte[] outData = new byte[2 + bData.length + 4*fData.length];
		byte[] segments = new byte[4];
		
		outData[0] = communicationType;
		outData[1] = deviceID;
		
		this.deviceID = deviceID;
		
		System.arraycopy(bData, 0, outData, 2, bData.length);
		
		int j = 2 + bData.length;
		for(int i = 0; i < fData.length; i++){
			segments = FloatToBytes(fData[i]);
			System.arraycopy(segments, 0, outData, j, 4);
			j = j + 4;
		}
		
		this.port.write(outData);
	}
	
	
 /**
  * Receives data from the serial port and formats data to return a float data array
  * 
  * @param     type type of communication taking place
  * @param     deviceID ID of the device receiving the information
  * @param     expected number for floating point numbers that are expected
  * @return    formatted float data array from the received data
  */
	public float[] receive(byte communicationType, byte deviceID, int expected){
		
		set_buffer(1 + 4*expected);
		
		byte[] segments = new byte[4];
		
		byte[] inData = new byte[1 + 4*expected];
		float[] data = new float[expected];
		
		this.port.readBytes(inData);
		
		if(inData[0] != deviceID){
			System.err.println("Error, another device expects this data!");
		}
		
		int j = 1;
		
		for(int i = 0; i < expected; i++){
			System.arraycopy(inData, j, segments, 0, 4);
			data[i] = BytesToFloat(segments);
			j = j + 4;
		}
		
		return data;
	}
	

 /**
  * @return   a boolean indicating if data is available from the serial port
  */	
	public boolean data_available(){
		boolean available = false;
		
		if(port.available() > 0){
			available = true;
		}
		
		return available;
	}
	

 /**
  * Sends a reset command to perform a software reset of the Haply board
  *
  */	
	private void reset_board(){
		byte communicationType = 0;
		byte deviceID = 0;
		byte[] bData = new byte[0];
		float[] fData = new float[0];
		
		transmit(communicationType, deviceID, bData, fData);
	}
	

  /**
   * Set serial buffer length for receiving incoming data
   *
   * @param   length number of bytes expected in read buffer
   */	
	private void set_buffer(int length){
		this.port.buffer(length);
	}

	
  /**
   * Translates a float point number to its raw binary format and stores it across four bytes
   *
   * @param    val floating point number
   * @return   array of 4 bytes containing raw binary of floating point number
   */ 
	private byte[] FloatToBytes(float val){
  
		byte[] segments = new byte[4];
  
		int temp = Float.floatToRawIntBits(val);
  
		segments[3] = (byte)((temp >> 24) & 0xff);
		segments[2] = (byte)((temp >> 16) & 0xff);
		segments[1] = (byte)((temp >> 8) & 0xff);
		segments[0] = (byte)((temp) & 0xff);

		return segments;
  
	}


  /**
   * Translates a binary of a float point to actual float point
   *
   * @param    segment array containing raw binary of floating point
   * @return   translated floating point number
   */ 	
	private float BytesToFloat(byte[] segment){
  
		int temp = 0;
  
		temp = (temp | (segment[3] & 0xff)) << 8;
		temp = (temp | (segment[2] & 0xff)) << 8;
		temp = (temp | (segment[1] & 0xff)) << 8;
		temp = (temp | (segment[0] & 0xff)); 
  
		float val = Float.intBitsToFloat(temp);
  
		return val;
	}	

}
