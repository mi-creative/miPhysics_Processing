import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

Ellipsoid earth;
ArrayList<Ellipsoid> massShapes = new ArrayList<Ellipsoid>();

void drawLine(Vect3D pos1, Vect3D pos2) {
  line(100*(float)pos1.x, 100*(float)pos1.y, 100*(float)pos1.z, 100*(float)pos2.x, 100*(float)pos2.y, 100*(float)pos2.z);
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
      addColoredShape(mdl.getMatPosAt(i).toPVector(), color(120, 120, 0), 40);
      break;
    case Mass2DPlane:
      addColoredShape(mdl.getMatPosAt(i).toPVector(), color(120, 0, 120), 10);
      break;
    case Ground3D:
      addColoredShape(mdl.getMatPosAt(i).toPVector(), color(30, 100, 100), 40);
      break; 
    case HapticInput3D:
      addColoredShape(mdl.getMatPosAt(i).toPVector(), color(255, 10, 10), 80);
      break; 
    case Osc3D:
      addColoredShape(mdl.getMatPosAt(i).toPVector(), color(30, 0, 230), 40);
      break;
    case UNDEFINED:
      break;
    }
  }
}


void renderModelShapes(PhysicalModel mdl) {
  PVector v;
  synchronized(lock) { 
    for ( int i = 0; i < mdl.getNumberOfMats(); i++) {
      v = mdl.getMatPosAt(i).toPVector().mult(100.);
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
