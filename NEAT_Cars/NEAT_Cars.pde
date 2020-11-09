// Recommended music: https://www.youtube.com/watch?v=atuFSv2bLa8

import g4p_controls.*;

// Car starting position and direction
Vec2f CAR_POS = new Vec2f(500, 300);
Vec2f CAR_DIR = new Vec2f(1, 0);
int TIME_LIMIT = 5; // Number of seconds each car gets during training

// Global variables
Evaluator eval;
Course course;
Car car;

void setup() {
  // Uncomment any one of these tests to try the tests I used during development
  //trainXOR();              //     XOR is not linearly separable, so the neural nets will have to evolve new neurons
  //testPretrainedXOR(1, 1); // <-- try changing the inputs to (0, 0), (0, 1), or (1, 0)

  // SKETCH SETUP
  createGUI();
  size(1400, 720);
  frameRate(FRAMERATE);
  
  // Set up course and car (Evaluator set up in the START TRAINING button callback)
  course = new Course(COURSE_WALLS, CHECKPOINTS);
  car = new Car(CAR_POS, CAR_DIR, course, color(255, 0, 0));
  
  while (!SIM_START) {print();} // Wait until setup is complete
  
  if (EVAL_MODE) {
    // If the program is in eval mode, load the user-selected genome into the car once
    car.nn = new NeuralNet(EVAL_GENOME, new Sigmoid(4.9));
  }
}

// During training, control gets passed between draw(), trainGeneration(), and generationSummary()
// They all work with the car, course, and eval globals

void draw() {
  if (!EVAL_MODE && car.nn == null) { // The car's nn will always be reset to null at the end of a generation
    if (SIM_START) {
      // Set SIM_START to false at the start of the generation summary
      // SIM_START is set to true again when the generation summary ends
      trainGeneration();
    }
    
    drawGenerationSummary();
  } else if (car.nn != null) {
    // When we want to draw a car to the screen, we load an nn into car.nn
    // before going into the draw function
    background(0);
    car.update(); // Update the car
    car.draw();
    course.draw();
    
    if (car.crashedFlag) {
      // End the run after the car crashes
      car.nn = null;
    }
    
    fill(255);
    if (!EVAL_MODE) {
      text("Press 'q' to go back to the Generation Summary", 980, 20);
    } else {
      text("Press 'q' to exit the simulation", 980, 20);
    }
    if (keyPressed && key == 'q') {
      // Also end the run when escape is pressed
      car.nn = null;
    }
  } else {
    // If car.nn is null in EVAL_MODE, the simulation has finished, so exit.
    exit();
  }
}

void trainGeneration() {
  // Train one full generation without drawing
  NeuralNet[] nns = eval.getNeuralNets();
  for (int i = 0; i < nns.length; ++i) {
    println("Evaluating Individual no.", i + 1);
    NeuralNet nn = nns[i];
    
    car.reset(CAR_POS, CAR_DIR);
    car.nn = nn;
    
    int timer = 0;
    while (!car.crashedFlag && timer < car.timeLimit) {
      // Simulate the car driving
      car.update();
      timer++;
    }
    
    nn.genome.fitness = car.fitness; // Update the genome's fitness
  }
  
  // Update the population after all genomes have been evaluated
  eval.updatePopulation();
  car.nn = null; // Reset car.nn to null so that we stay in the generationSummary
  SIM_START = false; // Pause the simulation
}

void drawGenerationSummary() {
  // Display information about the completed generation.
  background(0);
  
  // Header text
  fill(255);
  textSize(48);
  text("Generation " + str(eval.generation), 20, 60);
  
  // Display best, median, worst genomes
  textSize(18);
  
  fill(255);
  rect(20, 100, 300, 200);
  text("Best Genome", 20, 320);
  text("Fitness: " + eval.bestGenome.rawFitness, 20, 340);
  new NeuralNet(eval.bestGenome, DEFAULT_ACTIVATION).drawNN(40, 120, 300, 280);
  
  fill(255);
  rect(340, 100, 300, 200);
  text("Median Genome", 340, 320);
  text("Fitness: " + eval.medianGenome.rawFitness, 340, 340);
  new NeuralNet(eval.medianGenome, DEFAULT_ACTIVATION).drawNN(360, 120, 620, 280);
  
  fill(255);
  rect(660, 100, 300, 200);
  text("Worst Genome", 660, 320);
  text("Fitness: " + eval.worstGenome.rawFitness, 660, 340);
  new NeuralNet(eval.worstGenome, DEFAULT_ACTIVATION).drawNN(680, 120, 940, 280);
  
  // Graphical data
  new Histogram(20, 360, 470, 670);
  text("Fitness Distribution", 20, 690);
  
  new AreaChart(490, 360, 960, 670);
  text("Species Populations", 490, 690);
  
  // BUTTONS
  textSize(32);
  textAlign(CENTER, CENTER);
  
  // Button colours change if the mouse is hovering over it
  color nextGenerationCol = color(100, 255, 100);
  color saveBestGenomeCol = color(255, 165, 0);
  color endTrainingCol = color(255, 100, 100);
  
  // Check if the mouse is within the bounds of each button
  if (1000 < mouseX && mouseX < 1380 && 600 < mouseY && mouseY < 700) {
    // Check "Next Generation" button
    nextGenerationCol = color(200, 255, 200);
  } else if (1000 < mouseX && mouseX < 1380 && 480 < mouseY && mouseY < 580) {
    // Check "Save Best Genome" button
    saveBestGenomeCol = color(255, 255, 200);
  } else if (1000 < mouseX && mouseX < 1380 && 360 < mouseY && mouseY < 460) {
    // Check "End Training" button
    endTrainingCol = color(255, 200, 200);
  }

  // Start next generation
  fill(nextGenerationCol);
  rect(1000, 600, 380, 100);
  fill(50, 127, 50);
  text("Next Generation", 1190, 650);
  
  // Save Best Genome
  fill(saveBestGenomeCol);
  rect(1000, 480, 380, 100);
  fill(127, 82, 0);
  text("Save Best Genome", 1190, 530);
  
  // Stop training
  fill(endTrainingCol);
  rect(1000, 360, 380, 100);
  fill(127, 50, 50);
  text("End Training", 1190, 410);
  
  // Reset text size and text align
  textSize(18);
  textAlign(LEFT, UP);
}

void mousePressed() {
  // For clicking buttons
  if (!EVAL_MODE && car.nn == null) {
    // If the program is in training mode and car.nn is null, the
    // program is currently in the generation summary
    
    if (1000 < mouseX && mouseX < 1380 && 600 < mouseY && mouseY < 700) {
      // "Next Generation" button clicked
      SIM_START = true;
    } else if (1000 < mouseX && mouseX < 1380 && 480 < mouseY && mouseY < 580) {
      // "Save Best Genome" button clicked
      eval.bestGenome.writeGenome(GENOME_SAVE_PATH);
      println("Best genome saved to " + GENOME_SAVE_PATH);
    } else if (1000 < mouseX && mouseX < 1380 && 360 < mouseY && mouseY < 460) {
      // "End Training" button clicked
      exit();
    } else if (20 < mouseX && mouseX < 320 && 100 < mouseY && mouseY < 300) {
      // Best genome clicked
      car.reset(CAR_POS, CAR_DIR);
      car.nn = new NeuralNet(eval.bestGenome, new Sigmoid(4.9));
    } else if (340 < mouseX && mouseX < 640 && 100 < mouseY && mouseY < 300) {
      // Median genome clicked
      car.reset(CAR_POS, CAR_DIR);
      car.nn = new NeuralNet(eval.medianGenome, new Sigmoid(4.9));
    } else if (660 < mouseX && mouseX < 960 && 100 < mouseY && mouseY < 300) {
      // Worst genome clicked
      car.reset(CAR_POS, CAR_DIR);
      car.nn = new NeuralNet(eval.worstGenome, new Sigmoid(4.9));
    }
  }
}
