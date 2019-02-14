# **miPhysics**
# Mass-Interaction Physics in Java/Processing

**miPhysics** is a mass-interaction physical modelling library, coded in Java and designed for the *Processing* sketching environment.

Using elementary physical elements (such as masses, springs, contact interactions...) it allows modular design of any type of physical object for **visual generation**, **audio synthesis** or **haptic interaction** purposes - or even ***all three*** at the same time !

![](miPhysics/data/mesh.gif)


## Getting Started

Clone or download the github repository and place the **"miPhysics"** folder in the Processing sketchbook "library" folder.


### Prerequisites

Any up to date version of Processing should do the trick (the library is untested for processing v1).

### Installing

See above.

A few libraries are necessary to run the different examples (peasycam, minim, shapes3D): you can get these from Processing's library manager.

## Running the examples

Open up the examples within the folder or in Processing's example browser and go crazy!

Examples are split into categories:

* **0_Basics**: start here if you have no idea what mass-interaction physical modelling is about. The simple examples should help understand how things work and how models can be coded in Processing.

* **1_Visuals**: some more elaborate models for generating visual behaviour, also showing some more advanced features (dynamic topology changes, grouped parameter modification, etc.)

* **2_Audio**: examples generating real-time sound synthesis with mass-interaction models. The code structure is a little different here (as the model runs in an audio thread, using the Minim library).

* **3_Haptics**: multi-sensory haptic interaction models! Some are purely haptic scenes, whereas others allow audio-haptic interaction with sound-producing virtual models (such as strings, etc.).

The Haptic examples require the Haply system. For information and installation requirements, see: [HaplyHaptics](https://github.com/HaplyHaptics)'s github page.

![](miPhysics/data/string.gif)


## A Simple Example Code


```java

/*
Model: Hello Mass

A physical equivalent to a Hello World program!

We create a mass, and attach it to six fixed points with spring-dampers.
We then simulate the model, and can trigger forces on the mass by hitting the space bar.
*/

import miPhysics.*;
import peasy.*;
PeasyCam cam;

int displayRate = 90;

float m = 1.0;
float k = 0.001;
float z = 0.01;
float dist = 70;

/*  global physical model object : will contain the model and run calculations. */
PhysicalModel mdl;

void setup() {
  frameRate(displayRate);
  size(1000, 700, P3D);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(100);
  cam.setMaximumDistance(500);

  mdl = new PhysicalModel(300, displayRate);

  /* Create a mass, connected to fixed points via Spring Dampers */
  mdl.addMass3D("mass", m, new Vect3D(0., 0., 0.), new Vect3D(0., 0., 1.));

  mdl.addGround3D("ground1", new Vect3D(dist, 0., 0.));
  mdl.addGround3D("ground2", new Vect3D(-dist, 0., 0.));
  mdl.addGround3D("ground3", new Vect3D(0., dist, 0.));
  mdl.addGround3D("ground4", new Vect3D(0., -dist, 0.));
  mdl.addGround3D("ground5", new Vect3D(0., 0., dist));
  mdl.addGround3D("ground6", new Vect3D(0., 0., -dist));

  mdl.addSpringDamper3D("spring1", dist, k, z, "mass", "ground1"); 
  mdl.addSpringDamper3D("spring2", dist, k*0.9, z, "mass", "ground2"); 
  mdl.addSpringDamper3D("spring3", dist, k*2, z, "mass", "ground3"); 
  mdl.addSpringDamper3D("spring4", dist, k*2.1, z, "mass", "ground4"); 
  mdl.addSpringDamper3D("spring5", dist, k*1.5, z, "mass", "ground5"); 
  mdl.addSpringDamper3D("spring6", dist, k*1.6, z, "mass", "ground6"); 

  mdl.init(); 
}

void draw() {
  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(0);
  stroke(255);

  /* Calculate Physics */
  mdl.draw_physics();

  /* Draw the mass and the springs */
  PVector pos = mdl.getMatPVector("mass");
  line(pos.x, pos.y, pos.z, dist, 0, 0);
  line(pos.x, pos.y, pos.z, -dist, 0, 0);
  line(pos.x, pos.y, pos.z, 0, dist, 0);
  line(pos.x, pos.y, pos.z, 0, -dist, 0);
  line(pos.x, pos.y, pos.z, 0, 0, dist);
  line(pos.x, pos.y, pos.z, 0, 0, -dist);
  translate(pos.x, pos.y, pos.z);
  sphere(15);
}

/* Trigger random forces on the mass */
void keyPressed() {
  if (key == ' ')
    mdl.triggerForceImpulse("mass",random(-5,5),random(-5,5),random(-5,5));
}

```


## Built With

Library built and documentation generated with IntelliJ IDEA.

It is also possible to use the .jar library outside of Processing (soon to be documented).

## Contributing

We'd be happy to include more people to the development repository, so drop us a line if you would like to contribute to the development of the library.


If you have created models that you would like to see integrated into the library examples, get in touch!


## Authors

This project was developped by James Leonard and Jérôme Villeneuve.

For more info, see: www.mi-creative.eu

## License

This project is licensed under the GNU GENERAL PUBLIC LICENSE - see the [LICENSE](LICENSE) file for details

## Acknowledgments

This work implements mass-interaction physical modelling, a concept originally developped at ACROE - and now widely used in sound synthesis, haptic interaction and visual creation.
