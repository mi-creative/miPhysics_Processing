# **miPhysics**
# Mass-Interaction Physics in Java/Processing

**miPhysics** is a mass-interaction physical modelling library, coded in Java and designed for the *Processing* sketching environment.

Using elementary physical elements (such as masses, springs, contact interactions...) it allows modular design of any type of physical object for **visual generation**, **audio synthesis** or **haptic interaction** purposes - or even ***all three*** at the same time !

![](data/mesh.gif)


## 1 - Using miPhysics: Getting Started

This repo contains the _development_ framework allowing to build the library.

If you just want the **_compiled_ version of the library for Processing**, head to the ***release*** section and download the latest release **ZIP file**.

Then unzip the file and place the **"miPhysics"** folder in the Processing sketchbook "library" folder. 


### Prerequisites

Any up to date version of Processing should do the trick (the library is untested for processing v1).

### Installing

See above.

A few libraries are necessary to run the different examples (peasycam, minim, shapes3D, midiBus): you can obtain these from Processing's library manager.

## 2 - Running the examples

Open up the examples within the folder or in Processing's example browser and go crazy!

Examples are split into categories:

* **0_Basics**: start here if you have no idea what mass-interaction physical modelling is about. The simple examples should help understand how things work and how models can be coded in Processing.

* **1_Visuals**: some more elaborate models for generating visual behaviour, also showing some more advanced features (dynamic topology changes, grouped parameter modification, etc.)

* **2_Audio**: examples generating real-time sound synthesis with mass-interaction models. The code structure is a little different here (as the model runs in an audio thread, using the Minim library).

* **3_Haptics**: multi-sensory haptic interaction models! Some are purely haptic scenes, whereas others allow audio-haptic interaction with sound-producing virtual models (such as strings, etc.).

The Haptic examples require the Haply system. For information and installation requirements, see: [HaplyHaptics](https://github.com/HaplyHaptics)'s github page.

![](data/string.gif)


## 3 - A Simple Example Code


```java

/*
Model: Hello Mass

A physical equivalent to a Hello World program!

We create a mass, and attach it to six fixed points with spring-dampers.
We then simulate the model, and can trigger forces on the mass by 
hitting the space bar.
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

ModelRenderer renderer;


void setup() {
  frameRate(displayRate);
  size(1000, 700, P3D);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(100);
  cam.setMaximumDistance(500);
  
  mdl = new PhysicalModel(300, displayRate);
  
  /* Create a mass, connected to fixed points via Spring Dampers */
  mdl.addMass("mass", new Mass3D(m, 15, new Vect3D(0., 0., 0.), new Vect3D(0., 0., 0.)));

  //mdl.addMass3D("mass", m, 10, new Vect3D(0., 0., 0.), new Vect3D(0., 0., 1.));
  mdl.addMass("ground1", new Ground3D(1, new Vect3D(dist, 0., 0.)));
  mdl.addMass("ground2", new Ground3D(1, new Vect3D(-dist, 0., 0.)));
  mdl.addMass("ground3", new Ground3D(1, new Vect3D(0., dist, 0.)));
  mdl.addMass("ground4", new Ground3D(1, new Vect3D(0., -dist, 0.)));
  mdl.addMass("ground5", new Ground3D(1, new Vect3D(0., 0., dist)));
  mdl.addMass("ground6", new Ground3D(1, new Vect3D(0., 0., -dist)));

  mdl.addInteraction("spring1", new SpringDamper3D(dist, k, z), "mass", "ground1");
  mdl.addInteraction("spring2", new SpringDamper3D(dist, k*0.9, z), "mass", "ground2");
  mdl.addInteraction("spring3", new SpringDamper3D(dist, k*2, z), "mass", "ground3");
  mdl.addInteraction("spring4", new SpringDamper3D(dist, k*2.1, z), "mass", "ground4");
  mdl.addInteraction("spring5", new SpringDamper3D(dist, k*1.5, z), "mass", "ground5");
  mdl.addInteraction("spring6", new SpringDamper3D(dist, k*1.2, z), "mass", "ground6");
  
  mdl.addInOut("drive",new Driver3D(),"mass");
  
  mdl.init(); 
  
  renderer = new ModelRenderer(this);
  renderer.setZoomVector(1,1,1);
}

void draw() {
  directionalLight(251, 102, 126, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(0);
  stroke(255);
  
  /* Calculate Physics */
  mdl.compute();
  renderer.renderModel(mdl);

}

/* Trigger random forces on the mass */
void keyPressed() {
  if (key == ' '){
    for(Driver3D driver : mdl.getDrivers())
      driver.applyFrc(new Vect3D(random(-5,5),random(-5,5),random(-5,5)));
  }

```

## 4 - Developping miPhysics

If you would like to manually build or work on the miPhysics library, clone or fork the github repository.

The library is currently built using Intellij IDEA (Ant build & automatic Javadoc generation), based on a template for developping Processing libraries.
Building with Eclipse should also be possible (cf. guidelines below).


### Using the library outside of Processing

It is also possible to use the .jar library outside of Processing. So far, this has been tested in Max/MSP (using the MXJ system) but is not yet documented.

### Contributing

We'd be happy to involve more coders in developping the library further, extending functionnalities and debugging. Feel free to fork the repo, suggest pull requests, etc.


If you have created models that you would like to see integrated into the library examples, get in touch!


## 5 - Authors

This project was developped by James Leonard and Jérôme Villeneuve.

For more info, see: www.mi-creative.eu

## 6 - License

This project is licensed under the GNU GENERAL PUBLIC LICENSE - see the [LICENSE](LICENSE) file for details

## 7 - Acknowledgments

This work implements mass-interaction physical modelling, a concept originally developped at ACROE - and now widely used in sound synthesis, haptic interaction and visual creation.

