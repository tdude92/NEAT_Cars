void setup() {
  Genome p1 = new Genome(4, 2);//, p2 = new Genome(4, 2);
  //p1.addNode();p2.addNode();p1.addNode();p1.addNode();p2.addConn();
  p1.linkNodes(); // TODO: uncomment this.linkNodes in the constructor of Genome after done testing with neural nets.
  //Genome g = new Genome(p1, p2);
  
  p1.printGenes(true);println();
  //p2.printGenes(true);println();
  //g.printGenes(true);
  
  NeuralNet testnet = new NeuralNet(p1, new Sigmoid(4.9));
  float[] input = {1, 1, 1, 1};
  testnet.forward(input);
  testnet.printOutput();
  
  /*
  test.writeGenome("./model/test.genome");
  testOffspring.writeGenome("./model/testOffspring.genome");
  
  Genome test2 = new Genome("./model/test.genome");
  Genome testOffspring2 = new Genome("./model/testOffspring.genome");
  */
  //GenomeDiff diff = new GenomeDiff(p1, p2);
  //println(diff.nE, diff.nD, diff.delta);
}

void draw() {}
