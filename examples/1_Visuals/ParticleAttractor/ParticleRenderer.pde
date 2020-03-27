
void drawPoint(PVector pos, double size){
  pushMatrix();
  strokeWeight(2* (int)size);
  translate(pos.x, pos.y, pos.z);
  point(0,0,0);
  strokeWeight(1);
  popMatrix();
}


class LineDrawer{
  PVector[] m_positions;
  color m_c;
  int m_idx;
  int hist = 50;

  LineDrawer(color c, int h){
    m_c = c;
    hist = h;
    
    m_positions = new PVector[hist];
    
    for(int i = 0; i < hist; i++){
      m_positions[i] = new PVector();
    }
  }
  
  void addPoint(Vect3D pos){
    m_idx = (m_idx +(hist-1)) % hist;
    m_positions[m_idx].x = (float)pos.x; 
    m_positions[m_idx].y = (float)pos.y; 
    m_positions[m_idx].z = (float)pos.z; 
  }
  
  void drawLines(){
    PVector p1, p2;
    for(int i = 0; i < hist-1; i++){
      p1 = m_positions[(m_idx + i) % hist];
      p2 = m_positions[(m_idx + i+1) % hist];
      strokeWeight(2);
      stroke(red(m_c), green(m_c), blue(m_c), 255- (255/hist) * i);
      line(p2.x, p2.y, p2.z, p1.x, p1.y, p1.z);
    }
  }
  

};

void customRenderer(PhyModel mdl){

   stroke(255, 255, 0);
  PVector pos; 

  for( int i = 0; i < mdl.getNumberOfMasses(); i++){
    Mass m = mdl.getMassList().get(i);
    switch (m.getType()){
      case OSC3D:
        pos = m.getPos().toPVector();
        // Explicit casting needed here to get the Osc3D specific methods
        Osc3D tmp = ((Osc3D)m);        
        double gradient = tmp.getElongation();    
        stroke(255,255,0,40*(int)gradient);
        drawPoint(pos, m.getParam(param.RADIUS));
        break;
      case MASS3D:
        pos = m.getPos().toPVector();
        stroke(255,50+(int)(m.getVel().magnitude()* 200.));
        drawPoint(pos, m.getParam(param.RADIUS));
        break;
        
      default:
        break;
    }
  }
}
