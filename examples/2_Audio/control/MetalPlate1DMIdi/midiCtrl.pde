//Attempt for a generic parameter controller
//TODO logarithmic scaling
//TODO two controller logarithmic control
//TODO manage to begin the simulation after setting parameters through the MIDI controller
// unless it can produce undesired effects at first control
//TODO handle channels

class midiCtrl
{
 int ctrl;
 float min;
 float max;
 String name;
 String param;
 float a;
 float b;
 
 
 midiCtrl(int ctrl_,float min_,float max_,String name_,String param_)
 {
  ctrl=ctrl_;
  min=min_;
  max=max_;
  name=name_;
  param=param_;
  computeScale();
 }
 
 float scale(int val)
 {
   return a*val + b;
 }
 
 void computeScale()
 {
   b = min;
   a = (max-min)/127;
 }
 
 void changeParam(int val)
 { //<>//
   if(param == "stiffness")
    simUGen.mdl.changeStiffnessParamOfSubset(scale(val),name);
    else if(param == "damping")
     simUGen.mdl.changeDampingParamOfSubset(scale(val),name);
    else if(param == "mass")
    simUGen.mdl.changeMassParamOfSubset(scale(val),name);
 }
 void ctrl(int number,int value)
 {
   if(ctrl == number)   changeParam(value); //<>//
 }
}
