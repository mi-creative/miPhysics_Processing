void generatePinScreen3D(PhyModel mdl, int dimX, int dimY, int dimZ, String mName, String lName, double masValue, double dist, double K_osc, double Z_osc, double K, double Z) {
  // add the masses to the model: name, mass, initial pos, init speed
  String celName;
  Vect3D X0, V0;
  
  for (int k = 0; k < dimZ; k++) {
    for (int i = 0; i < dimY; i++) {
      for (int j = 0; j < dimX; j++) {
        celName = mName + j +"_"+ i +"_"+ k;
        //println(celName);
        masValue = 1.0;
        X0 = new Vect3D(j*dist, i*dist, k*dist);
        V0 = new Vect3D(0., 0., 0.);

        mdl.addMass(celName, new Osc3D(masValue, 1, K_osc, Z_osc, X0, V0));
        //mdl.addOsc3D(celName, masValue, 1, K_osc, Z_osc, X0, V0);
      }
    }
  }


  // add the spring to the model: length, stiffness, connected mats
   String celName1, celName2;
   for (int k = 0; k < dimZ; k++) {
     for (int i = 0; i < dimX-1; i++) {
       for (int j = 0; j < dimY; j++) {
         celName1 = mName + j +"_"+ i +"_"+ k;
         celName2 = mName + j +"_"+ str(i+1) +"_"+ k;
         //println("X " +celName1+celName2);
         
         String intName = lName +"_1_"+i+"_"+j+"_"+k;
         mdl.addInteraction(intName, new SpringDamper3D(dist, K, Z), celName1, celName2);
         //mdl.addSpringDamper3D(lName + "1_" +i+j, dist, K, Z, celName1, celName2);
       }
     }
   }
   
   for (int k = 0; k < dimZ; k++) {
     for (int i = 0; i < dimX; i++) {
       for (int j = 0; j < dimY-1; j++) {
         celName1 = mName + j +"_"+ i +"_"+ k;
         celName2 = mName + str(j+1) +"_"+ i +"_"+ k;
         //println("Y " +celName1+celName2);
         
         String intName = lName +"_2_"+i+"_"+j+"_"+k;
         mdl.addInteraction(intName, new SpringDamper3D(dist, K, Z), celName1, celName2);
         //mdl.addSpringDamper3D(lName + "1_" +i+j, dist, K, Z, celName1, celName2);
       }
     }
   }
   
   for (int k = 0; k < dimZ-1; k++) {
     for (int i = 0; i < dimX; i++) {
       for (int j = 0; j < dimY; j++) {
         celName1 = mName + j +"_"+ i +"_"+ k;
         celName2 = mName + j +"_"+ i +"_"+ str(k+1);
         //println("Y " +celName1+celName2);
         String intName = lName +"_3_"+i+"_"+j+"_"+k;
         mdl.addInteraction(intName, new SpringDamper3D(dist, K, Z), celName1, celName2);
         //mdl.addSpringDamper3D(lName + "1_" +i+j, dist, K, Z, celName1, celName2);
       }
     }
   }
  
}
