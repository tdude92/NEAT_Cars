void setup() {
  Genome test = new Genome(4, 2);
  test.addNode();test.addNode();
  Genome testOffspring = new Genome(test);
  testOffspring.addConn();
  test.printGenes(true);
  println();
  testOffspring.printGenes(true);
  
  GenomeDiff diff = new GenomeDiff(test, testOffspring);
  println(diff.delta);
  
  test.writeGenome("./model/test.genome");
  testOffspring.writeGenome("./model/testOffspring.genome");
  
  Genome test2 = new Genome("./model/test.genome");
  Genome testOffspring2 = new Genome("./model/testOffspring.genome");
  
  println();
  test2.printGenes(true);
  println();
  testOffspring2.printGenes(true);
  
  GenomeDiff diff2 = new GenomeDiff(test, testOffspring);
  println(diff2.delta);
}

void draw() {}
