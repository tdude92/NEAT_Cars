void setup() { /*
  Genome p1 = new Genome(4, 2);//, p2;
  p1.addConn();
  p1.linkNodes(); // TODO: uncomment this.linkNodes in the constructor of Genome after done testing with neural nets.
  //Genome g = new Genome(p1, p2);
  
  p1.printGenes(true);println();
  //p2.printGenes(true);println();
  //g.printGenes(true);
  
  NeuralNet testnet = new NeuralNet(p1, new Sigmoid(4.9));
  testnet.printConns();
  float[] input = {1, 1, 1, 1};
  testnet.forward(input);
  testnet.printOutput();
  println(testnet.computeDepth());
  
  
  //p1.writeGenome("./model/test.genome");
  //p2 = new Genome("./model/test.genome");
  //p2.printGenes(true);*/
  
  // NEAT TEST: TRAIN ON XOR
  Evaluator eval = new Evaluator(1000, new Sigmoid(4.9));
  eval.initPopulation(2, 1);
  while (true) {
    NeuralNet[] nns = eval.getNeuralNets();
    for (NeuralNet nn : nns) {
      float fitness = 4;
      for (int i = 0; i <= 1; ++i) {
        for (int j = 0; j <= 1; ++j) {
          float groundTruth = i^j;
          float[] in = {i, j};
          float out = nn.forward(in)[0];
          float mse = pow(groundTruth - out, 2);
          fitness -= mse;
        }
      }
      nn.genome.fitness = fitness;
    }
    eval.updatePopulation();
    println();
    println("Generation", eval.generation);
    println(eval.bestGenome.fitness);
    println(eval.medianGenome.fitness);
    println(eval.worstGenome.fitness);
    for (Species species : eval.species) {
      println(species.id, species.allocatedOffspring);
    }
  }
}

void draw() {}
