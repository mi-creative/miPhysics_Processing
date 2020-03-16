void generateMesh(PhysicalModel mdl, int dimX, int dimY, String mName, String lName, double masValue, double dist, double K_osc, double Z_osc, double K, double Z) {
  // add the masses to the model: name, mass, initial pos, init speed
  String masName;
  Vect3D X0;

  for (int i = 0; i < dimY; i++) {
    for (int j = 0; j < dimX; j++) {
      masName = mName + j +"_"+ i;
      X0 = new Vect3D((float)j*dist,(float)i*dist, 0.);
      mdl.addMass(masName, new Osc1D(masValue, 1, K_osc, Z_osc, X0));
    }
  }
  // add the spring to the model: length, stiffness, connected mats
  String masName1, masName2;

    for (int i = 0; i < dimX; i++) {
      for (int j = 0; j < dimY-1; j++) {
        masName1 = mName + i +"_"+ j;
        masName2 = mName + i +"_"+ str(j+1);
        mdl.addInteraction(lName + "1_" +i+"_"+j, new SpringDamper1D(0, K, Z), masName1, masName2);
      }
    }
    
    for (int i = 0; i < dimX-1; i++) {
      for (int j = 0; j < dimY; j++) {
        masName1 = mName + i +"_"+ j;
        masName2 = mName + str(i+1) +"_"+ j;
        mdl.addInteraction(lName + "2_" +i+"_"+j, new SpringDamper1D(0, K, Z), masName1, masName2);
      }
    }
}
