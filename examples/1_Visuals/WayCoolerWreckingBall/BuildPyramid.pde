PhyModel buildPyramid(String name, Medium med, int baseSize, double baseDist, int levels) {

  PhyModel model = new PhyModel(name, med);


  for (int lev = 0; lev < levels; lev++) {
    for (int i = 0; i < baseSize-lev; i++) {
      for (int j = 0; j < baseSize-lev; j++) {
        if ((lev ==0) && ((j==0) || (i ==0) || (j==baseSize-lev-1) || (i == baseSize-lev-1)))
          model.addMass("pBase_"+i+"_"+j+"_"+lev, new Ground3D(0.5*baseDist, new Vect3D(1.*(i+lev*0.5) * baseDist, 1.*(j+lev*0.5) * baseDist, 0.5*baseDist)));
        else {
          model.addMass("pBase_"+i+"_"+j+"_"+lev, new Mass3D(1, 0.5*baseDist, new Vect3D(1.*(i+lev*0.5) * baseDist, 1.*(j+lev*0.5) * baseDist, 0.5*baseDist + sin(PI/4)*lev*baseDist)));
        }
      }
    }
  }
  int cpt = 0;
  for(Mass m : model.getMassList()){
    model.addInteraction("plane" + cpt++, new PlaneContact3D(0.1, 0.01, 2, 0), m);
  }
  
  // Brute force collision algorithms between elements... very expensive to compute !
  /*
  for(int i = 0; i < model.getNumberOfMasses(); i++){
    for(int j = i; j < model.getNumberOfMasses(); j++){
      model.addInteraction("col_"+i+"_"+j, new Contact3D(0.1, 0.1), model.getMassList().get(i), model.getMassList().get(j));
    }
  }
  */

  
  model.translate(-200, -140, 0);

  return model;
}
