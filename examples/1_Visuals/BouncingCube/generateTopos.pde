
void generateVolume(PhysicalModel mdl, int dimX, int dimY, int dimZ, String mName, String lName, float masValue, float dist, float K, float Z) {
  // add the masses to the model: name, mass, initial pos, init speed
  String masName;
  Vect3D X0, V0;

  for (int k = 0; k < dimZ; k++) {
    for (int i = 0; i < dimY; i++) {
      for (int j = 1; j <= dimX; j++) {
        masName = mName +(j+i*dimX+k*dimX*dimY);
        println(masName);
        masValue = 1.0;
        X0 = new Vect3D(j*dist, i*dist, k*dist);
        V0 = new Vect3D(0., 0., 0.);
        mdl.addMass3D(masName, masValue, X0, V0);
      }
    }
  }

  // add the spring to the model: length, stiffness, connected mats
  String masName1, masName2;

  for (int k = 0; k < dimZ; k++) {
    for (int i = 0; i < dimY; i++) {
      for (int j = 1; j < dimX; j++) {
        masName1 = mName +(j+i*dimX+k*(dimX*dimY));
        masName2 = mName +(j+i*dimX+k*(dimX*dimY)+1);
        //println("X " +masName1+masName2);

        mdl.addSpringDamper3D(lName + "1_" +i+j+k, dist, K, Z, masName1, masName2);
      }
    }
  }

  for (int k = 0; k < dimZ; k++) {
    for (int i = 1; i < dimX+1; i++) {
      for (int j = 0; j < dimY-1; j++) {
        masName1 = mName +(i+j*dimX+k*(dimX*dimY));
        masName2 = mName +(i+(j+1)*dimX+k*(dimX*dimY));
        //println("Y "+masName1+masName2);

        mdl.addSpringDamper3D(lName + "1_" +i+j+k, dist, K, Z, masName1, masName2);
      }
    }
  }

  for (int i = 1; i < dimX+1; i++) {
    for (int j = 0; j < dimY; j++) {
      for (int k = 0; k < dimZ-1; k++) {
        masName1 = mName +(i+j*dimX+k*(dimX*dimY));
        masName2 = mName +(i+j*dimX+(k+1)*(dimX*dimY));
        //println("Z "+masName1+masName2);

        mdl.addSpringDamper3D(lName + "1_" +i+j+k, dist, K, Z, masName1, masName2);
      }
    }
  }

  // Create cross links (for structural integrity) here!
  double h1 = sqrt(2)*dist;
  double h2 = sqrt(3)*dist;
  
  for (int i = 1; i < dimX; i++) {
    for (int j = 0; j < dimY-1; j++) {
      for (int k = 0; k < dimZ; k++) {
        masName1 = mName +(i+j*dimX+k*(dimX*dimY));
        masName2 = mName +(i+1+(j+1)*dimX+k*(dimX*dimY));   
        mdl.addSpringDamper3D(lName + "1_" +i+j+k, h1, K, Z, masName1, masName2);

        masName1 = mName +(i+(j+1)*dimX+k*(dimX*dimY));
        masName2 = mName +(i+1+(j)*dimX+k*(dimX*dimY));   
        mdl.addSpringDamper3D(lName + "1_" +i+j+k, h1, K, Z, masName1, masName2);
      }
    }
  }
  for (int i = 1; i < dimX; i++) {
    for (int j = 0; j < dimY; j++) {
      for (int k = 0; k < dimZ-1; k++) {
        masName1 = mName +(i+j*dimX+k*(dimX*dimY));
        masName2 = mName +(i+1+(j)*dimX+(k+1)*(dimX*dimY));   
        mdl.addSpringDamper3D(lName + "1_" +i+j+k, h1, K, Z, masName1, masName2);

        masName1 = mName +(i+(j)*dimX+(k+1)*(dimX*dimY));
        masName2 = mName +(i+1+(j)*dimX+k*(dimX*dimY));   
        mdl.addSpringDamper3D(lName + "1_" +i+j+k, h1, K, Z, masName1, masName2);
      }
    }
  }
    for (int i = 1; i < dimX+1; i++) {
    for (int j = 0; j < dimY-1; j++) {
      for (int k = 0; k < dimZ-1; k++) {
        masName1 = mName +(i+j*dimX+k*(dimX*dimY));
        masName2 = mName +(i+(j+1)*dimX+(k+1)*((dimX)*(dimY)));   
        mdl.addSpringDamper3D(lName + "1_" +i+j+k, h1, K, Z, masName1, masName2);
        
        masName1 = mName +(i+j*dimX+(k+1)*(dimX*dimY));
        masName2 = mName +(i+(j+1)*dimX+(k)*((dimX)*(dimY)));   
        mdl.addSpringDamper3D(lName + "1_" +i+j+k, h1, K, Z, masName1, masName2);
      }
    }
  }
  for (int i = 1; i < dimX; i++) {
    for (int j = 0; j < dimY-1; j++) {
      for (int k = 0; k < dimZ-1; k++) {
        masName1 = mName +(i+j*dimX+k*(dimX*dimY));
        masName2 = mName +(i+1+(j+1)*dimX+(k+1)*((dimX)*(dimY)));   
        mdl.addSpringDamper3D(lName + "1_" +i+j+k, h2, K, Z, masName1, masName2);
        
        masName1 = mName +(i+(j+1)*dimX+(k+1)*(dimX*dimY));
        masName2 = mName +(i+1+(j)*dimX+(k)*((dimX)*(dimY)));   
        mdl.addSpringDamper3D(lName + "1_" +i+j+k, h2, K, Z, masName1, masName2);
        
        masName1 = mName +(i+1+(j+1)*dimX+(k)*(dimX*dimY));
        masName2 = mName +(i+(j)*dimX+(k+1)*((dimX)*(dimY)));   
        mdl.addSpringDamper3D(lName + "1_" +i+j+k, h2, K, Z, masName1, masName2);
        
        masName1 = mName +(i+1+(j)*dimX+(k+1)*(dimX*dimY));
        masName2 = mName +(i+(j+1)*dimX+(k)*((dimX)*(dimY)));   
        mdl.addSpringDamper3D(lName + "1_" +i+j+k, h2, K, Z, masName1, masName2);
      }
    }
  }
}
