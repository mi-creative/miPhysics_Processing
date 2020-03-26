//One of many controls over a mass through midi NoteOn/NoteOff
//This one is really basic...
class midiNote
{

 float min;
 float max;
 float a;
 float b;
 int indexMin;
 int indexMax;
 String direction;
 String controlType;
 
 Mass m;
 
  midiNote(float min_,float max_, PhyModel pm_,String controlType_)
 {

  min=min_;
  max=max_;
  indexMin = 0;
  indexMax = pm_.getNumberOfMasses();
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
   if(pitch > indexMin && pitch < indexMax)
   {
     String name = "m_"+pitch + "_0_0";
     m = phys.mdl().getPhyModel("string").getMass(name);
     d.connect(m);
     
     if(controlType == "impulse")
       d.applyFrc(new Vect3D(0,a*velocity+b,0));
     else if(controlType == "pluck")
       m.triggerVelocityControl(new Vect3D(0,0.0001 * a*velocity+b,0));
   }
 }
 void off(int pitch,int velocity)
 {
   if(controlType == "pluck")
     if(m!=null)
       m.stopVelocityControl();
 }
}
