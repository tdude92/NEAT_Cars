// Recommended music: https://www.youtube.com/watch?v=atuFSv2bLa8

import g4p_controls.*;

// Global variables
Evaluator eval;
Course course;
Car car;

void setup() {
  createGUI();
  
  // Uncomment any one of these tests to try the tests I used during development
  //trainXOR();              //     XOR is not linearly separable, so the neural nets will have to evolve new neurons
  //testPretrainedXOR(1, 1); // <-- try changing the inputs to (0, 0), (0, 1), or (1, 0)

  // SKETCH SETUP
  size(1400, 720);
  frameRate(FRAMERATE);
  
  // Set up evaluator
  eval = new Evaluator(POPULATION, DEFAULT_ACTIVATION);
  eval.initPopulation(6, 6);
  
  // Set up course and car
  course = new Course(COURSE_WALLS);
  car = new Car(new Vec2f(500, 300), new Vec2f(1, 0), course, color(255, 0, 0));
  
  while (!SIM_START) {print();} // Wait until setup is complete
}


void draw() {
  background(0);
  course.draw();
}
