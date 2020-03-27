

void generateVolume(PhyModel mdl, int dimX, int dimY, int dimZ, String mName, String lName, float masValue, float dist, float K, float Z){
  // add the masses to the model: name, mass, initial pos, init speed
  String masName;
  Vect3D X0, V0;
  
  for (int k = 0; k < dimZ; k++) {
    for (int i = 0; i < dimY; i++) {
      for (int j = 1; j <= dimX; j++) {
        masName = mName +(j+i*dimX+k*dimX*dimY);
        println(masName);
        masValue = 1.0;
        X0 = new Vect3D(j*dist,i*dist,k*dist);
        if (masName.equals("mass1000")==true){
          V0 = new Vect3D(0.,0.,000000.);
        } else
        if (masName.equals("mass1")==true){
          V0 = new Vect3D(0.,0.,-300000.);
        } else{
          V0 = new Vect3D(0.,0.,0.);
        }
        //println(V0);
        
        mdl.addMass(masName, new Mass3D(masValue, dist/2, X0, V0));
      }
    }
  }
  
  // add the spring to the model: length, stiffness, connected mats
  String masName1, masName2;
  
  for (int k = 0; k < dimZ; k++) {
    for (int i = 0; i < dimY; i++) {
      for (int j = 1; j < dimX; j++) {
        masName1 = mName +(j+i*dimX+k*dimX*dimY);
        masName2 = mName +(j+i*dimX+k*dimX*dimY+1);
        //println("X " +masName1+masName2);

        mdl.addInteraction(lName + "1_" +i+"_"+j+"_"+k, new SpringDamper3D(dist, K, Z), masName1, masName2);
      }
    }
  }
  
  for (int k = 0; k < dimZ; k++) {
    for (int i = 1; i < dimX+1; i++) {
      for (int j = 0; j < dimY-1; j++) {
        masName1 = mName +(i+j*dimX+k*dimX*dimY);
        masName2 = mName +(i+(j+1)*dimX+k*dimX*dimY);
        //println("Y "+masName1+masName2);
   
        mdl.addInteraction(lName + "2_" +i+"_"+j+"_"+k, new SpringDamper3D(dist, K, Z), masName1, masName2);
      }
    }
  }
  
  for (int i = 1; i < dimX+1; i++) {
    for (int j = 0; j < dimY; j++) {
        for (int k = 0; k < dimZ-1; k++) {
        masName1 = mName +(i+j*dimX+k*dimX*dimY);
        masName2 = mName +(i+j*dimX+(k+1)*dimX*dimY);
        //println("Z "+masName1+masName2);
   
        mdl.addInteraction(lName + "3_" +i+"_"+j+"_"+k, new SpringDamper3D(dist, K, Z), masName1, masName2);
      }
    }
  }
}
