void generateMesh(PhysicalModel mdl, int dimX, int dimY, String mName, String lName, double masValue, double dist, double K_osc, double Z_osc, double K, double Z) {
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
      mdl.addOsc1D(masName, masValue, K_osc, Z_osc, X0, V0);
    }
  }


  // add the spring to the model: length, stiffness, connected mats
  String masName1, masName2;

    for (int i = 0; i < dimX; i++) {
      for (int j = 0; j < dimY-1; j++) {
        masName1 = mName + i +"_"+ j;
        masName2 = mName + i +"_"+ str(j+1);
        println("X " +masName1+masName2);
        mdl.addSpringDamper1D(lName + "1_" +i+j, 0, K, Z, masName1, masName2);
      }
    }
    
    for (int i = 0; i < dimX-1; i++) {
      for (int j = 0; j < dimY; j++) {
        masName1 = mName + i +"_"+ j;
        masName2 = mName + str(i+1) +"_"+ j;
        println("Y " +masName1+masName2);
        mdl.addSpringDamper1D(lName + "1_" +i+j, 0, K, Z, masName1, masName2);
      }
    }
}

int zZoom = 1;

void drawLine(Vect3D pos1, Vect3D pos2){
line((float)pos1.x, (float)pos1.y, zZoom *(float)pos1.z, (float)pos2.x, (float)pos2.y, zZoom * (float)pos2.z);
}


void renderLinks(PhysicalModel mdl){
   stroke(255, 255, 0);
   strokeWeight(1);
  for( int i = 0; i < (mdl.getNumberOfLinks()); i++){
    switch (mdl.getLinkTypeAt(i)){
      case Spring3D:
        stroke(0, 255, 0);
        drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
        break;
      case SpringDamper1D:
        stroke(100+10*zZoom*(float)mdl.getLinkPos1At(i).z,0, 255);
        drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
        break;
      case Damper3D:
        stroke(125, 125, 125);
        drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
        break; 
      case SpringDamper3D:
        stroke(100+10*zZoom*(float)mdl.getLinkPos1At(i).z,0, 255);
        drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
        break;
      case Rope3D:
        stroke(210, 235, 110);
        drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
        break;
      case Contact3D:
        break; 
      case PlaneContact3D:
        break;
      case UNDEFINED:
        break;
    }
  }
}