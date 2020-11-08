// Recommended music: https://www.youtube.com/watch?v=atuFSv2bLa8

import g4p_controls.*;

// Car starting position and direction
Vec2f CAR_POS = new Vec2f(500, 300);
Vec2f CAR_DIR = new Vec2f(1, 0);
int TIME_LIMIT = 5000; // Number of milliseconds each car gets during training

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
  car = new Car(CAR_POS, CAR_DIR, course, color(255, 0, 0));
  
  while (!SIM_START) {print();} // Wait until setup is complete
  
  if (EVAL_MODE) {
    // If the program is in eval mode, load the user-selected genome into the car once
    car.nn = new NeuralNet(EVAL_GENOME, new Sigmoid(4.9));
  } else {
    // If the program is in training mode, load the first nn in eval into the car
    car.nn = eval.getNeuralNets()[0];
  }
}

int nnCtr = 0; // Tracks the index of the nn loaded into car.
void draw() {
  background(0);
  car.update(); // Update the car
  course.draw();
}

void trainGeneration() {} // TODO
void generationSummary(Evaluator eval) {while(true) {}} // TODO (also set framerate here too depending on ASAP)
