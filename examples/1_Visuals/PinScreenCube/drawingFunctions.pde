
void drawPoint(PVector pos, int size){
  pushMatrix();
  strokeWeight(size);
  translate(pos.x, pos.y, pos.z);
  point(0,0,0);
  strokeWeight(1);
  popMatrix();
}



void renderModelPnScrn3D(PhysicalModel mdl, int matSize){

   stroke(255, 255, 0);

  for( int i = 0; i < mdl.getNumberOfMasses(); i++){
    Mass m = mdl.getMassList().get(i);
    switch (m.getType()){
      case OSC3D:
        PVector pos = m.getPos().toPVector();
        stroke(255,255,255,100);
        point(pos.x, pos.y, pos.z);
        
        // Explicit casting needed here to get the Osc3D specific methods
        Osc3D tmp = ((Osc3D)m);        
        double gradient = tmp.getElongation();
        
        stroke(255,255,0,40*(int)gradient);
        drawPoint(pos, 2*matSize);
        break;
        
      default:
        break;
    }
  }
}
