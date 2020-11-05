/* TESTS */

void trainXOR() {
  // Test NEAT on emulating the XOR operator
  int trial = 0;
  while (true){
      int ctr = 0;
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
      /*println();
      println("Generation", eval.generation);
      println("no. species:", eval.species.size());
      println(eval.bestGenome.rawFitness);
      println(eval.medianGenome.rawFitness);
      println(eval.worstGenome.rawFitness);
      println();
      NeuralNet test = new NeuralNet(eval.bestGenome, new Sigmoid(4.9));
      test.printConns();
      float[] t1 = {0, 0};
      float[] t2 = {0, 1};
      float[] t3 = {1, 0};
      float[] t4 = {1, 1};
      println("0 ^ 0: ", test.forward(t1)[0]);
      println("0 ^ 1: ", test.forward(t2)[0]);
      println("1 ^ 0: ", test.forward(t3)[0]);
      println("1 ^ 1: ", test.forward(t4)[0]);
      println(eval.bestGenome.rawFitness);
      println();*/ // Uncomment this section to seet each generation of each trial.

      if (4 - eval.bestGenome.rawFitness < 0.01 || ctr++ == 200) {
        println("Trial", ++trial);
        println("Accuracy:", eval.bestGenome.rawFitness / 4);
        println("No. Generatons:", eval.generation);
        println("No. Hidden Nodes:", eval.bestGenome.nodeGenes.size() - eval.bestGenome.nodeGenes_sen.size() - eval.bestGenome.nodeGenes_out.size());
        
        int nConnGenes = 0;
        for (ConnGene g : eval.bestGenome.connGenes) {if (g.enable) {nConnGenes++;}}
        println("No. Connections:", nConnGenes);
        
        
        println("No. Species:", eval.species.size());
        println();
        break;
      }
    }
  }
}

void testPretrainedXOR(float a, float b) {
  // Test the pretrained XOR in ./model/ with the inputs a & b
  Genome xorGenome = new Genome("model/XOR.xml");
  NeuralNet nn = new NeuralNet(xorGenome, new Sigmoid(4.9));
  float[] in = {a, b};
  println("Model output:", a, "^", b, "=", nn.forward(in)[0]);
  exit();
}
