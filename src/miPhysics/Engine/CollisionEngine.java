package miPhysics.Engine;

import java.util.ArrayList;

public class CollisionEngine {

    ArrayList<MassCollider> m_colliders = new ArrayList<>();

    public CollisionEngine(){

    }

    public void addCollision(PhyModel m1, PhyModel m2, double stiffness, double damping){

        recursiveColliders(m1, m2, stiffness, damping,  m_colliders);

        //MassCollider mc = new MassCollider(m1, m2);
        //mc.setStiffness(stiffness);
        //m_colliders.add(mc);
    }

    private void recursiveColliders(PhyModel m1, PhyModel m2, double K, double Z,  ArrayList<MassCollider> colList){
        for(PhyModel pm1 : m1.getSubModels()){
            for(PhyModel pm2 : m2.getSubModels()){
                recursiveColliders(pm1, pm2, K, Z, colList);
            }
            recursiveColliders(pm1, m2, K, Z, colList);
        }
        if(!m1.equals(m2)) {
            System.out.println("Creating collision between " + m1.getName() + " and " + m2.getName());
            MassCollider mc = new MassCollider(m1, m2);
            mc.setStiffness(K);
            mc.setDamping(Z);
            colList.add(mc);
        }
    }

    public void runCollisions(){
        for(MassCollider mc : m_colliders){
            mc.detectCollisions();
            mc.computeCollisions();
        }
    }

    public ArrayList<MassCollider> getMassColliders(){
        return m_colliders;
    }




}
