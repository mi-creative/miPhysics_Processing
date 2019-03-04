import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

ArrayList<Ellipsoid> massShapes = new ArrayList<Ellipsoid>();

void drawLine(Vect3D pos1, Vect3D pos2) {
  line((float)pos1.x, (float)pos1.y, (float)pos1.z, (float)pos2.x, (float)pos2.y, (float)pos2.z);
}

void addTexturedShape(PVector pos, String texture, float size) {
  Ellipsoid tmp = new Ellipsoid(this, 20, 20);
  tmp.setTexture(texture);
  tmp.setRadius(size);
  tmp.moveTo(pos.x, pos.y, pos.z);
  tmp.strokeWeight(0);
  tmp.fill(color(32, 32, 200, 100));
  tmp.tag = "";
  tmp.drawMode(Shape3D.TEXTURE);
  massShapes.add(tmp);
}

void addColoredShape(PVector pos, color col, float size) {
  Ellipsoid tmp = new Ellipsoid(this, 20, 20);
  tmp.setRadius(size);
  tmp.moveTo(pos.x, pos.y, pos.z);
  tmp.strokeWeight(0);
  tmp.fill(col);
  tmp.tag = "";
  tmp.drawMode(Shape3D.TEXTURE);
  massShapes.add(tmp);
}

void createShapeArray(PhysicalModel mdl) {
  for ( int i = 0; i < mdl.getNumberOfMats(); i++) {
    switch (mdl.getMatTypeAt(i)) {
    case Mass3D:
      addColoredShape(mdl.getMatPosAt(i).toPVector(), color(120, 120, 0), 5);
      break;
    case Mass2DPlane:
      addColoredShape(mdl.getMatPosAt(i).toPVector(), color(120, 0, 120), 10);
      break;
    case Ground3D:
      addColoredShape(mdl.getMatPosAt(i).toPVector(), color(30, 100, 100), 5);
      break; 
    case HapticInput3D:
      addColoredShape(mdl.getMatPosAt(i).toPVector(), color(255, 10, 10), 40);
      break; 
    case Osc3D:
      addColoredShape(mdl.getMatPosAt(i).toPVector(), color(30, 0, 230), 4);
      break;
    case UNDEFINED:
      break;
    }
  }
}


void renderModelShapes(PhysicalModel mdl) {
  PVector v;
  synchronized(lock) {
    
      
  pushMatrix();
  rotateX(PI/2);
  PVector test = simUGen.mdl.getMatPVector("gnd");
  translate(test.x,test.z,test.y);
  drawHemisphere();
  popMatrix();
    
    
    for ( int i = 0; i < mdl.getNumberOfMats(); i++) {
      v = mdl.getMatPosAt(i).toPVector().mult(1.);
      massShapes.get(i).moveTo(v.x, v.y, v.z);
    }


    for ( int i = 0; i < mdl.getNumberOfLinks(); i++) {
      switch (mdl.getLinkTypeAt(i)) {
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
  for (Ellipsoid massShape : massShapes)
    massShape.draw();
}




// Drawing function below taken from: 
// https://forum.processing.org/two/discussion/13353/creating-arc-sections-in-3d

float radius = 1000.0;
float rho = radius;
float factor = TWO_PI / 50.0;
float x, y, z;
 
PVector[] sphereVertexPoints;


void drawHemisphere(){
  
  noStroke();
  fill(100, 0,0);
  
  for(float phi = 0.0; phi < HALF_PI/2; phi += factor/2) {
    beginShape(QUAD_STRIP);
    for(float theta = 0.0; theta < TWO_PI + factor; theta += factor) {
      x = rho * sin(phi) * cos(theta);
      z = rho * sin(phi) * sin(theta);
      y = -rho * cos(phi);
 
      vertex(x, y, z);
 
      x = rho * sin(phi + factor) * cos(theta);
      z = rho * sin(phi + factor) * sin(theta);
      y = -rho * cos(phi + factor);
 
      vertex(x, y, z);
    }
    endShape(CLOSE);
  }

}
