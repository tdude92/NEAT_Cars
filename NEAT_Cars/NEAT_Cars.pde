void setup() {
  Genome p1 = new Genome(4, 2);//, p2;
  p1.addNode();p1.addNode();p1.addNode();
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
  
  
  //p1.writeGenome("./model/test.genome");
  //p2 = new Genome("./model/test.genome");
  //p2.printGenes(true);
}

void draw() {}
