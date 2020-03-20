package miPhysics.Engine;

import java.util.*;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class PhyModel extends Object {

    public PhyModel(String name, Medium med) {
        m_macroName = name;
        m_lock = new ReentrantLock();
        m_medium = med;
        System.out.println(m_medium);
    }

    public void init(){
        /* Initialise the stored distances for the springs */
        for(Interaction inter : m_interactions)
            inter.initDistances();
        for(PhyModel m : m_macros)
            m.init();
    }

    public void clear(){
        // Recursively clear all the sub "objects"...
        for(PhyModel m : m_macros)
            m.clear();
        // Then clear the list of objects...
        m_macros.clear();
        m_masses.clear();
        // And clear the list of interactions...
        m_interactions.clear();
    }

    // Need to check the validity of this... Are mass/interaction phases properly timed when descending recursively?
    public void compute(){

        for(Mass m : m_masses)
            m.compute();
        for(PhyModel o : m_macros)
            o.compute();
        for(Interaction i : m_interactions)
            i.compute();
        for(InOut io : m_inOuts)
            io.compute();
    }

    // Can always apply a force to all the components of a macro object
    protected void applyForce(Vect3D force){
        for(Mass m : m_masses)
            m.applyForce(force);
        for(PhyModel o: m_macros)
            o.applyForce(force);
    }

    // Will have to define types at some point.
    public massType getType(){
        return m_type;
    }
    protected void setType(massType t){
        m_type = t;
    }


    public Mass getMass(String name){
        if(m_massLabels.get(name) == null){
            System.out.println("Cannot find mass " + name + " in macro " + m_name);
            return null;
        }
        return m_massLabels.get(name);
    }

    public PhyModel getPhyModel(String name){
        if(m_macroLabels.get(name) == null){
            System.out.println("Cannot find sub-macro " + name + " in macro " + m_name);
            return null;
        }
        return m_macroLabels.get(name);
    }

    public void addPhyModel(PhyModel mac){
        if(mac == null){
            System.out.println("Cannot add sub-macro " + mac + " !!! To " + m_name);
            return;
        }
        else {
            m_macros.add(mac);
            m_macroLabels.put(mac.getName(), mac);
        }
    }



    public <T extends Mass> T addMass(String name, T m){
        return addMass(name, m, m_medium);
    }

    public <T extends Mass> T addMass(String name, T m, Medium med){
        if (m_massLabels.get(name) == null){
            try {
                m.setName(name);
                m.setMedium(med);

                // Small trickery to input velocities (either per sample or per second)
                Vect3D pInit = new Vect3D(m.getPos());
                Vect3D vInit = new Vect3D(m.getPosR());
                if (m_velUnits == velUnit.PER_SEC)
                    m.setPosR(pInit.sub(vInit.div(m_simRate)));
                else
                    m.setPosR(pInit.sub(vInit));

                m_masses.add(m);
                m_massLabels.put(name, m);

            } catch (Exception e) {
                System.out.println("Error adding mass module " + name + ": " + e);
                this.m_errorCode = -2;
                return null;
            }
        }
        else {
            System.out.println("Could not create " + m + ", " + name + " label already exists. ");
            this.m_errorCode = -1;
            return null;
        }
        this.m_errorCode = 0;
        return m;
    }



    public <T extends Interaction> T addInteraction(String name, T inter, Mass m1){
        if (inter.getType() == interType.PLANECONTACT3D){
            return addInteraction(name, inter, m1, m1);
        }
        else{
            System.out.println("Missing argument for " + name
                    + " (connects to two masses).");
            this.m_errorCode = -1;
            return null;
        }
    }


    public <T extends Interaction> T addInteraction(String name, T inter, String m_id1){
        Mass m1 = m_massLabels.get(m_id1);
        return addInteraction(name, inter, m1);
    }


    public <T extends Interaction> T addInteraction(String name, T inter, Mass m1, Mass m2) {

        if (m_intLabels.get(name) != null) {
            System.out.println("Cannot create interaction " + name
                    + ": " + name + " interaction already exists. ");
            this.m_errorCode = -1;
            return null;
        }
        if (m1 == null) {
            System.out.println("Cannot create interaction " + name
                    + ": " + m1.getName() + " mass doesn't exist. ");
            this.m_errorCode = -2;
            return null;
        } else if (m2 == null) {
            System.out.println("Cannot create interaction " + name
                    + ": " + m2.getName() + " mass doesn't exist. ");
            this.m_errorCode = -3;
            return null;
        }

        try {
            inter.setName(name);
            inter.connect(m1, m2);
            m_interactions.add(inter);
            m_intLabels.put(name, inter);

        } catch (Exception e) {
            System.out.println("Error adding interaction module " + name + ": " + e);
            this.m_errorCode = -4;
            return null;
        }
        this.m_errorCode = 0;
        return inter;
    }


    public <T extends Interaction> T addInteraction(String name, T inter, String m_id1, String m_id2) {
        Mass m1 = m_massLabels.get(m_id1);
        Mass m2 = m_massLabels.get(m_id2);
        return addInteraction(name, inter, m1, m2);
    }


    public <T extends InOut> T addInOut(String name, T mod, Mass m) {
        if (m_inOutLabels.get(name) != null) {
            System.out.println("Cannot create InOut " + name
                    + ": " + name + " extern already exists. ");
            this.m_errorCode = -1;
            return null;
        }
        if (m == null) {
            System.out.println("Cannot create InOut " + name
                    + ": " + m.getName() + " mass doesn't exist. ");
            this.m_errorCode = -2;
            return null;
        }
        try {
            mod.setName(name);
            mod.connect(m);
            m_inOuts.add(mod);
            m_inOutLabels.put(name, mod);
        } catch (Exception e) {
            System.out.println("Error adding InOut module " + name + ": " + e);
            this.m_errorCode = -4;
            return null;
        }
        this.m_errorCode = 0;
        return mod;
    }


    public <T extends InOut> T addInOut(String name, T mod, String m_id) {
        Mass m = m_massLabels.get(m_id);
        return addInOut(name, mod, m);
    }


    public ArrayList<PhyModel> getSubModels(){
        return m_macros;
    }

    public ArrayList<Mass> getMassList(){
        return m_masses;
    }

    public ArrayList<Interaction> getInteractionList(){
        return m_interactions;
    }

    public int numberOfMassTypes(){
        int nb = m_masses.size();
        for(PhyModel pm : m_macros)
            nb += pm.numberOfMassTypes();
        return nb;
    }

    public int numberOfInterTypes(){
        int nb = m_interactions.size();
        for(PhyModel pm : m_macros)
            nb += pm.numberOfInterTypes();
        return nb;
    }

    public int getNumberOfMasses(){
        return m_masses.size();
    }

    public int getNumberOfInteractions(){
        return m_interactions.size();
    }

    public ArrayList<Observer3D> getObservers(){
        ArrayList<Observer3D> list = new ArrayList<>();
        for(InOut element : m_inOuts){
            if(element.getType() == inOutType.OBSERVER3D) {
                Observer3D tmp = ((Observer3D)element);
                list.add(tmp);
            }
        }
        return list;
    }

    public ArrayList<Driver3D> getDrivers(){
        ArrayList<Driver3D> list = new ArrayList<>();
        for(InOut element : m_inOuts){
            if(element.getType() == inOutType.DRIVER3D) {
                Driver3D tmp = ((Driver3D)element);
                list.add(tmp);
            }
        }
        return list;
    }





    public boolean massExists(String name) {
        Mass m = m_massLabels.get(name);
        if (m == null)
            return false;
        else
            return true;
    }


    private int removeMass(Mass m){
        try {
            if(m_massLabels.remove(m.getName()) == null)
                throw(new Exception("Couldn't remove Mass module " + m + "out of label list."));
            if(m_masses.remove(m) == false)
                throw(new Exception("Couldn't remove Mass module " + m + "out of Array list."));
            return 0;
        } catch (Exception e) {
            System.out.println("Error removing Mass Module " + m + ": " + e);
            return -1;
        }
    }

    public void setSimRate(int SR){
        m_simRate = SR;
    }


    private int removeMass(String name) {
        Mass m = m_massLabels.get(name);
        return removeMass(m);
    }


    public int removeInteraction(Interaction l) {
        synchronized (m_lock) {
            try {
                if(m_intLabels.remove(l.getName()) == null)
                    throw(new Exception("Couldn't remove Interaction module " + l + "out of label list."));
                if(m_interactions.remove(l)== false)
                    throw(new Exception("Couldn't remove Interaction module " + l + "out of Array list."));
                return 0;
            } catch (Exception e) {
                System.out.println("Error removing interaction Module " + l + ": " + e);
                return -1;
            }
        }
    }

    public synchronized int removeInteraction(String name) {
        Interaction l = m_intLabels.get(name);
        return removeInteraction(l);
    }


    public int removeMassAndConnectedInteractions(Mass m) {
        synchronized (m_lock) {
            try {
                for (int i = m_interactions.size() - 1; i >= 0; i--) {
                    Interaction cur = m_interactions.get(i);
                    if ((cur.getMat1() == m) || (cur.getMat2() == m))
                        if(removeInteraction(cur) != 0)
                            throw(new Exception("Couldn't remove Interaction module " + cur ));

                }
                if (removeMass(m) != 0)
                    throw(new Exception("Couldn't remove Mass module " + m));

                return 0;

            } catch (Exception e) {
                System.out.println("Issue removing connected interactions and mass!" + e);
                System.exit(1);
            }
        }
        return -1;
    }


    public int removeMassAndConnectedInteractions(String mName) {
        Mass m = m_massLabels.get(mName);
        return removeMassAndConnectedInteractions(m);
    }


    /**
     * Quick module substitution (for boundary conditions).
     *
     * @param masName
     *            identifier of the Mass module.
     * @return
     */
    public void changeToFixedPoint(String masName) {
        Mass m = m_massLabels.get(masName);

        try {

            String name = m.getName();
            System.out.println("Changing to fixed point:  " + m.getName());
            int idx = m_masses.indexOf(m);

            Ground3D tmp = new Ground3D(m.getParam(param.RADIUS), m.getPos());
            tmp.setName(name);
            //m = tmp;
            m_masses.set(idx, tmp);
            m_massLabels.replace(name, tmp);

            Mass m1, m2;
            for(Interaction i: m_interactions){
                if(i.getMat1() == m)
                    i.connect(tmp, i.getMat2());
                if(i.getMat2() == m)
                    i.connect(i.getMat1(), tmp);
            }

        } catch (Exception e) {
            System.out.println("Couldn't change into fixed point:  " + m.getName() + ": " + e);
            System.exit(1);
        }
        return;
    }

    public void translate(float tx, float ty, float tz){
        translateAndRotate(tx, ty, tz, 0, 0, 0);
    }

    public void rotate(float x, float y, float z){
        translateAndRotate(0, 0, 0, x, y, z);
    }

    // Currently a problem with rotations along Y and Z, need to sort this...
    public void translateAndRotate(float tx, float ty, float tz, float x_angle, float y_angle, float z_angle){

        Vect3D mdlPos;

        Vect3D offset = new Vect3D();

        double cosa = Math.cos(x_angle);
        double sina = Math.sin(x_angle);

        double cosb = Math.cos(y_angle);
        double sinb = Math.sin(y_angle);

        double cosc = Math.cos(z_angle);
        double sinc = Math.sin(z_angle);

        double Axx = cosa*cosb;
        double Axy = cosa*sinb*sinc - sina*cosc;
        double Axz = cosa*sinb*cosc + sina*sinc;

        double Ayx = sina*cosb;
        double Ayy = sina*sinb*sinc + cosa*cosc;
        double Ayz = sina*sinb*cosc - cosa*sinc;

        double Azx = -sinb;
        double Azy = cosb*sinc;
        double Azz = cosb*cosc;

        offset.x = 0; // 0.5 * ((dimX-1) * dist);
        offset.y = 0; //0.5 * ((dimY-1) * dist);
        offset.z = 0; //0.5 * ((dimZ-1) * dist);

        Vect3D v = new Vect3D();


        for (int i = 0; i < this.getNumberOfMasses(); i++) {

            Mass tmp = this.getMassList().get(i);
            mdlPos = tmp.getPos();

            System.out.println("Input pos: " + mdlPos);

            mdlPos.x -= offset.x;
            mdlPos.y -= offset.y;
            mdlPos.z -= offset.z;

            v.x = Axx*mdlPos.x + Axy*mdlPos.y + Axz*mdlPos.z;
            v.y = Ayx*mdlPos.x + Ayy*mdlPos.y + Ayz*mdlPos.z;
            v.z = Azx*mdlPos.x + Azy*mdlPos.y + Azz*mdlPos.z;

            System.out.println("Position: " + v);

            v.x += offset.x + tx;
            v.y += offset.y + ty;
            v.z += offset.z + tz;

            tmp.setPos(v);
        }
        for(PhyModel pm : getSubModels())
            pm.translateAndRotate(tx,ty,tz,x_angle, y_angle, z_angle);
    }



    /* Class attributes */
    private massType m_type;

    ArrayList<PhyModel> m_macros = new ArrayList<>();
    ArrayList<Mass> m_masses = new ArrayList<>();
    ArrayList<InOut> m_inOuts = new ArrayList<>();
    ArrayList<Interaction> m_interactions = new ArrayList<>();

    HashMap<String, PhyModel> m_macroLabels = new HashMap<>();
    HashMap<String, Mass> m_massLabels = new HashMap<>();
    HashMap<String, Interaction> m_intLabels = new HashMap<>();
    HashMap<String, InOut> m_inOutLabels = new HashMap<>();

    String m_macroName;

    private velUnit m_velUnits = velUnit.PER_SEC;
    private int m_errorCode = 0;
    private int m_simRate = 1000;

    private Lock m_lock;

    public Lock getLock(){
        return m_lock;
    }

}
