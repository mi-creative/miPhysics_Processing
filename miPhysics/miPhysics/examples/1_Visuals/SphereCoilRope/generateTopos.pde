void generatePinSphere(PhysicalModel mdl, int dimX, int dimY, int dimZ, String mName, String lName, float masValue, float dist, float K_osc, float Z_osc, float K, float Z) {
  // add the masses to the model: name, mass, initial pos, init speed
  String celName;
  Vect3D X0, V0;
  int size = 200;
  int qual = 200;
  float increment = TWO_PI/qual;
  float x1,z1,y1;
  int celCount = 0;
  int countAngles = 0;
  int x= 0;
  int y =0;
  int z = 0;
  masValue = 1.0;

  for(float theta =-PI/2; theta< PI/2; theta = theta+increment){//only 1 roTATE
    //0,0,-1 to;
    //0,0,1
    float sinz=sin(theta);
    float cosz=cos(theta);
    //define sin and cosine early
    
    for(float phi=0; phi<TWO_PI; phi = phi+(increment)){//making x,y rotation

      stroke(255,255,255);
      float sin = sin(phi);//sine of x,y angle
      float cos = cos(phi);//cosine of x,y angle 
      float sin1 = sinz;//redeclare
      float cos1 = cosz;
      x1 = cos1*cos*size;//scale x to z position
      y1 = cos1*sin*size;//repeat
      z1 = sin1*size;//z
      X0 = new Vect3D(x1+x,y1+y,z1+z);
      V0 = new Vect3D(0., 0., 0.);
      celName = mName + celCount;
      //println(celName);
      mdl.addOsc3D(celName, masValue, K_osc, Z_osc, X0, V0);
      celCount += 1;

      
    }
  }
  
  // add the spring to the model: length, stiffness, connected mats
   String celName1, celName2;
   for (int k = 0; k < qual*(qual/2)-1; k++) {
         celName1 = mName + k;
         celName2 = mName + str(k+1);
         //println("X " +celName1+celName2);
         mdl.addSpringDamper3D(lName + "1_" +k, dist, K, Z, celName1, celName2);
       }
}