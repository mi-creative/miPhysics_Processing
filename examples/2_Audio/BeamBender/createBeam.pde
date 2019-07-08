void generateVolume(PhysicalModel mdl, int dimX, int dimY, int dimZ, String mName, String lName, String subSetName, float masValue, float l0, float dist, float K, float Z) {

  String masName;
  Vect3D X0, V0;
  String springName;
  mdl.createLinkSubset(subSetName);
  mdl.createLinkSubset(subSetName+"_1axe");
  mdl.createLinkSubset(subSetName+"_2axes");
  mdl.createLinkSubset(subSetName+"_3axes");
  



  // add the masses to the model: name, mass, initial pos, init speed
  for (int k = 0; k < dimZ; k++) {
    for (int i = 0; i < dimY; i++) {
      for (int j = 1; j <= dimX; j++) {
        masName = mName +(j+i*dimX+k*dimX*dimY);
        println(masName);
        masValue = 1.0;
        X0 = new Vect3D(j*dist-(dimX/2*dist), i*dist, k*dist);
        V0 = new Vect3D(0., 0., 0.);
        if(j==1){
          mdl.addGround3D(masName, X0);
          groundsL.append(masName);
        }
        else if (j==dimX){
           mdl.addGround3D(masName, X0);
          groundsR.append(masName);
        }
        else
          mdl.addMass3D(masName, masValue, X0, V0);
      }
    }
  }
  println(groundsL);
  println(groundsR);

  

  // add the spring to the model: length, stiffness, connected mats
  String masName1, masName2;

  for (int k = 0; k < dimZ; k++) {
    for (int i = 0; i < dimY; i++) {
      for (int j = 1; j < dimX; j++) {
        masName1 = mName +(j+i*dimX+k*(dimX*dimY));
        masName2 = mName +(j+i*dimX+k*(dimX*dimY)+1);
        springName = lName + "1_" +i+j+k;
        mdl.addSpringDamper3D(springName, l0, K, Z, masName1, masName2);
        mdl.addLinkToSubset(springName,subSetName+"_1axe");
        mdl.addLinkToSubset(springName,subSetName);
      }
    }
  }

  for (int k = 0; k < dimZ; k++) {
    for (int i = 1; i < dimX+1; i++) {
      for (int j = 0; j < dimY-1; j++) {
        masName1 = mName +(i+j*dimX+k*(dimX*dimY));
        masName2 = mName +(i+(j+1)*dimX+k*(dimX*dimY));
        springName = lName + "1_" +i+j+k;
        mdl.addSpringDamper3D(springName, l0, K, Z, masName1, masName2);
        mdl.addLinkToSubset(springName,subSetName+"_1axe");
        mdl.addLinkToSubset(springName,subSetName);
      }
    }
  }

  for (int i = 1; i < dimX+1; i++) {
    for (int j = 0; j < dimY; j++) {
      for (int k = 0; k < dimZ-1; k++) {
        masName1 = mName +(i+j*dimX+k*(dimX*dimY));
        masName2 = mName +(i+j*dimX+(k+1)*(dimX*dimY));
        springName = lName + "1_" +i+j+k;
        mdl.addSpringDamper3D(springName, l0, K, Z, masName1, masName2);
        mdl.addLinkToSubset(springName,subSetName+"_1axe");
        mdl.addLinkToSubset(springName,subSetName);
      }
    }
  }

  // Create cross links (for structural integrity) here!
  double h1 = sqrt(2)*l0;
  double h2 = sqrt(3)*l0;

  for (int i = 1; i < dimX; i++) {
    for (int j = 0; j < dimY-1; j++) {
      for (int k = 0; k < dimZ; k++) {
        masName1 = mName +(i+j*dimX+k*(dimX*dimY));
        masName2 = mName +(i+1+(j+1)*dimX+k*(dimX*dimY));  
        springName = lName + "1_" +i+j+k;
        mdl.addSpringDamper3D(springName, h1, K, Z, masName1, masName2);
        mdl.addLinkToSubset(springName,subSetName+"_2axes");

        masName1 = mName +(i+(j+1)*dimX+k*(dimX*dimY));
        masName2 = mName +(i+1+(j)*dimX+k*(dimX*dimY));   
        mdl.addSpringDamper3D(springName, h1, K, Z, masName1, masName2);
        mdl.addLinkToSubset(springName,subSetName+"_2axes");
        mdl.addLinkToSubset(springName,subSetName);
      }
    }
  }
  for (int i = 1; i < dimX; i++) {
    for (int j = 0; j < dimY; j++) {
      for (int k = 0; k < dimZ-1; k++) {
        masName1 = mName +(i+j*dimX+k*(dimX*dimY));
        masName2 = mName +(i+1+(j)*dimX+(k+1)*(dimX*dimY));
        springName = lName + "1_" +i+j+k;
        mdl.addSpringDamper3D(springName, h1, K, Z, masName1, masName2);
        mdl.addLinkToSubset(springName,subSetName+"_2axes");
        mdl.addLinkToSubset(springName,subSetName);

        masName1 = mName +(i+(j)*dimX+(k+1)*(dimX*dimY));
        masName2 = mName +(i+1+(j)*dimX+k*(dimX*dimY));   
        mdl.addSpringDamper3D(springName, h1, K, Z, masName1, masName2);
        mdl.addLinkToSubset(springName,subSetName+"_2axes");
        mdl.addLinkToSubset(springName,subSetName);
      }
    }
  }
    for (int i = 1; i < dimX+1; i++) {
    for (int j = 0; j < dimY-1; j++) {
      for (int k = 0; k < dimZ-1; k++) {
        masName1 = mName +(i+j*dimX+k*(dimX*dimY));
        masName2 = mName +(i+(j+1)*dimX+(k+1)*((dimX)*(dimY)));
        springName = lName + "1_" +i+j+k;
        mdl.addSpringDamper3D(springName, h1, K, Z, masName1, masName2);
        mdl.addLinkToSubset(springName,subSetName+"_2axes");
        mdl.addLinkToSubset(springName,subSetName);
        
        masName1 = mName +(i+j*dimX+(k+1)*(dimX*dimY));
        masName2 = mName +(i+(j+1)*dimX+(k)*((dimX)*(dimY)));   
        mdl.addSpringDamper3D(springName, h1, K, Z, masName1, masName2);
        mdl.addLinkToSubset(springName,subSetName+"_2axes");
        mdl.addLinkToSubset(springName,subSetName);
      }
    }
  }
  for (int i = 1; i < dimX; i++) {
    for (int j = 0; j < dimY-1; j++) {
      for (int k = 0; k < dimZ-1; k++) {
        masName1 = mName +(i+j*dimX+k*(dimX*dimY));
        masName2 = mName +(i+1+(j+1)*dimX+(k+1)*((dimX)*(dimY)));   
        springName = lName + "1_" +i+j+k;        
        mdl.addSpringDamper3D(springName, h2, K, Z, masName1, masName2);
        mdl.addLinkToSubset(springName,subSetName+"_3axes");
        mdl.addLinkToSubset(springName,subSetName);
        
        masName1 = mName +(i+(j+1)*dimX+(k+1)*(dimX*dimY));
        masName2 = mName +(i+1+(j)*dimX+(k)*((dimX)*(dimY)));   
        mdl.addSpringDamper3D(springName, h2, K, Z, masName1, masName2);
        mdl.addLinkToSubset(springName,subSetName+"_3axes");
        mdl.addLinkToSubset(springName,subSetName);
        
        masName1 = mName +(i+1+(j+1)*dimX+(k)*(dimX*dimY));
        masName2 = mName +(i+(j)*dimX+(k+1)*((dimX)*(dimY)));   
        mdl.addSpringDamper3D(springName, h2, K, Z, masName1, masName2);
        mdl.addLinkToSubset(springName,subSetName+"_3axes");
        mdl.addLinkToSubset(springName,subSetName);
        
        masName1 = mName +(i+1+(j)*dimX+(k+1)*(dimX*dimY));
        masName2 = mName +(i+(j+1)*dimX+(k)*((dimX)*(dimY)));   
        mdl.addSpringDamper3D(springName, h2, K, Z, masName1, masName2);
        mdl.addLinkToSubset(springName,subSetName+"_3axes");
        mdl.addLinkToSubset(springName,subSetName);
      }
    }
  }
}
