
/* Draw a sphere */
void drawSphere(Vect3D pos, int size) {
  pushMatrix();
  translate((float)pos.x, (float)pos.y, (float)pos.z);
  sphere(size);
  popMatrix();
}

void drawPoint(Vect3D pos, int size){
  pushMatrix();
  strokeWeight(size);
  translate((float)pos.x, (float)pos.y, (float)pos.z);
  point(0,0,0);
  strokeWeight(1);
  popMatrix();
}

void drawLine(Vect3D pos1, Vect3D pos2){
line((float)pos1.x, (float)pos1.y, (float)pos1.z, (float)pos2.x, (float)pos2.y, (float)pos2.z);
}


void renderModel(PhysicalModel mdl, int matSize){

  for( int i = 0; i < mdl.getNumberOfMats(); i++){
    switch (mdl.getMatTypeAt(i)){
      case Mass3D:
        fill(0,150,200);
        //drawSphere(mdl.getMatPosAt(i), matSize);
        break;
      case Ground3D:
        fill(0,255,0);
        drawSphere(mdl.getMatPosAt(i), matSize);
        break; 
      case Mass3DSimple:
        fill(180,150,200);
        drawSphere(mdl.getMatPosAt(i), matSize);
        break;
      case Osc3D:
        fill(180,0,180);
        drawSphere(mdl.getMatPosAt(i), matSize);
        break;
      case UNDEFINED:
        break;
    }
  }
  
   strokeWeight(2);
  for( int i = 0; i < mdl.getNumberOfLinks(); i++){
    switch (mdl.getLinkTypeAt(i)){
      case Spring3D:
        stroke(0, 255, 0);
        drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
        break;
      case Damper3D:
        stroke(125, 125, 125);
        drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
        break; 
      case SpringDamper3D:
        stroke(0, 0, 255);
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