//One of many controls over a mass through midi NoteOn/NoteOff
//This one is really basic...
class midiNote
{

 float min;
 float max;
 String name;
  float a;
 float b;
 int indexMin;
 int indexMax;
 String direction;
 String controlType;
  midiNote(float min_,float max_,String name_,int indexMin_,int indexMax_,String direction_,String controlType_)
 {

  min=min_;
  max=max_;
  name=name_;
  indexMin = indexMin_;
  indexMax = indexMax_;
  direction = direction_;
  controlType = controlType_;
  computeScale();
 }
 void computeScale()
 {
      b = min;
   a = (max-min)/127;
 }
 void on(int pitch,int velocity)
 {
   if(pitch >= indexMin && pitch <= indexMax)
   {
   if( direction == "X")
   {
     if(controlType == "impulse")  simUGen.mdl.triggerForceImpulse(name+pitch,a*velocity+b,0,0);
     else if(controlType == "pluck") simUGen.mdl.triggerVelocityControl(name+pitch,a*velocity+b,0,0);
   }
   if( direction == "Y") 
   {
     if(controlType == "impulse") simUGen.mdl.triggerForceImpulse(name+pitch,0,a*velocity+b,0);
     else if(controlType == "pluck") simUGen.mdl.triggerVelocityControl(name+pitch,0,a*velocity+b,0);
   }
   if( direction == "Z")
   {
     if(controlType == "impulse") simUGen.mdl.triggerForceImpulse(name+pitch,0,0,a*velocity+b);
     else if(controlType == "pluck") simUGen.mdl.triggerVelocityControl(name+pitch,0,0,a*velocity+b);
   }
   }
 }
 void off(int pitch,int velocity)
 {
   if(controlType == "pluck") simUGen.mdl.stopVelocityControl(name+pitch); //<>//
 }
}
