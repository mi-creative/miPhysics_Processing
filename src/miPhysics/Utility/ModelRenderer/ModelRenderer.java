package miPhysics;

import java.util.ArrayList;
import java.util.HashMap;

import processing.core.PVector;

import processing.core.*;
import processing.core.PApplet;
import processing.core.PShape;

public class ModelRenderer implements PConstants{

    protected PApplet app;

    HashMap <matModuleType, MatRenderProps> matStyles;
    HashMap <linkModuleType, LinkRenderProps> linkStyles;

    MatRenderProps fallbackMat = new MatRenderProps(125, 125, 125, 5);
    LinkRenderProps fallbackLink = new LinkRenderProps(125, 125, 125, 0);

    float m_scale;

    PVector m_zoomRatio;

    boolean m_matDisplay;

    public ModelRenderer(PApplet parent){

        this.app = parent;

        m_scale = 1;
        m_matDisplay = true;

        matStyles = new HashMap <matModuleType, MatRenderProps> ();
        linkStyles = new HashMap <linkModuleType, LinkRenderProps> ();

        m_zoomRatio = new PVector(1,1,1);

        // Default renderer settings for modules
        matStyles.put(matModuleType.Mass3D, new MatRenderProps(180, 100, 0, 10));
        matStyles.put(matModuleType.Ground3D, new MatRenderProps(0, 220, 130, 10));
        matStyles.put(matModuleType.Mass2DPlane, new MatRenderProps(0, 220, 130, 10));
        matStyles.put(matModuleType.Osc3D, new MatRenderProps(0, 220, 130, 10));
        matStyles.put(matModuleType.HapticInput3D, new MatRenderProps(255, 50, 50, 10));

        linkStyles.put(linkModuleType.Damper3D, new LinkRenderProps(30, 100, 100, 255));
        linkStyles.put(linkModuleType.Spring3D, new LinkRenderProps(30, 100, 100, 255));
        linkStyles.put(linkModuleType.SpringDamper3D, new LinkRenderProps(30, 250, 250, 255));
        linkStyles.put(linkModuleType.SpringDamper1D, new LinkRenderProps(50, 255, 250, 255));
        linkStyles.put(linkModuleType.Contact3D, new LinkRenderProps(255, 100, 100, 0));
        linkStyles.put(linkModuleType.Bubble3D, new LinkRenderProps(30, 100, 100, 0));
        linkStyles.put(linkModuleType.Rope3D, new LinkRenderProps(0, 255, 100, 255));

    };

    public boolean setColor(matModuleType m, int r, int g, int b){
            if(matStyles.containsKey(m)) {
                matStyles.get(m).setColor(r, g, b);
                return true;
            }
            else return false;
    }

    public boolean setSize(matModuleType m, float size){
        if(matStyles.containsKey(m)) {
            matStyles.get(m).setBaseSize(size);
            return true;
        }
        else return false;
    }

    public void setZoomVector(float x, float y, float z){
        m_zoomRatio.x = x;
        m_zoomRatio.y = y;
        m_zoomRatio.z = z;
    }


    public boolean setSize(linkModuleType m, int size){
        if(linkStyles.containsKey(m)) {
            linkStyles.get(m).setSize(size);
            return true;
        }
        else return false;
    }

    public boolean setColor(linkModuleType m, int r, int g, int b, int alpha){
        if(linkStyles.containsKey(m)) {
            linkStyles.get(m).setColor(r, g, b, alpha);
            return true;
        }
        else return false;
    }


    public boolean setStrainGradient(linkModuleType m, boolean cond, float val){
        if(linkStyles.containsKey(m)) {
            linkStyles.get(m).setStrainGradient(cond, val);
            return true;
        }
        else return false;
    }

    public boolean setStrainColor(linkModuleType m, int r, int g, int b, int alpha){
        if(linkStyles.containsKey(m)) {
            linkStyles.get(m).setStrainColor(r, g, b, alpha);
            return true;
        }
        else return false;
    }


    public boolean setScaling(matModuleType m, float scale){
        if(matStyles.containsKey(m)) {
            matStyles.get(m).setInertiaScaling(scale);
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



    public void renderModel(PhysicalModel mdl) {
        PVector v;
        MatRenderProps tmp;
        LinkRenderProps tmp2;

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
                    if (matStyles.containsKey(mdl.getMatTypeAt(i)))
                        tmp = matStyles.get(mdl.getMatTypeAt(i));
                    else tmp = fallbackMat;

                    v = mdl.getMatPosAt(i).toPVector().mult(1);
                    app.pushMatrix();
                    app.translate(m_zoomRatio.x * v.x, m_zoomRatio.y * v.y, m_zoomRatio.z * v.z);
                    app.fill(tmp.red(), tmp.green(), tmp.blue());
                    app.noStroke();
                    app.sphere(tmp.getScaledSize(mdl.getMatMassAt(i)));
                    app.popMatrix();
                }
            }


            for ( int i = 0; i < mdl.getNumberOfLinks(); i++) {
                app.strokeWeight(1);

                if (linkStyles.containsKey(mdl.getLinkTypeAt(i)))
                    tmp2 = linkStyles.get(mdl.getLinkTypeAt(i));
                else tmp2 = fallbackLink;

                if(tmp2.strainGradient() == true){
                    if ((tmp2.getAlpha() > 0) || (tmp2.getStrainAlpha() > 0))
                    {
                        float stretching = (float)(mdl.getLinkElongationAt(i) / mdl.getLinkDRestAt(i));

                        app.strokeWeight(tmp2.getSize());
                        app.stroke(tmp2.redStretch(stretching),
                                   tmp2.greenStretch(stretching),
                                   tmp2.blueStretch(stretching),
                                   tmp2.alphaStretch(stretching));

                        drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
                    }

                }

                else if (tmp2.getAlpha() > 0) {
                    app.stroke(tmp2.red(), tmp2.green(), tmp2.blue(), tmp2.getAlpha());
                    app.strokeWeight(tmp2.getSize());

                    drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));

                }
            }
        }
    }


    private void drawLine(Vect3D pos1, Vect3D pos2) {
        app.line(m_zoomRatio.x * (float)pos1.x,
                 m_zoomRatio.y * (float)pos1.y,
                 m_zoomRatio.z * (float)pos1.z,
                 m_zoomRatio.x * (float)pos2.x,
                 m_zoomRatio.y * (float)pos2.y,
                 m_zoomRatio.z * (float)pos2.z);
    }
}