package miPhysics.Engine;

import java.util.ArrayList;

/**
 * The global collision engine for the physics context. It can handle both collisions between
 * two sub-models (physical models) and auto-collision of the masses inside a physical model.
 */
public class CollisionEngine {

    ArrayList<MassCollider> m_colliders = new ArrayList<>();
    ArrayList<AutoCollider> m_autoColliders = new ArrayList<>();

    public CollisionEngine(){

    }

    /**
     * Register a collision between two sub-models.
     * @param m1 the first physical model.
     * @param m2 the second physical model.
     * @param stiffness stiffness of the collisions.
     * @param damping damping of the collisions.
     */
    public void addCollision(PhyModel m1, PhyModel m2, double stiffness, double damping){

        recursiveColliders(m1, m2, stiffness, damping,  m_colliders);

        //MassCollider mc = new MassCollider(m1, m2);
        //mc.setStiffness(stiffness);
        //m_colliders.add(mc);
    }


    /**
     * Register auto-collision between the masses of a physical model.
     * @param mdl the physical model.
     * @param size size of the auto-collision voxels.
     * @param dim gid size (number of voxels).
     * @param stiffness stiffness of collisions.
     * @param damping damping of collisions.
     */
    public void addAutoCollision(PhyModel mdl, double size, int dim, double stiffness, double damping){
        m_autoColliders.add(new AutoCollider(mdl, size, dim, dim, dim, stiffness, damping));
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

    /**
     * Compute all collusions and auto-collisions.
     */
    public void runCollisions(){
        for(MassCollider mc : m_colliders){
            mc.detectCollisions();
            mc.computeCollisions();
        }
        for(AutoCollider ac : m_autoColliders){
            ac.generateSpaceTags();
            ac.computeCollisions();
        }
    }

    public ArrayList<MassCollider> getMassColliders(){
        return m_colliders;
    }

    public ArrayList<AutoCollider> getAutoColliders(){
        return m_autoColliders;
    }


}
