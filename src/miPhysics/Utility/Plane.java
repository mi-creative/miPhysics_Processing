//package miPhysics;
//
//
//class Plane{
//
//    Plane(Vect3D a, Vect3D b, Vect3D c){
//
//        m_origin.set(a);
//
//        Vect3D ab = new Vect3D(a).sub(b);
//        Vect3D ac = new Vect3D(a).sub(c);
//
//        //ab.set(Vect3D.sub(a,b));
//        //ac.set(Vect3D.sub(a,c));
//
//        m_normal = ab.cross(ac);
//        if(m_normal.mag() < 0.0000001){
//            System.out.println("Invalid (colinear) vectors, cannot create plane");
//        }
//        m_normal.normalize();
//
//        m_a = m_normal.x;
//        m_b = m_normal.y;
//        m_c = m_normal.z;
//        m_d = a.x * m_a + a.y * m_b + a.z * m_c;
//    }
//
//    /*
//    void drawPlane(int radius){
//        pushMatrix();
//        translate(m_origin.x, m_origin.y, m_origin.z);
//        rotateX(m_normal.x);
//        rotateY(m_normal.y);
//        rotateZ(m_normal.z);
//        fill(127);
//        ellipse(0,0,radius, radius);
//        popMatrix();
//    }
//    */
//
//    Vect3D calcIntersection(Vect3D p){
//        double term  = (m_normal.x * p.x + m_normal.y * p.y + m_normal.z * p.z + m_d)
//                / m_normal.magSq();
//
//        Vect3D inter = new Vect3D();
//
//        inter.x = pos.x - m_normal.x * term;
//        inter.y = pos.y - m_normal.y * term;
//        inter.z = pos.z - m_normal.z * term;
//
//        return inter;
//    }
//
//
//    double m_a = 0;
//    double m_b = 0;
//    double m_c = 0;
//    double m_d = 0;
//
//    Vect3D m_origin = new Vect3D();
//    Vect3D m_normal = new Vect3D();
//
//    boolean m_valid = false;
//
//};