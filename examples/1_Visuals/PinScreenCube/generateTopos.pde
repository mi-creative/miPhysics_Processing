void generatePinScreen3D(PhysicalModel mdl, int dimX, int dimY, int dimZ, String mName, String lName, float masValue, float dist, float K_osc, float Z_osc, float K, float Z) {
  // add the masses to the model: name, mass, initial pos, init speed
  String celName;
  Vect3D X0, V0;
  
  for (int k = 0; k < dimZ; k++) {
    for (int i = 0; i < dimY; i++) {
      for (int j = 0; j < dimX; j++) {
        celName = mName + j +"_"+ i +"_"+ k;
        //println(celName);
        masValue = 1.0;
        X0 = new Vect3D(j*dist, i*dist, k*dist);
        V0 = new Vect3D(0., 0., 0.);

        mdl.addMass(celName, new Osc3D(masValue, 1, K_osc, Z_osc, X0, V0));
        //mdl.addOsc3D(celName, masValue, 1, K_osc, Z_osc, X0, V0);
      }
    }
  }


  // add the spring to the model: length, stiffness, connected mats
   String celName1, celName2;
   for (int k = 0; k < dimZ; k++) {
     for (int i = 0; i < dimX-1; i++) {
       for (int j = 0; j < dimY; j++) {
         celName1 = mName + j +"_"+ i +"_"+ k;
         celName2 = mName + j +"_"+ str(i+1) +"_"+ k;
         //println("X " +celName1+celName2);
         
         String intName = lName +"_1_"+i+"_"+j+"_"+k;
         mdl.addInteraction(intName, new SpringDamper3D(dist, K, Z), celName1, celName2);
         //mdl.addSpringDamper3D(lName + "1_" +i+j, dist, K, Z, celName1, celName2);
       }
     }
   }
   
   for (int k = 0; k < dimZ; k++) {
     for (int i = 0; i < dimX; i++) {
       for (int j = 0; j < dimY-1; j++) {
         celName1 = mName + j +"_"+ i +"_"+ k;
         celName2 = mName + str(j+1) +"_"+ i +"_"+ k;
         //println("Y " +celName1+celName2);
         
         String intName = lName +"_2_"+i+"_"+j+"_"+k;
         mdl.addInteraction(intName, new SpringDamper3D(dist, K, Z), celName1, celName2);
         //mdl.addSpringDamper3D(lName + "1_" +i+j, dist, K, Z, celName1, celName2);
       }
     }
   }
   
   for (int k = 0; k < dimZ-1; k++) {
     for (int i = 0; i < dimX; i++) {
       for (int j = 0; j < dimY; j++) {
         celName1 = mName + j +"_"+ i +"_"+ k;
         celName2 = mName + j +"_"+ i +"_"+ str(k+1);
         //println("Y " +celName1+celName2);
         String intName = lName +"_3_"+i+"_"+j+"_"+k;
         mdl.addInteraction(intName, new SpringDamper3D(dist, K, Z), celName1, celName2);
         //mdl.addSpringDamper3D(lName + "1_" +i+j, dist, K, Z, celName1, celName2);
       }
     }
   }
  
}


/*

void generatePinScreen2D(PhysicalModel mdl, int dimX, int dimY, String mName, String lName, float masValue, float dist, float K_osc, float Z_osc, float K, float Z) {
  // add the masses to the model: name, mass, initial pos, init speed
  String celName;
  Vect3D X0, V0;

  for (int i = 0; i < dimY; i++) {
    for (int j = 0; j < dimX; j++) {
      celName = mName + j +"_"+ i;
      println(celName);
      X0 = new Vect3D(j*dist, i*dist, 0.);
      V0 = new Vect3D(0., 0., 0.);
      mdl.addOsc3D(celName, masValue, 1, K_osc, Z_osc, X0, V0);
    }
  }


  // add the spring to the model: length, stiffness, connected mats
  String celName1, celName2;

    for (int i = 0; i < dimX-1; i++) {
      for (int j = 0; j < dimY; j++) {
        celName1 = mName + j +"_"+ i;
        celName2 = mName + j +"_"+ str(i+1);
        println("X " +celName1+celName2);
        mdl.addSpringDamper3D(lName + "1_" +i+j, dist, K, Z, celName1, celName2);
      }
    }
    
    for (int i = 0; i < dimX; i++) {
      for (int j = 0; j < dimY-1; j++) {
        celName1 = mName + j +"_"+ i;
        celName2 = mName + str(j+1) +"_"+ i;
        println("Y " +celName1+celName2);
        mdl.addSpringDamper3D(lName + "1_" +i+j, dist, K, Z, celName1, celName2);
      }
    }
}



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
        if (masName.equals("mass1")==true) {
          V0 = new Vect3D(0., 0., 0.);
        } else {
          V0 = new Vect3D(0., 0., 0.);
        }
        println(V0);

        mdl.addMass3D(masName, masValue, 1, X0, V0);
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
*/
