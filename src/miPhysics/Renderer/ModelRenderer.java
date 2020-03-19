package miPhysics.Renderer;

import java.util.ArrayList;
import java.util.HashMap;

import miPhysics.Engine.Interaction;
import miPhysics.Engine.Mass;
import miPhysics.Engine.PhysicalModel;
import miPhysics.Engine.Vect3D;
import miPhysics.Engine.interType;
import miPhysics.Engine.massType;
import miPhysics.Engine.param;
import processing.core.PVector;

import processing.core.*;
import processing.core.PApplet;


public class ModelRenderer implements PConstants{

    protected PApplet app;

    HashMap <massType, MatRenderProps> matStyles;
    HashMap <interType, LinkRenderProps> linkStyles;

    MatRenderProps fallbackMat = new MatRenderProps(125, 125, 125, 5);
    LinkRenderProps fallbackLink = new LinkRenderProps(125, 125, 125, 0);

    float m_scale;

    PVector m_zoomRatio;

    boolean m_matDisplay;

    public ModelRenderer(PApplet parent){

        this.app = parent;

        m_scale = 1;
        m_matDisplay = true;

        matStyles = new HashMap <massType, MatRenderProps> ();
        linkStyles = new HashMap <interType, LinkRenderProps> ();

        m_zoomRatio = new PVector(1,1,1);

        // Default renderer settings for modules
        matStyles.put(massType.MASS3D, new MatRenderProps(180, 100, 0, 10));
        matStyles.put(massType.GROUND3D, new MatRenderProps(0, 220, 130, 10));
        matStyles.put(massType.MASS2DPLANE, new MatRenderProps(0, 220, 130, 10));
        matStyles.put(massType.MASS1D, new MatRenderProps(100, 200, 150, 10));
        matStyles.put(massType.OSC3D, new MatRenderProps(0, 220, 130, 10));
        matStyles.put(massType.OSC1D, new MatRenderProps(100, 200, 140, 10));
        matStyles.put(massType.HAPTICINPUT3D, new MatRenderProps(255, 50, 50, 10));
        matStyles.put(massType.POSINPUT3D, new MatRenderProps(255, 20, 60, 10));


        linkStyles.put(interType.DAMPER3D, new LinkRenderProps(30, 100, 100, 255));
        linkStyles.put(interType.SPRING3D, new LinkRenderProps(30, 100, 100, 255));
        linkStyles.put(interType.SPRINGDAMPER3D, new LinkRenderProps(30, 250, 250, 255));
        linkStyles.put(interType.SPRINGDAMPER1D, new LinkRenderProps(50, 255, 250, 255));
        linkStyles.put(interType.CONTACT3D, new LinkRenderProps(255, 100, 100, 0));
        linkStyles.put(interType.BUBBLE3D, new LinkRenderProps(30, 100, 100, 0));
        linkStyles.put(interType.ROPE3D, new LinkRenderProps(0, 255, 100, 255));

    };

    public boolean setColor(massType m, int r, int g, int b){
        if(matStyles.containsKey(m)) {
            matStyles.get(m).setColor(r, g, b);
            return true;
        }
        else return false;
    }

    public boolean setSize(massType m, float size){
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


    public boolean setSize(interType m, int size){
        if(linkStyles.containsKey(m)) {
            linkStyles.get(m).setSize(size);
            return true;
        }
        else return false;
    }

    public boolean setColor(interType m, int r, int g, int b, int alpha){
        if(linkStyles.containsKey(m)) {
            linkStyles.get(m).setColor(r, g, b, alpha);
            return true;
        }
        else return false;
    }


    public boolean setStrainGradient(interType m, boolean cond, float val){
        if(linkStyles.containsKey(m)) {
            linkStyles.get(m).setStrainGradient(cond, val);
            return true;
        }
        else return false;
    }

    public boolean setStrainColor(interType m, int r, int g, int b, int alpha){
        if(linkStyles.containsKey(m)) {
            linkStyles.get(m).setStrainColor(r, g, b, alpha);
            return true;
        }
        else return false;
    }


    /*public boolean setScaling(massType m, float scale){
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
    }*/

    public void displayMasses(boolean val){
        m_matDisplay = val;
    }



    public void renderModel(PhysicalModel mdl) {
        PVector v;
        MatRenderProps tmp;
        LinkRenderProps tmp2;

        ArrayList<MatDataHolder> matHolders = new ArrayList<MatDataHolder>();
        ArrayList<LinkDataHolder> linkHolders = new ArrayList<LinkDataHolder>();

        int nbMats;
        int nbLinks;

        MatDataHolder mH;
        LinkDataHolder lH;



        // Limit the synchronized section to a copy of the model state
        synchronized (mdl.getLock()) {

            nbMats = mdl.getNumberOfMasses();
            nbLinks = mdl.getNumberOfInteractions();

            double dist;

            if(m_matDisplay) {

                for(Mass mat : mdl.getMassList()){
                    matHolders.add(new MatDataHolder(
                            mat.getPos(),
                            1,
                            mat.getParam(param.RADIUS),
                            mat.getType()));
                }

                /*
                for (int i = 0; i < mdl.getNumberOfMats(); i++)
                    //matHolders.add(new MatDataHolder(mdl.getMat(i)));
                    matHolders.add(new MatDataHolder(mdl.getMatPosAt(i),
                            mdl.getMatMassAt(i),
                            mdl.getMatSizeAt(i),
                            mdl.getMatTypeAt(i)));*/
            }

            for(Interaction inter : mdl.getInteractionList()){
                if(inter.getType() == interType.SPRINGDAMPER1D)
                    dist = inter.calcDist1D();
                else if(inter.getType() == interType.CONTACT3D)
                    dist = 0;
                else if(inter.getType() == interType.PLANECONTACT3D)
                    dist = 0;
                else
                    dist = inter.getElongation() / inter.getParam(param.DISTANCE);
                linkHolders.add(new LinkDataHolder(
                        inter.getMat1().getPos(),
                        inter.getMat2().getPos(),
                        dist,
                        inter.getType()));
            }
            /*
            for (int i = 0; i < mdl.getNumberOfLinks(); i++)
                linkHolders.add(new LinkDataHolder(mdl.getLinkPos1At(i),
                        mdl.getLinkPos2At(i),
                        mdl.getLinkElongationAt(i) / mdl.getLinkDRestAt(i),
                        mdl.getLinkTypeAt(i)));
                        */

        }

        if(m_matDisplay){

            // Scaling the detail of the spheres depending on size of the model
            if (nbMats < 100)
                app.sphereDetail(30);
            else if (nbMats < 1000)
                app.sphereDetail(15);
            else if (nbMats < 10000)
                app.sphereDetail(5);

            // All the drawing can then run concurrently to the model calculation
            // Should really structure several lists according to module type
            for (int i = 0; i < nbMats; i++) {

                mH = matHolders.get(i);

                if (matStyles.containsKey(mH.getType()))
                    tmp = matStyles.get(mH.getType());
                else tmp = fallbackMat;

                v = mH.getPos().toPVector().mult(1);
                app.pushMatrix();
                app.translate(m_zoomRatio.x * v.x, m_zoomRatio.y * v.y, m_zoomRatio.z * v.z);
                app.fill(tmp.red(), tmp.green(), tmp.blue());
                app.noStroke();
                app.sphere(m_zoomRatio.x * (float)mH.getRadius());
                //app.sphere(tmp.getScaledSize(mH.getMass()));
                app.popMatrix();
            }
        }


        for ( int i = 0; i < nbLinks; i++) {

            lH = linkHolders.get(i);

            app.strokeWeight(1);

            if (linkStyles.containsKey(lH.getType()))
                tmp2 = linkStyles.get(lH.getType());
            else tmp2 = fallbackLink;

            if(tmp2.strainGradient()){
                if ((tmp2.getAlpha() > 0) || (tmp2.getStrainAlpha() > 0))
                {
                    float stretching = (float)lH.getElongation();

                    app.strokeWeight(tmp2.getSize());
                    app.stroke(tmp2.redStretch(stretching),
                            tmp2.greenStretch(stretching),
                            tmp2.blueStretch(stretching),
                            tmp2.alphaStretch(stretching));

                    drawLine(lH.getP1(), lH.getP2());
                }
            }

            else if (tmp2.getAlpha() > 0) {
                app.stroke(tmp2.red(), tmp2.green(), tmp2.blue(), tmp2.getAlpha());
                app.strokeWeight(tmp2.getSize());

                drawLine(lH.getP1(), lH.getP2());
            }
        }

/*            for (int i = 0; i < mdl.getNumberOfMats(); i++) {
                matHolders.add(new MatDataHolder(mdl.getMatPosAt(i),
                                                 mdl.getMatMassAt(i),
                                                 mdl.getMatTypeAt(i)));
            }

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
            }*/

          /*  synchronized(mdl.getLock()) {


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
        }*/
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