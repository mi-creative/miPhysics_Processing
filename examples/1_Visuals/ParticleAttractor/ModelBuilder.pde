void buildModel(int collisionModel){
  
  phys = new PhysicsContext(300, displayRate);
  PhyModel mdl = phys.mdl();
  
  phys.setGlobalFriction(0.005);
  phys.setGlobalGravity(0, -0.0, 0.);
  
  if(collisionModel < 2)
    nbMass = 600;
  else
    nbMass = 3600;
    

  /* Create a mass, connected to fixed points via Spring Dampers */
  mdl.addMass("attractor1", new Osc3D(1000., 10, 0.5, 0.1, new Vect3D(0., 0., -150.)));
  mdl.addMass("attractor2", new Osc3D(1200., 10, 0.6, 0.1, new Vect3D(0., 0., 0.)));
  mdl.addMass("attractor3", new Osc3D(1400., 10, 0.4, 0.1, new Vect3D(0., 0., 150.)));

  
  // Create a bunch of masses with randomised spherical coordinates
  for(int i = 0; i < nbMass; i++){
    float rR = random(100.);
    float rThe = random(2.*PI);
    float rPhi = random(2.*PI);
    
    mdl.addMass("mass"+i, new Mass3D(1, 4, 
    new Vect3D(rR * sin(rThe)*cos(rPhi), rR * sin(rThe)*sin(rPhi), rR * cos(rThe)), 
    new Vect3D(0., 0., 0.)));
    
    // Add enclosing "Bubble" interaction to keep masses inside a sphere
    mdl.addInteraction("at1_"+i, new Attractor3D(50, 100), "attractor1", "mass"+i);
    mdl.addInteraction("at2_"+i, new Attractor3D(50, 100), "attractor2", "mass"+i);
    mdl.addInteraction("at3_"+i, new Attractor3D(50, 100), "attractor3", "mass"+i);

    
    // set a driver for each mass in the system
    mdl.addInOut("drive"+i,new Driver3D(),"mass"+i);

  }
  
  ld = new LineDrawer[nbMass+3];
  for(int i = 0; i < nbMass+3; i++)
    ld[i] = new LineDrawer(color(255, 255, 255), 50);
  
  
  if(collisionModel < 2){ 
    if(collisionModel == 0)
      phys.colEngine().addAutoCollision(phys.mdl(),30,20,0.01,0.0001);
    else{
    for(int i = 0; i < nbMass; i++)
      for(int j = i; j < nbMass; j++)
        mdl.addInteraction("cnt"+i+"_"+j, new Contact3D(0.01, 0.01), "mass"+i, "mass"+j);
    }
  }
  
  phys.init(); 




}
