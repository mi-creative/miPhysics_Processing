PhyModel buildWreckingBall(String name, Medium med) {

  // some initial coordinates for the modules.
  Vect3D initPos = new Vect3D(270., 0., 360.);
  Vect3D initPos2 = new Vect3D(180., 0., 360.);
  Vect3D initPos3 = new Vect3D(90., 0., 360.);
  Vect3D initPos4 = new Vect3D(0., 0., 360.);
  Vect3D initV = new Vect3D(0., 0., 0.);
  
  PhyModel model = new PhyModel(name, med);
  
  model.addMass("mass1", new Mass3D(200, 40, initPos, initV));
  model.addMass("mass2", new Mass3D(10, 15, initPos2, initV));
  model.addMass("mass3", new Mass3D(10, 10, initPos3, initV));
  model.addMass("ground1", new Ground3D(5, initPos4));

  model.addInteraction("rope1", new Rope3D(90, 0.2, 0.8), "mass1", "mass2");
  model.addInteraction("rope2", new Rope3D(90, 0.2, 0.8), "mass2", "mass3");
  model.addInteraction("rope3", new Rope3D(90, 0.2, 0.8), "mass3", "ground1");
  
  model.translate(-100, 0, 0);

  return model;
}
