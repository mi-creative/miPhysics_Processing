package miPhysics.Engine;

import javafx.util.Pair;
import miPhysics.Utility.SpacePrint;

import java.util.ArrayList;
import java.util.ConcurrentModificationException;

public class MassCollider {

    private Pair<PhyModel, PhyModel> m_colMdls;
    private SpacePrint m_intersect;

    private ArrayList<Mass> m_massList1 = new ArrayList<>();
    private ArrayList<Mass> m_massList2 = new ArrayList<>();


    private Contact3D contactLink = new Contact3D(0., 0);

    MassCollider(PhyModel m1, PhyModel m2){
        m_colMdls = new Pair<>(m1, m2);
        m_intersect = new SpacePrint();

    }

    public SpacePrint getSpacePrint(){
        return m_intersect;
    }

    private PhyModel getMdl1(){
        return m_colMdls.getKey();
    }
    private PhyModel getMdl2(){
        return m_colMdls.getValue();
    }

    public void setStiffness(double K){
        contactLink.setParam(param.STIFFNESS, K);
    }
    public void setDamping(double Z){
        contactLink.setParam(param.DAMPING, Z);
    }

    void detectCollisions(){

        // Clear possible collisions from previous step
        m_massList1.clear();
        m_massList2.clear();
        boolean fake = false;
        // Generate the new intersection box between both physical models
        m_intersect.intersection(getMdl1().getSpacePrint(), getMdl2().getSpacePrint());

        // If this box is valid (i.e. there is an intersection between the physical model bounding boxes
        if(m_intersect.isValid()){
            //System.out.println("Valid intersection : Looking for potentially colliding masses...");
            // Get all masses from model 1 that may be touching this box

            /*
            getMdl1().getMassList().parallelStream().forEach(p-> {
                if(m_intersect.intersectsWithMass(p))
                    m_massList1.add(p);

            });
            */

            for(Mass m : getMdl1().getMassList()){
                if(m_intersect.intersectsWithMass(m))
                    m_massList1.add(m);
            }

            /*
            getMdl2().getMassList().parallelStream().forEach(p-> {
                if(m_intersect.intersectsWithMass(p))
                    m_massList2.add(p);
            });
            */

            // Get all masses from model 2 that may be touching this box

            for(Mass m : getMdl2().getMassList()){
                if(m_intersect.intersectsWithMass(m))
                    m_massList2.add(m);
            }



            //System.out.println("Found " + m_massList1.size() + " and " + m_massList2.size() + " masses to test");
        }else{
            //System.out.println("No masses to run the collision engine with.");

        }

        // Need to put this up here or else the parallel stream stuff screws up??
        //this.computeCollisions();
    }

    void computeCollisions(){

        for(int i = 0; i < m_massList1.size(); i++){
            for(int j = 0; j < m_massList2.size(); j++){
                // CAREFUL ! the delayed distance could be false here !
                //System.out.println(m_massList1.get(i).getName());
                //System.out.println(m_massList2.get(j).getName());
                contactLink.connect(m_massList1.get(i), m_massList2.get(j));
                contactLink.compute();
                //System.out.println("Computing collision...");

            }
        }
    }

}
