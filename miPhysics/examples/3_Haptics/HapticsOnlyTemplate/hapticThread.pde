/* Haptic Simulation Thread */
class SimulationThread implements Runnable {
  
  public void run(){
    /* put haptic simulation code here, runs repeatedly at 1kHz as defined in setup */
    
    /* Monitor elapsed time for any missed steps */
    end = System.nanoTime();
    elapsed = (end - start)/1000;
    start = end;
    if(elapsed > (float)microtimeRate * 1.5){
      stepsMissed++;
    }
    
    if(haplyBoard.data_available()){
      /* get encoder values from Haply and construct angles */
      widgetOne.device_read_data();
      angles.set(widgetOne.get_device_angles());
      
      /* construct 2D position from angles */
      tmp.set(widgetOne.get_device_position(angles.array()));
      posEE.x = - alpha * tmp.x + offset_x;
      posEE.y = alpha * tmp.y + offset_y;
      
      /* apply position to model, calculate step and get applied force */
      mdl.setHapticPosition("hapticMass", new Vect3D(posEE.x, posEE.y, 0));    
      mdl.computeStep();
      frcOut = mdl.getHapticForce("hapticMass");

      /* apply scaling factor to force */
      fEE.x = -beta * (float)frcOut.x;
      fEE.y = beta * (float)frcOut.y;
    }
    /* build torque values from 2D force and apply to device */
    torques.set(widgetOne.set_device_torques(fEE.array()));
    widgetOne.device_write_torques(); 
  }
}
