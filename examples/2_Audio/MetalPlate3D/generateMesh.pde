void generateMesh(PhysicalModel mdl, int dimX, int dimY, String mName, String lName, double masValue, double dist,double K, double Z) {
  // add the masses to the model: name, mass, initial pos, init speed
  String masName;
  Vect3D X0;

  for (int i = 0; i < dimY; i++) {
    for (int j = 0; j < dimX; j++) {
      masName = mName + j +"_"+ i;
      X0 = new Vect3D((float)j*dist,(float)i*dist, 0.);
      if((i==0) || (i == dimY-1) || (j==0) || (j == dimX-1))
        mdl.addMass(masName, new Ground3D(1, X0));
      else
        mdl.addMass(masName, new Mass3D(masValue, 10, X0));
    }
  }
  // add the spring to the model: length, stiffness, connected mats
  String masName1, masName2;

    for (int i = 0; i < dimX; i++) {
      for (int j = 0; j < dimY-1; j++) {
        masName1 = mName + i +"_"+ j;
        masName2 = mName + i +"_"+ str(j+1);
        mdl.addInteraction(lName + "1_" +i+"_"+j, new SpringDamper3D(dist*0.1, K, Z), masName1, masName2);
      }
    }
    
    for (int i = 0; i < dimX-1; i++) {
      for (int j = 0; j < dimY; j++) {
        masName1 = mName + i +"_"+ j;
        masName2 = mName + str(i+1) +"_"+ j;
        mdl.addInteraction(lName + "2_" +i+"_"+j, new SpringDamper3D(dist*0.1, K, Z), masName1, masName2);
      }
    }
}
