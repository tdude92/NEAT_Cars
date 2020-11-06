long t = millis();
Car test = new Car(new Vec2f(500, 400), new Vec2f(0, -1), color(255));

void setup() {
  /* TESTS */
  // Uncomment any one of these tests to run the tests I used during development
  
  //trainXOR();              //     XOR is not linearly separable, so the neural nets will have to evolve new neurons
  //testPretrainedXOR(1, 1); // <-- try changing the inputs to (0, 0), (0, 1), or (1, 0)
  //testCar();               //     Drive the car around and test collision detection & checkpointing

  /* Sketch setup */
  size(1200, 720);
  frameRate(FRAMERATE);
  
  test.gas();
}

void draw() {
  background(0);
  test.update();
  if (test.pos.y < -CAR_L/2) {
    test.pos.y = height + CAR_L/2;
  }
  if (millis() - t > 5000) {
    test.brake();
  }
}
