package miPhysics.Engine;
import miPhysics.Utility.SpacePrint;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/* This can certainly be optimised! */
/* ported from some pretty early code */

//TODO : If you change the underlying physical model during simulation, it will break! Make safer

public class AutoCollider {

    PhyModel m_model;
    ArrayList<MatCol> m_colliders = new ArrayList<>();

    private double m_vSize;
    private Vect3D m_bounds;

    private int m_dimX = 1;
    private int m_dimY = 1;
    private int m_dimZ = 1;

    double m_K = 0;
    double m_Z = 0;

    private float m_radius = 10 ;

    private boolean [][] m_colTable;
    private ArrayList<Pair> m_activeCols = new ArrayList<Pair>();

    private Voxel[][][] m_boxes;
    private ArrayList<Voxel> m_actives;

    private Contact3D contactLink = new Contact3D(0., 0);


    private class Voxel {
        Voxel(int x, int y, int z) {
            idX = x;
            idY = y;
            idZ = z;
        }

        HashMap<Integer, Mass> getParticleList() {
            return this.m_particleMap;
        }

        int getNumberOfParticles() {
            return this.m_particleMap.size();
        }

        void clearParticles() {
            m_particleMap.clear();
        }

        void addParticle(Mass p, int i) {
            m_particleMap.put(i, p);
            //m_particleMap.add(new HashMap<Integer, Mass>(m_particleMap.size(), p));
        }

        int idX;
        int idY;
        int idZ;

        private HashMap<Integer, Mass> m_particleMap = new HashMap<>();
    }

    private class MatCol {

        private Mass m_mass;
        private ArrayList<Voxel> m_activeVoxels = new ArrayList<>();

        int m_idx;

        boolean m_Out = false;
        boolean m_Inter = false;

        MatCol(Mass m, int i) {
            this.m_mass = m;
            this.m_idx = i;
        }

        public int getIndex(){
            return m_idx;
        }

        public Mass getMass(){
            return m_mass;
        }

        public ArrayList<Voxel> getActiveVoxList() {
            return m_activeVoxels;
        }
        public int getNbActiveVoxels() {
            return m_activeVoxels.size();
        }


        void clearVoxels() {
            m_activeVoxels.clear();
        }

        void addVoxel(Voxel hash) {
            m_activeVoxels.add(hash);
        }
    }

    private class Pair {

        int p1;
        int p2;

        Pair(int a, int b) {
            p1 = a;
            p2 = b;
        }
    }

    public AutoCollider(PhyModel mdl, double size, int nbX, int nbY, int nbZ, double K, double Z){
        // save the model reference
        this.m_model = mdl;

        int nbMat = m_model.getNumberOfMasses();

        // create collider structures for all mats
        int counter = 0;
        for(Mass m : mdl.getMassList()){
            this.m_colliders.add(new MatCol(m, counter++));
        }

        // Store dimension of the whole scene and voxel size as two PVectors
        m_vSize = size;
        m_bounds = new Vect3D(m_vSize * nbX, m_vSize * nbY, m_vSize * nbZ);

        m_dimX = nbX;
        m_dimY = nbY;
        m_dimZ = nbZ;

        m_K = K;
        m_Z = Z;

        m_boxes = new Voxel[m_dimX][m_dimY][m_dimZ];
        m_actives = new ArrayList<>();

        for (int i = 0; i < m_dimX; i++)
            for (int j = 0; j < m_dimY; j++)
                for (int k = 0; k < m_dimZ; k++)
                    m_boxes[i][j][k] = new Voxel(i, j, k);


        m_colTable = new boolean[nbMat][nbMat];
        for (int i = 0; i < nbMat; i++)
            for (int j = 0; j < nbMat; j++)
                m_colTable[i][j] = false;

    }

    public ArrayList<SpacePrint> activeVoxelSpacePrints(){
        ArrayList<SpacePrint> spa = new ArrayList<>();
        for (Voxel vox : m_actives) {
            SpacePrint tmp = new SpacePrint();
            tmp.set((vox.idX  - Math.floor(m_dimX*0.5)) * m_vSize,
                    (vox.idX + 1 - Math.floor(m_dimX*0.5)) * m_vSize,
                    (vox.idY  - Math.floor(m_dimY*0.5)) * m_vSize,
                    (vox.idY + 1 - Math.floor(m_dimY*0.5)) * m_vSize,
                    (vox.idZ -  Math.floor(m_dimZ*0.5)) * m_vSize,
                    (vox.idZ + 1 - Math.floor(m_dimZ*0.5)) * m_vSize);
            spa.add(tmp);
        }
        return spa;
    }

    public void generateSpaceTags() {

        for (Voxel vox : m_actives) {
            vox.clearParticles();
        }
        m_actives.clear();

        for (int cur = 0; cur < m_model.getNumberOfMasses(); cur++) {

            MatCol current = this.m_colliders.get(cur);
            current.m_Out = false;
            current.m_Inter = false;
            current.clearVoxels();

            Vect3D pos = current.getMass().getPos();
            double radius = current.getMass().getParam(param.RADIUS);

            int p_min = (int)Math.floor((pos.x - radius + m_bounds.x * 0.5)/m_vSize);
            int r_min = (int)Math.floor((pos.y - radius + m_bounds.y * 0.5)/m_vSize);
            int c_min = (int)Math.floor((pos.z - radius + m_bounds.z * 0.5)/m_vSize);
            int p_max = (int)Math.floor((pos.x + radius + m_bounds.x*0.5)/m_vSize);
            int r_max = (int)Math.floor((pos.y + radius + m_bounds.y*0.5)/m_vSize);
            int c_max = (int)Math.floor((pos.z + radius + m_bounds.z*0.5)/m_vSize);

            // If entirely out of bounds, skip test
            if ((p_max < 0) || (p_min > m_dimX-1) ||
                    (r_max < 0) || (r_min > m_dimY-1) ||
                    (c_max < 0) || (c_min > m_dimZ-1)) {
                //println("Is outside of scope, skipping : " + cur + ", " + pos);
                current.m_Out = true;
            } else if ((p_max >= m_dimX) || (p_min < 0) ||
                    (r_max >= m_dimY) || (r_min < 0) ||
                    (c_max >= m_dimZ) || (c_min < 0)) {
                //println("Intersects with a border, be careful: " + cur + ", " + pos);
                current.m_Inter = true;
            }


            if (!current.m_Out) {
                for (int i = Math.max(p_min, 0); i <= Math.min(p_max, m_dimX-1); i++) {
                    for (int j = Math.max(r_min, 0); j <= Math.min(r_max, m_dimY-1); j++) {
                        for (int k = Math.max(c_min, 0); k <= Math.min(c_max, m_dimZ-1); k++) {


                            //println(i + ", " + j + ", " + k);

                            //current.addVoxel(new SpatHash(i, j, k));
                            current.addVoxel(m_boxes[i][j][k]);

                            //System.out.println("Mat nb: " + cur + ". " +i + ", "+ j +", " + k);

                            m_boxes[i][j][k].addParticle(current.getMass(), cur);

                            if (!m_actives.contains(m_boxes[i][j][k]))
                                m_actives.add(m_boxes[i][j][k]);
                        }
                    }
                }
            }
            // Enf of per-mass loop
        }
        // End of SpaceTags method
    }

    void computeCollisions() {

        //MatCol current;
        boolean padding = false;

        for (Pair p : m_activeCols) {
            m_colTable[p.p1][p.p2] = false;
        }
        m_activeCols.clear();


        for(MatCol current : m_colliders){
            // For each SpaceHash associated to this MAT
            for (Voxel curVox : current.getActiveVoxList()) {

                // Create some "soft" borders to avoid crazy behaviour
                if ((curVox.idX<= 0)||(curVox.idX >= m_dimX-1) ||
                        (curVox.idY<= 0)||(curVox.idY >= m_dimY-1) ||
                        (curVox.idZ<= 0)||(curVox.idZ >= m_dimZ-1)) {
                    padding = true;
                    contactLink.setParam(param.STIFFNESS, 0.001 * m_K);
                    contactLink.setParam(param.DAMPING, 0.001 * m_Z);
                } else {

                    padding = false;
                    contactLink.setParam(param.STIFFNESS,  m_K);
                    contactLink.setParam(param.DAMPING, m_Z);
                }


                // If there is only one particle in the voxel, no collisions to run
                if (curVox.getNumberOfParticles() < 2) {
                    //System.out.println("\t Single particle, nothing to do: " + curVox.getNumberOfParticles());
                }
                // Otherwise we need to calculate some things
                else {
                    //println("\tFound several particles, looking into it : " + curVox.getNumberOfParticles());
                    // Go through all MAT indexes associated with this Voxel

                    for(Map.Entry<Integer, Mass> entry : curVox.getParticleList().entrySet()){
                        int second = entry.getKey();
                        Mass m2 = entry.getValue();

                        int cur = current.getIndex();

                        if(second > cur){
                            //println("\t\t This seems valid");
                            if (!m_colTable[cur][second]) {

                                //System.out.println("\t\t Not yet been calculated, lets GO !");
                                m_activeCols.add(new Pair(cur, second));
                                m_colTable[cur][second] = true;

                                contactLink.connect(current.getMass(), m2);
                                contactLink.forceRecalculateVelocity();
                                contactLink.compute();
                            } else {
                                //System.out.println("\t\t This collision has already been taken care of");
                            }
                        }

                    }
                }
            }
        }
    }

}
