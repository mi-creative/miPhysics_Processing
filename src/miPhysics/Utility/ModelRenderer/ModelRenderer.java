package miPhysics;

import java.util.ArrayList;
import java.util.HashMap;

import processing.core.PVector;

import processing.core.*;
import processing.core.PApplet;
import processing.core.PShape;

public class ModelRenderer implements PConstants{

    protected PApplet app;

    HashMap <matModuleType, MatRenderProps> matShapes;
    MatRenderProps fallback = new MatRenderProps(125, 125, 125, 5);

    float m_scale;

    boolean m_matDisplay;

    public ModelRenderer(PApplet parent){

        this.app = parent;

        m_scale = 1;
        m_matDisplay = true;

        matShapes = new HashMap <matModuleType, MatRenderProps> ();

        // Default renderer settings for modules
        matShapes.put(matModuleType.Mass3D, new MatRenderProps(180, 100, 0, 10));
        matShapes.put(matModuleType.Ground3D, new MatRenderProps(0, 220, 130, 10));
        matShapes.put(matModuleType.Mass2DPlane, new MatRenderProps(0, 220, 130, 10));
        matShapes.put(matModuleType.Osc3D, new MatRenderProps(0, 220, 130, 10));
        matShapes.put(matModuleType.HapticInput3D, new MatRenderProps(255, 50, 50, 10));

    };

    public boolean setColor(matModuleType m, int r, int g, int b){
        MatRenderProps tmp;
            if(matShapes.containsKey(m)) {
                matShapes.get(m).setColor(r, g, b);
                return true;
            }
            else return false;
    }

    public boolean setSize(matModuleType m, float size){
        MatRenderProps tmp;
        if(matShapes.containsKey(m)) {
            matShapes.get(m).setBaseSize(size);
            return true;
        }
        else return false;
    }

    public boolean setScaling(matModuleType m, float scale){
        MatRenderProps tmp;
        if(matShapes.containsKey(m)) {
            matShapes.get(m).setInertiaScaling(scale);
            return true;
        }
        else return false;
    }


    public void setScale(float scale){
        m_scale = scale;
    }

    public float getScale(){
        return(m_scale);
    }

    public void displayMats(boolean val){
        m_matDisplay = val;
    }



    public void renderModelShapes(PhysicalModel mdl) {
        PVector v;
        MatRenderProps tmp;

        synchronized(mdl.getLock()) {

            if(m_matDisplay) {

                int nbMats = mdl.getNumberOfMats();

                // Scaling the detail of the spheres depending on size of the model
                if (nbMats < 100)
                    app.sphereDetail(30);
                else if (nbMats < 1000)
                    app.sphereDetail(15);
                else if (nbMats < 10000)
                    app.sphereDetail(5);

                for (int i = 0; i < nbMats; i++) {
                    if (matShapes.containsKey(mdl.getMatTypeAt(i)))
                        tmp = matShapes.get(mdl.getMatTypeAt(i));
                    else tmp = fallback;

                    v = mdl.getMatPosAt(i).toPVector().mult(1);
                    app.pushMatrix();
                    app.translate(v.x, v.y, v.z);
                    app.fill(tmp.red(), tmp.green(), tmp.blue());
                    app.noStroke();
                    app.sphere(tmp.getScaledSize(mdl.getMatMassAt(i)));
                    app.popMatrix();
                }
            }


            for ( int i = 0; i < mdl.getNumberOfLinks(); i++) {
                app.strokeWeight(1);
                switch (mdl.getLinkTypeAt(i)) {
                    case Spring3D:
                        app.stroke(0, 255, 0);
                        drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
                        break;
                    case Damper3D:
                        app.stroke(125, 125, 125);
                        drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
                        break;
                    case SpringDamper3D:
                        app.stroke(0, 0, 255);
                        drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
                        break;
                    case Rope3D:
                        app.stroke(210, 235, 110);
                        drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
                        break;
                    case Contact3D:
                        break;
                    case PlaneContact3D:
                        break;
                    default:
                        break;
                }
            }
        }
    }


    private void drawLine(Vect3D pos1, Vect3D pos2) {
        app.line((float)pos1.x, (float)pos1.y, (float)pos1.z, (float)pos2.x, (float)pos2.y, (float)pos2.z);
    }
}