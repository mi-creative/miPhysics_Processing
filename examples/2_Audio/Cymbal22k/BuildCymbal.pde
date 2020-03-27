PhyModel createCymbal(int dimX, int dimY, String mName, String lName, double masValue, double dist, double K, double Z) {

  PhyModel mdl = new PhyModel("cymbal", phys.getGlobalMedium());
  
  String masName;
  Vect3D X0;
  for (int i = 0; i < dimY; i++) {
    for (int j = 0; j < dimX; j++) {
      masName = mName + j +"_"+ i;
      X0 = new Vect3D((float)j*dist, (float)i*dist, 0.);
      float m = min((float)(masValue*(1+0.01*i*dimX)), (float)(masValue*(1+0.01*(dimX-i)))); 
      if ((i==dimY/2) && (j == dimX/2))
        mdl.addMass(masName, new Ground3D(1, X0));
      else
        mdl.addMass(masName, new Mass1D(m, 10, X0));
    }
  }

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
      mdl.addInteraction(lName + "2_" +i+"_"+j, new SpringDamper3D(dist*0.9, K, Z), masName1, masName2);
    }
  }
  
  double radius = ((dimX/2)-1)*dist; 
  Vect3D center = new Vect3D(dist*dimX/2, dist*dimY/2, 0);
  
  ArrayList<Mass> toRemove = new ArrayList<Mass>();
  for (Mass m : mdl.getMassList()) {
    if (m.getPos().dist(center) > radius)
      toRemove.add(m);
  }
  for (Mass m : toRemove)
    mdl.removeMassAndConnectedInteractions(m);

  mdl.addInOut("list_1", new Observer3D(filterType.HIGH_PASS), "osc16_24");
  mdl.addInOut("list_2", new Observer3D(filterType.HIGH_PASS), "osc13_23");

  return mdl;

}
