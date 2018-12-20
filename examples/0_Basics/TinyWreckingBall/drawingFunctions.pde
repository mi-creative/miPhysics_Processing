
/* Draw a sphere */
void drawSphere(Vect3D pos, int size) {
  pushMatrix();
  translate((float)pos.x, (float)pos.y, (float)pos.z);
  sphere(size);
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