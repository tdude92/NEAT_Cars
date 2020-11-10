// Recommended music: https://www.youtube.com/watch?v=atuFSv2bLa8

import g4p_controls.*;

// Car starting position and direction
Vec2f CAR_POS = new Vec2f(500, 300);
Vec2f CAR_DIR = new Vec2f(1, 0);
int TIME_LIMIT = 2; // Number of seconds each car gets during training
float W_LAPTIME = 8; // The weight of lap time in fitness calculations

// Global variables
Evaluator eval;
Course course;
Car car;

NeuralNet bestNN, medianNN, worstNN; // These are global so that NeuralNet.nodePos isn't recomputed every
                                     // time drawGenerationSummary() is called

Histogram fitnessDist = new Histogram("Fitness", "No. Individuals", 20, 360, 470, 670, 12, 30, 8);
PieChart speciesChart = new PieChart(715, 515, 160);

void setup() {
  // Uncomment any one of these tests to try the tests I used during development
  //trainXOR();              //     XOR is not linearly separable, so the neural nets will have to evolve new neurons
  //testPretrainedXOR(1, 1); // <-- try changing the inputs to (0, 0), (0, 1), or (1, 0)

  // SKETCH SETUP
  createGUI();
  size(1250, 720);
  frameRate(FRAMERATE);
  
  // Set up course and car (Evaluator set up in the START TRAINING button callback)
  course = new Course();
  course.load(TRACK_FILE_PATH);
  car = new Car(CAR_POS, CAR_DIR, course, color(255, 0, 0));
  
  while (!SIM_START) {print();} // Wait until setup is complete
  
  if (EVAL_MODE) {
    // If the program is in eval mode, load the user-selected genome into the car once
    car.nn = new NeuralNet(EVAL_GENOME, new Sigmoid(4.9));
    car.reset(CAR_POS, CAR_DIR);
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
    // When we want to draw a car to the screen, we load a NeuralNet into car.nn
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
      text("Press 'q' to go back to the Generation Summary", 10, 20);
    } else {
      text("Press 'q' to exit the simulation", 10, 20);
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
    //println("Evaluating Individual no.", i + 1);
    NeuralNet nn = nns[i];
    
    car.reset(CAR_POS, CAR_DIR);
    car.nn = nn;
    
    while (!car.crashedFlag && car.timer < car.timeLimit && !car.lapCompleted) {
      // Simulate the car driving
      car.update();
    }
    
    if (car.lapCompleted) {
      // If the car completed a lap, factor in lap time to fitness
      car.fitness += abs(1/(car.timer/FRAMERATE - 8)*W_LAPTIME);
    }
    
    nn.genome.fitness = car.fitness; // Update the genome's fitness
  }
  
  // Update the population after all genomes have been evaluated
  eval.updatePopulation();
  car.nn = null; // Reset car.nn to null so that we stay in the generationSummary
  
  if (!TRAIN_INDEF) {
    SIM_START = false; // Pause the simulation and enter the generationSummary
  } else {
    // Save the best genome automatically
    eval.bestGenome.writeGenome(GENOME_SAVE_PATH);
    println("Best genome saved to " + GENOME_SAVE_PATH);
  }
  
  // Set the best, median, and worst neural nets
  bestNN = new NeuralNet(eval.bestGenome, new Sigmoid(4.9));
  medianNN = new NeuralNet(eval.medianGenome, new Sigmoid(4.9));
  worstNN = new NeuralNet(eval.worstGenome, new Sigmoid(4.9));
}


void drawGenerationSummary() {
  // Display information about the completed generation.
  background(0);
  
  // Header text
  fill(255);
  textSize(48);
  text("Generation " + str(eval.generation), 20, 60);
  
  // Display best, median, worst genomes
  textSize(12);
  
  fill(255);
  rect(20, 100, 300, 200);
  text("Best Genome", 20, 320);
  text("Fitness: " + eval.bestGenome.rawFitness, 20, 340);
  bestNN.drawNN(40, 120, 300, 280);
  
  fill(255);
  rect(340, 100, 300, 200);
  text("Median Genome", 340, 320);
  text("Fitness: " + eval.medianGenome.rawFitness, 340, 340);
  medianNN.drawNN(360, 120, 620, 280);
  
  fill(255);
  rect(660, 100, 300, 200);
  text("Worst Genome", 660, 320);
  text("Fitness: " + eval.worstGenome.rawFitness, 660, 340);
  worstNN.drawNN(680, 120, 940, 280);
  
  fill(255);
  text("Try clicking on one\nof the neural nets!", 1000, 120);
  
  // Update graphs
  fitnessDist.draw(eval);
  fill(255);
  textAlign(BOTTOM, LEFT);
  text("Fitness Distribution", 20, 690);
  
  speciesChart.draw(eval);
  fill(255);
  textAlign(BOTTOM, LEFT);
  text("Species Populations", 490, 690);
  
  // BUTTONS
  textSize(24);
  textAlign(CENTER, CENTER);
  
  // Button colours change if the mouse is hovering over it
  color nextGenerationCol = color(100, 255, 100);
  color trainIndefCol = color(100, 255, 100);
  color saveBestGenomeCol = color(255, 165, 0);
  color endTrainingCol = color(255, 100, 100);
  
  // Check if the mouse is within the bounds of each button
  if (1000 < mouseX && mouseX < 1230 && 600 < mouseY && mouseY < 700) {
    // Check "Next Generation" button
    nextGenerationCol = color(200, 255, 200);
  } else if (1000 < mouseX && mouseX < 1230 && 480 < mouseY && mouseY < 580) {
    // Check "Train Indefinitely" button
    trainIndefCol = color(200, 255, 200);
  } else if (1000 < mouseX && mouseX < 1230 && 360 < mouseY && mouseY < 460) {
    // Check "Save Best Genome" button
    saveBestGenomeCol = color(255, 255, 200);
  } else if (1000 < mouseX && mouseX < 1230 && 210 < mouseY && mouseY < 310) {
    // Check "End Training" button
    endTrainingCol = color(255, 200, 200);
  }

  // Start next generation
  fill(nextGenerationCol);
  rect(1000, 570, 230, 100);
  fill(50, 127, 50);
  text("Next Generation", 1115, 620);
  
  // Train indefinitely
  fill(trainIndefCol);
  rect(1000, 450, 230, 100);
  fill(50, 127, 50);
  text("Train Indefinitely", 1115, 500);
  
  // Save Best Genome
  fill(saveBestGenomeCol);
  rect(1000, 330, 230, 100);
  fill(127, 82, 0);
  text("Save Best Genome", 1115, 380);
  
  // Stop training
  fill(endTrainingCol);
  rect(1000, 210, 230, 100);
  fill(127, 50, 50);
  text("End Training", 1115, 260);
  
  // Reset text size and text align
  textSize(12);
  textAlign(LEFT, UP);
}

void mousePressed() {
  // For clicking buttons
  if (!EVAL_MODE && car.nn == null) {
    // If the program is in training mode and car.nn is null, the
    // program is currently in the generation summary
    
    if (1000 < mouseX && mouseX < 1230 && 600 < mouseY && mouseY < 700) {
      // "Next Generation" button clicked
      SIM_START = true;
    } else if (1000 < mouseX && mouseX < 1230 && 480 < mouseY && mouseY < 580) {
      // "Train Indefinitely" button clicked
      SIM_START = true;
      TRAIN_INDEF = true;
    } else if (1000 < mouseX && mouseX < 1230 && 360 < mouseY && mouseY < 460) {
      // "Save Best Genome" button clicked
      eval.bestGenome.writeGenome(GENOME_SAVE_PATH);
      println("Best genome saved to " + GENOME_SAVE_PATH);
    } else if (1000 < mouseX && mouseX < 1230 && 210 < mouseY && mouseY < 310) {
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
