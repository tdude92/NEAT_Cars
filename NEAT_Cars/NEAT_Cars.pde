Course course;
Car car;

void setup() {
  // Uncomment any one of these cars to run the cars I used during development
  
  //trainXOR();              //     XOR is not linearly separable, so the neural nets will have to evolve new neurons
  //testPretrainedXOR(1, 1); // <-- try changing the inputs to (0, 0), (0, 1), or (1, 0)

  // SKETCH SETUP
  size(1400, 720);
  frameRate(FRAMERATE);
  
  course = new Course(COURSE_WALLS);
  car = new Car(new Vec2f(500, 300), new Vec2f(1, 0), course, color(255, 0, 0));
  car.nn = new NeuralNet(new Genome(6, 6), new Sigmoid(4.9));
}


void draw() {
  background(0);
  course.draw();
  
  car.update();
}
