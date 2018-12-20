
/* Draw a sphere */
void drawSphere(Vect3D pos, int size) {
  pushMatrix();
  translate((float)pos.x, (float)pos.y, (float)pos.z);
  sphere(size);
  popMatrix();
}

void drawEllipse(Vect3D pos, int size){
  pushMatrix();
  strokeWeight(2);
  translate((float)pos.x, (float)pos.y, (float)pos.z);
  //ellipse(0, 0, size, size);
  point(0,0,0);
  strokeWeight(1);
  popMatrix();
}


void drawLine(Vect3D pos1, Vect3D pos2){
line((float)pos1.x, (float)pos1.y, (float)pos1.z, (float)pos2.x, (float)pos2.y, (float)pos2.z);
}


void drawPlane(int orientation, float position, float size){
  stroke(255);
  fill(127);
  
  beginShape();
  if(orientation ==2){
    vertex(-size, -size, position);
    vertex( size, -size, position);
    vertex( size, size, position);
    vertex(-size, size, position);
  } else if (orientation == 1) {
    vertex(-size,position, -size);
    vertex( size,position, -size);
    vertex( size,position, size);
    vertex(-size,position, size);  
  } else if (orientation ==0) {
    vertex(position, -size, -size);
    vertex(position, size, -size);
    vertex(position, size, size);
    vertex(position,-size, size);
  }
  endShape(CLOSE);
}


void drawGrid(int gridSize, int nbBlocks) {
  strokeWeight(1);
  stroke(100, 100, 100); 
  int range = gridSize * nbBlocks;

  for (int j = -range; j <= range; j+=gridSize) {
    for (int k = -range; k <= range; k += gridSize) {
      line(-range, j, k, range, j, k);
      line(j, -range, k, j, range, k);
      line(j, k, -range, j, k, range);
    }
  }
}



void renderModel(PhysicalModel mdl, int matSize){

  for( int i = 0; i < mdl.getNumberOfMats(); i++){
    switch (mdl.getMatTypeAt(i)){
      case Mass3D:
        fill(0,150,200);
        drawSphere(mdl.getMatPosAt(i), matSize);
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
  
   strokeWeight(5);
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



void renderModelEllipse(PhysicalModel mdl, int matSize){

   stroke(255, 255, 0);

  for( int i = 0; i < mdl.getNumberOfMats(); i++){
    switch (mdl.getMatTypeAt(i)){
      case Mass3D:
        fill(0,150,200);
        //drawEllipse(mdl.getMatPosAt(i), matSize);
        break;
      case Ground3D:
        fill(0,255,0);
        //drawEllipse(mdl.getMatPosAt(i), matSize);
        break; 
      case Mass3DSimple:
        fill(180,150,200);
        //drawEllipse(mdl.getMatPosAt(i), matSize);
        break;
      case Osc3D:
        fill(180,0,180);
        //drawEllipse(mdl.getMatPosAt(i), matSize);
        break;
      case UNDEFINED:
        break;
    }
  }
  
   strokeWeight(1);
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
        stroke(100+10*(float)mdl.getLinkPos1At(i).z,0, 255);
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