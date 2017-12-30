

void generatePinScreen(PhysicalModel mdl, int dimX, int dimY, String mName, String lName, double masValue, double dist, double K_osc, double Z_osc, double K, double Z) {
  // add the masses to the model: name, mass, initial pos, init speed
  String masName;
  String solName;
  Vect3D X0, V0;

  for (int i = 0; i < dimY; i++) {
    for (int j = 0; j < dimX; j++) {
      masName = mName + j +"_"+ i;
      println(masName);
      X0 = new Vect3D((float)j*dist,(float)i*dist, 0.);
      V0 = new Vect3D(0., 0., 0.);
      mdl.addOsc3D(masName, masValue, K_osc, Z_osc, X0, V0);
    }
  }


  // add the spring to the model: length, stiffness, connected mats
  String masName1, masName2;

    for (int i = 0; i < dimX; i++) {
      for (int j = 0; j < dimY-1; j++) {
        masName1 = mName + i +"_"+ j;
        masName2 = mName + i +"_"+ str(j+1);
        println("X " +masName1+masName2);
        mdl.addSpringDamper3D(lName + "1_" +i+j, dist, K, Z, masName1, masName2);
      }
    }
    
    for (int i = 0; i < dimX-1; i++) {
      for (int j = 0; j < dimY; j++) {
        masName1 = mName + i +"_"+ j;
        masName2 = mName + str(i+1) +"_"+ j;
        println("Y " +masName1+masName2);
        mdl.addSpringDamper3D(lName + "1_" +i+j, dist, K, Z, masName1, masName2);
      }
    }
}



void generateVolume(PhysicalModel mdl, int dimX, int dimY, int dimZ, String mName, String lName, double masValue, double dist, double K, double Z) {
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
        if (masName.equals("mass1")==true) {
          V0 = new Vect3D(0., 0., 0.);
        } else {
          V0 = new Vect3D(0., 0., 0.);
        }
        println(V0);

        mdl.addMass3D(masName, masValue, X0, V0);
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

        mdl.addSpringDamper3D(lName + "1_" +i+j+k, dist, K, Z, masName1, masName2);
      }
    }
  }

  for (int k = 0; k < dimZ; k++) {
    for (int i = 1; i < dimX+1; i++) {
      for (int j = 0; j < dimY-1; j++) {
        masName1 = mName +(i+j*dimX+k*dimX*dimY);
        masName2 = mName +(i+(j+1)*dimX+k*dimX*dimY);
        //println("Y "+masName1+masName2);

        mdl.addSpringDamper3D(lName + "1_" +i+j+k, dist, K, Z, masName1, masName2);
      }
    }
  }

  for (int i = 1; i < dimX+1; i++) {
    for (int j = 0; j < dimY; j++) {
      for (int k = 0; k < dimZ-1; k++) {
        masName1 = mName +(i+j*dimX+k*dimX*dimY);
        masName2 = mName +(i+j*dimX+(k+1)*dimX*dimY);
        //println("Z "+masName1+masName2);

        mdl.addSpringDamper3D(lName + "1_" +i+j+k, dist, K, Z, masName1, masName2);
      }
    }
  }
}














void generateMembrane(PhysicalModel mdl, int dimX, int dimY, String name, String lName, double masValue, double dist, double K, double Z) {
  // add the masses to the model: name, mass, initial pos, init speed
  String masName;
  Vect3D X0, V0;


  for (int i = 0; i < dimY; i++) {
    for (int j = 1; j <= dimX; j++) {
      masName = name +(j+i*dimX);
      //println(masName);
      masValue = 1.0;
      X0 = new Vect3D(j*10, i*10, j*10.);
      V0 = new Vect3D(0., 0., 0.);

      mdl.addMass3D(masName, masValue, X0, V0);
    }
  }

  // add the spring to the model: length, stiffness, connected mats
  String masName1, masName2;

  for (int i = 0; i < dimY; i++) {
    for (int j = 2; j <= dimX; j++) {
      masName1 = name +(i*dimX+(j-1));
      masName2 = name +(i*dimX+j);
      mdl.addSpringDamper3D(lName+"1_"+i+j, dist, K, Z, masName1, masName2);
    }
  }

  for (int i = 1; i < dimX; i++) {
    for (int j = 0; j < dimY-1; j++) {
      masName1 = name +(j*dimY+i);
      masName2 = name +((j+1)*dimY+i);
      mdl.addSpringDamper3D(lName+"2_"+i+j, dist, K, Z, masName1, masName2);
    }
  }
}