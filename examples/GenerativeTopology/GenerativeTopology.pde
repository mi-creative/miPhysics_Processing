import physicalModelling.*;
import peasy.*;
PeasyCam cam;

int displayRate = 90;

int iter = 0;

float m = 1.0;
float k = 0.0001;
float z = 0.01;
float dist = 10;
int mass_cpt = 0;

/*  global physical model object : will contain the model and run calculations. */
PhysicalModel mdl;

void setup() {
  frameRate(displayRate);
  size(1000, 700, P3D);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(100);
  cam.setMaximumDistance(1500);
  
  mdl = new PhysicalModel(300, displayRate);
  
  mdl.addGround3D("ground", new Vect3D(0., 0., 0.));
  
  mdl.setFriction(0.00005);
  mdl.setFriction(0.0001);
  ///* Group modules into subsets for parameter modifications */
  //mdl.createMatSubset("massmod");
  //mdl.addMatToSubset("mass","massmod");
  
  //mdl.createLinkSubset("X_springs");
  //mdl.addLinkToSubset("spring1","X_springs");
  //mdl.addLinkToSubset("spring2","X_springs");
  
  //mdl.createLinkSubset("Y_springs");
  //mdl.addLinkToSubset("spring3","Y_springs");
  //mdl.addLinkToSubset("spring4","Y_springs");
  
  //mdl.createLinkSubset("Z_springs");
  //mdl.addLinkToSubset("spring5","Z_springs");
  //mdl.addLinkToSubset("spring6","Z_springs");
  
  mdl.init(); 
}

void draw() {
  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(0);
  noStroke();
  
  /* Calculate Physics */
  mdl.draw_physics();
  renderModel(mdl,3);  
  
}

void keyPressed() {
  // Trigger a random force on the mass module
  if (key == ' ')
    if(mass_cpt >0 && iter == 0)
      mdl.triggerForceImpulse("mass0",random(-5,5),random(-5,5),random(-5,5));
    else for(int i=0; i<iter;i++){
      mdl.triggerForceImpulse("mass" + (mass_cpt-1-iter+i),random(-1,1),random(-1,1),random(-1,1));
    }
  // randomly modify the inertia of the mass module
  
  if (key == 'a'){
    if(mass_cpt ==0){
     /* Create a mass, connected to fixed points via Spring Dampers */
     mdl.addMass3D("mass0", m, new Vect3D(0., 0., 0.), new Vect3D(0., 1., 0.));
     mdl.addSpringDamper3D("spring0", dist, k, z, "mass0", "ground");
     println("Step 0: Create module: mass0");
     //iter++;
     mass_cpt++;
    }
   else{
     iter++;
     for(int i = 0; i<iter; i++){
       for(int j = 0; j<2; j++){
         Vect3D origin = mdl.getMatPosition("mass" + str(mass_cpt-iter+i));
         mdl.addMass3D("mass"+ (mass_cpt+i*2+j), m, 
         new Vect3D(origin.x + random(dist), origin.y + random(dist), origin.z + random(dist)), new Vect3D(0., 0., 0));
         println("Create module: mass"+ str(mass_cpt+i*2+j) +", iter: " + iter + ", mass_cpt: " + mass_cpt);
         println("Spring connect " + "mass" + str(mass_cpt+i*2+j) +" to " + "mass" + str(mass_cpt-iter+i)); 
         mdl.addSpringDamper3D("spring", dist, k, z, "mass" + str(mass_cpt+i*2+j), "mass" + str(mass_cpt-iter+i));  
       }
     }
     println("...");
     mass_cpt += 2*iter; 
    }
  }
}