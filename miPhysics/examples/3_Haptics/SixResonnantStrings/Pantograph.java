/**
 **********************************************************************************************************************
 * @file       Pantograph.java
 * @author     Steve Ding, Colin Gallacher
 * @version    V2.0.0
 * @date       19-September-2018
 * @brief      Mechanism extension example
 **********************************************************************************************************************
 * @attention
 *
 *
 **********************************************************************************************************************
 */

import static java.lang.Math.*;


public class Pantograph extends Mechanisms{

	private float l, L, d;
	
	private float th1, th2;
	private float tau1, tau2;
	private float f_x, f_y;
	private float x_E, y_E;
	
	private float pi = 3.14159265359f;
	private float J11, J12, J21, J22;
	private float gain = 0.1f;
	
	public Pantograph(){
		this.l = 0.05f;
		this.L = 0.07f;
		this.d = 0.02f;
	}
	
	
	public void forwardKinematics(float[] angles){
		th1 = pi/180*angles[0];
		th2 = pi/180*angles[1];
		
		// Forward Kinematics
		float c1 = (float)cos(th1);
		float c2 = (float)cos(th2);
		float s1 = (float)sin(th1);
		float s2 = (float)sin(th2);
    
		float xA = l*c1;
		float yA = l*s1;
		float xB = d+l*c2;
		float yB = l*s2;
		float R = (float)pow(xA,2) + (float)pow(yA,2);
		float S = (float)pow(xB,2) + (float)pow(yB,2);
		float M = (yA-yB)/(xB-xA);
		float N = (float)0.5*(S-R)/(xB-xA);
		float a = (float)pow(M,2)+1;
		float b = 2*(M*N-M*xA-yA);
		float c = (float)pow(N,2)-2*N*xA+R-(float)pow(L,2);
		float Delta = (float)pow(b,2)-4*a*c;
		
		y_E = (-b+(float)sqrt(Delta))/(2*a);
		x_E = M*y_E+N;	
		
		float phi1 = (float)acos((x_E-l*c1)/L);
		float phi2 = (float)acos((x_E-d-l*c2)/L);
		float s21 = (float)sin(phi2-phi1);
		float s12 = (float)sin(th1-phi2);
		float s22 = (float)sin(th2-phi2);
		J11 = -(s1*s21 + (float)sin(phi1)*s12)/s21;
		J12 = (c1*s21 + (float)cos(phi1)*s12)/s21;
		J21 = (float)sin(phi1)*s22/s21;
		J22 = -(float)cos(phi1)*s22/s21;
	}

	
	public void torqueCalculation(float[] force){
		f_x = force[0];
		f_y = force[1];
		
		tau1 = J11*f_x + J12*f_y;
		tau2 = J21*f_x + J22*f_y;
		
		tau1 = tau1*gain;
		tau2 = tau2*gain;
	}
	
	
	public void forceCalculation(){
	}
	
	
	public void positionControl(){
	}
	
	
	public void inverseKinematics(){
	}
	
	
	public void set_mechanism_parameters(float[] parameters){
		this.l = parameters[0];
		this.L = parameters[1];
		this.d = parameters[2];
	}
	
	
	public void set_sensor_data(float[] data){
	}
	
	
	public float[] get_coordinate(){
		float temp[] = {x_E, y_E};
		return temp;
	}
	
	
	public float[] get_torque(){
		float temp[] = {tau1, tau2};
		return temp;
	}
	
	
	public float[] get_angle(){
		float temp[] = {th1, th2};
		return temp;
	}





}
