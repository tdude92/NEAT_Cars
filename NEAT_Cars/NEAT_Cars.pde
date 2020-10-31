void setup() {
  Genome p1 = new Genome(4, 2), p2 = new Genome(4, 2);
  p1.addNode();p2.addNode();p1.addNode();p1.addNode();p2.addConn();
  Genome g = new Genome(p1, p2);
  
  p1.printGenes(true);println();
  p2.printGenes(true);println();
  g.printGenes(true);
  
  /*
  test.writeGenome("./model/test.genome");
  testOffspring.writeGenome("./model/testOffspring.genome");
  
  Genome test2 = new Genome("./model/test.genome");
  Genome testOffspring2 = new Genome("./model/testOffspring.genome");
  */
  GenomeDiff diff = new GenomeDiff(p1, p2);
  println(diff.nE, diff.nD, diff.delta);
}

void draw() {}
