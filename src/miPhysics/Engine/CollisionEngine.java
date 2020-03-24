package miPhysics.Engine;

import java.util.ArrayList;

public class CollisionEngine {

    ArrayList<MassCollider> m_colliders = new ArrayList<>();

    public CollisionEngine(){

    }

    public void addCollision(PhyModel m1, PhyModel m2, double stiffness){
        MassCollider mc = new MassCollider(m1, m2);
        mc.setStiffness(stiffness);
        m_colliders.add(mc);
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
