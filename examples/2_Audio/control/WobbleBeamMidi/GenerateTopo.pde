
void generateVolume(PhysicalModel mdl, int dimX, int dimY, int dimZ, String mName, String lName, float masValue, float dist, float K, float Z) {
  // add the masses to the model: name, mass, initial pos, init speed
  String masName;
  Vect3D X0, V0;

  mdl.createMatSubset(mName);
  mdl.createMatSubset(mName + "_f");
  
  for (int k = 0; k < dimZ; k++) {
    for (int i = 0; i < dimY; i++) {
      for (int j = 1; j <= dimX; j++) {
        masName = mName +(j+i*dimX+k*dimX*dimY);
        println(masName);
        X0 = new Vect3D(j*dist+2, i*dist, k*dist);
        V0 = new Vect3D(0., 0., 0.);
        if((i==0)) // || (i ==dimY-1))
        {
          mdl.addGround3D(masName, X0);
          mdl.addMatToSubset(masName,mName + "_f");
        }
        else
        {
          mdl.addMass2DPlane(masName, masValue, X0, V0);
          mdl.addMatToSubset(masName,mName);
        }
      }
    }
  }


  // add the spring to the model: length, stiffness, connected mats
  String masName1, masName2;
  mdl.createLinkSubset(lName);
  for (int k = 0; k < dimZ; k++) {
    for (int i = 0; i < dimY; i++) {
      for (int j = 1; j < dimX; j++) {
        masName1 = mName +(j+i*dimX+k*(dimX*dimY));
        masName2 = mName +(j+i*dimX+k*(dimX*dimY)+1);
        mdl.addSpringDamper3D(lName + "X_" +i+"_"+j+"_"+k, dist, K, Z, masName1, masName2);
        mdl.addLinkToSubset(lName + "X_" +i+"_"+j+"_"+k,lName);
    }
    }
  }

  for (int k = 0; k < dimZ; k++) {
    for (int i = 1; i < dimX+1; i++) {
      for (int j = 0; j < dimY-1; j++) {
        masName1 = mName +(i+j*dimX+k*(dimX*dimY));
        masName2 = mName +(i+(j+1)*dimX+k*(dimX*dimY));
        mdl.addSpringDamper3D(lName + "Y_" +i+"_"+j+"_"+k, dist, K, Z, masName1, masName2);
        mdl.addLinkToSubset(lName + "Y_" +i+"_"+j+"_"+k,lName);
      }
    }
  }

  for (int i = 1; i < dimX+1; i++) {
    for (int j = 0; j < dimY; j++) {
      for (int k = 0; k < dimZ-1; k++) {
        masName1 = mName +(i+j*dimX+k*(dimX*dimY));
        masName2 = mName +(i+j*dimX+(k+1)*(dimX*dimY));
        mdl.addSpringDamper3D(lName + "Z_" +i+"_"+j+"_"+k, dist, K, Z, masName1, masName2);
        mdl.addLinkToSubset(lName + "Z_" +i+"_"+j+"_"+k,lName);
  
    }
    }
  }

  // Create cross links (for structural integrity) here!
  double h1 = sqrt(2)*dist;
  double h2 = sqrt(3)*dist;
   mdl.createLinkSubset(lName + "_cross");
  for (int i = 1; i < dimX; i++) {
    for (int j = 0; j < dimY-1; j++) {
      for (int k = 0; k < dimZ; k++) {
        masName1 = mName +(i+j*dimX+k*(dimX*dimY));
        masName2 = mName +(i+1+(j+1)*dimX+k*(dimX*dimY));   
        mdl.addSpringDamper3D(lName + "XY_" +i+"_"+j+"_"+k, h1, K, Z, masName1, masName2);
        mdl.addLinkToSubset(lName + "XY_" +i+"_"+j+"_"+k,lName+ "_cross");
   
        masName1 = mName +(i+(j+1)*dimX+k*(dimX*dimY));
        masName2 = mName +(i+1+(j)*dimX+k*(dimX*dimY));   
        mdl.addSpringDamper3D(lName + "YX_" +i+"_"+j+"_"+k, h1, K, Z, masName1, masName2);
        mdl.addLinkToSubset(lName + "YX_" +i+"_"+j+"_"+k,lName+ "_cross");
      }
    }
  }
  for (int i = 1; i < dimX; i++) {
    for (int j = 0; j < dimY; j++) {
      for (int k = 0; k < dimZ-1; k++) {
        masName1 = mName +(i+j*dimX+k*(dimX*dimY));
        masName2 = mName +(i+1+(j)*dimX+(k+1)*(dimX*dimY));   
        mdl.addSpringDamper3D(lName + "XZ_" +i+"_"+j+"_"+k, h1, K, Z, masName1, masName2);
      mdl.addLinkToSubset(lName + "XZ_" +i+"_"+j+"_"+k,lName+ "_cross");
  
        masName1 = mName +(i+(j)*dimX+(k+1)*(dimX*dimY));
        masName2 = mName +(i+1+(j)*dimX+k*(dimX*dimY));   
        mdl.addSpringDamper3D(lName + "ZX_" +i+"_"+j+"_"+k, h1, K, Z, masName1, masName2);
        mdl.addLinkToSubset(lName + "ZX_" +i+"_"+j+"_"+k,lName+ "_cross");
 
    }
    }
  }
    for (int i = 1; i < dimX+1; i++) {
    for (int j = 0; j < dimY-1; j++) {
      for (int k = 0; k < dimZ-1; k++) {
        masName1 = mName +(i+j*dimX+k*(dimX*dimY));
        masName2 = mName +(i+(j+1)*dimX+(k+1)*((dimX)*(dimY)));   
        mdl.addSpringDamper3D(lName + "XYZ_" +i+"_"+j+"_"+k, h1, K, Z, masName1, masName2);
        mdl.addLinkToSubset(lName + "XYZ_" +i+"_"+j+"_"+k,lName+ "_cross");
  
        masName1 = mName +(i+j*dimX+(k+1)*(dimX*dimY));
        masName2 = mName +(i+(j+1)*dimX+(k)*((dimX)*(dimY)));   
        mdl.addSpringDamper3D(lName + "YZX_" +i+"_"+j+"_"+k, h1, K, Z, masName1, masName2);
        mdl.addLinkToSubset(lName + "YZX_" +i+"_"+j+"_"+k,lName+ "_cross");
      }
    }
  }
  for (int i = 1; i < dimX; i++) {
    for (int j = 0; j < dimY-1; j++) {
      for (int k = 0; k < dimZ-1; k++) {
        masName1 = mName +(i+j*dimX+k*(dimX*dimY));
        masName2 = mName +(i+1+(j+1)*dimX+(k+1)*((dimX)*(dimY)));   
        mdl.addSpringDamper3D(lName + "YZ_" +i+j+k, h1, K, Z, masName1, masName2);
        mdl.addLinkToSubset(lName + "YZ_" +i+"_"+j+"_"+k,lName+ "_cross");   
        
        masName1 = mName +(i+(j+1)*dimX+(k+1)*(dimX*dimY));
        masName2 = mName +(i+1+(j)*dimX+(k)*((dimX)*(dimY)));   
        mdl.addSpringDamper3D(lName + "ZY_" +i+j+k, h1, K, Z, masName1, masName2);
        mdl.addLinkToSubset(lName + "ZY_" +i+"_"+j+"_"+k,lName+ "_cross");
           
        masName1 = mName +(i+1+(j+1)*dimX+(k)*(dimX*dimY));
        masName2 = mName +(i+(j)*dimX+(k+1)*((dimX)*(dimY)));   
        mdl.addSpringDamper3D(lName + "ZXY_" +i+j+k, h1, K, Z, masName1, masName2);
        mdl.addLinkToSubset(lName + "ZXY_" +i+"_"+j+"_"+k,lName+ "_cross");
                
        masName1 = mName +(i+1+(j)*dimX+(k+1)*(dimX*dimY));
        masName2 = mName +(i+(j+1)*dimX+(k)*((dimX)*(dimY)));   
        mdl.addSpringDamper3D(lName + "ZYX_" +i+j+k, h1, K, Z, masName1, masName2);
        mdl.addLinkToSubset(lName + "ZYX_" +i+"_"+j+"_"+k,lName+ "_cross");
      }
    }
  }
}
