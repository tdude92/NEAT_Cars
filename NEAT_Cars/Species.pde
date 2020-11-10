class Species {
  String id;
  color colour;
  boolean wiped; // True if the species was reset
                 // Returns to false if a genome is added during Evaluator.updateSpecies()
  ArrayList<Genome> genomes = new ArrayList<Genome>();
  float speciesFitness; // Sum of the fitnesses of all genomes
  int allocatedOffspring;
  
  Species(Genome repr) {
    this.wiped = false;
    this.genomes.add(repr); // The species representative is the genome at index 0
    this.colour = color(random(255), random(255), random(255));
    
    int nHidden = repr.nodeGenes.size() - repr.nodeGenes_sen.size() - repr.nodeGenes_out.size();
    this.id = "S_S" + str(repr.nodeGenes_sen.size()) + "H" + str(nHidden) + "O" + str(repr.nodeGenes_out.size()) + "C" + str(repr.connGenes.size());
  }
  
  void wipe() {
    // Wipes this.genomes of all values except te representative
    this.genomes.subList(1, this.genomes.size()).clear();
    
    this.wiped = true;
    // The representative of each species will be reassigned
    // to the first genome that is added to this species
  }
  
  void addGenome(Genome genome) {
    // Adds a genome to this.genomes
    if (this.wiped == true) {
      // Replaces the representative genome with the new genome
      // if the species has been wiped.
      this.genomes.set(0, genome);
      this.wiped = false;
    } else {
      this.genomes.add(genome);
    }
  }
  
  void allocateOffspring() {
    // Allocates a number of offspring to each individual
    // Can only be called after this.allocatedOffspring and this.speciesFitness is set

    // Performs the same kind of computation as Evaluator.allocateOffspring()
    int allocated = 0;
    for (Genome genome : this.genomes) {
      if (!genome.culled) { // Only alive genomes can reproduce
        // This computation is imprecise since we're rounding
        genome.allocatedOffspring = round(this.allocatedOffspring*(genome.fitness/this.speciesFitness));
        allocated += genome.allocatedOffspring;
        
        if (allocated == this.allocatedOffspring) {
          // All spaces in this.genomes have been allocated
          break;
        } else if (allocated > this.allocatedOffspring) {
          // Overallocated. Subtract the overflow from this species' allocatedOffspring variable
          int error = allocated - this.allocatedOffspring;
          genome.allocatedOffspring -= error;
          allocated -= error;
          break;
        }
      }
    }
    
    while (!this.culled() && allocated < this.allocatedOffspring) {
      // Underallocated. Distribute additional free spaces randomly
      Genome genome = this.genomes.get(int(random(0, this.genomes.size()))); // Pick a random genome
      if (!genome.culled) {
        genome.allocatedOffspring++;
        allocated++;
      }
    }
  }
  
  int population() {
    return this.genomes.size();
  }
  
  Genome repr() {
    // Returns the representative genome
    return this.genomes.get(0);
  }
  
  boolean culled() {
    for (Genome genome : this.genomes) {
      if (!genome.culled) {
        return false;
      }
    }
    return true;
  }
  
  ArrayList<Genome> getAliveGenomesExcluding(Genome exclusion) {
    // Used for finding a mating partner for a genome
    ArrayList<Genome> output = new ArrayList<Genome>();
    for (Genome genome : this.genomes) {
      if (!genome.culled && genome != exclusion) {
        output.add(genome);
      }
    }
    return output;
  }
}
