// Note: during mutation keep a list of all createConn and createNode mutations
//       to identify which mutations should have the same innovation number.

class Evaluator {
  int generation = 0;
  Genome bestGenome, medianGenome, worstGenome;
  ArrayList<Species> species = new ArrayList<Species>();
  Activation activation;
  
  // Structure of arrays to store genomes and their nns
  Genome[] genomes;
  NeuralNet[] neuralNets;
  
  Evaluator(int population, Activation activation) {
    this.genomes = new Genome[population];
    this.neuralNets = new NeuralNet[population];
    this.activation = activation;
  }
  
  void initPopulation(int nInput, int nOutput) {
    // Randomly generate a population of genomes with nInput sensors and nOutput outputs
    for (int i = 0; i < this.genomes.length; ++i) {
      this.genomes[i] = new Genome(nInput, nOutput);
    }
    this.constructNeuralNets();
  }
  
  void updatePopulation() {
    // Updates the population after raw fitnesses have been assigned to each genome
    // The population gets updated to the next generation, the fields get updated to the
    // current generation.
    this.updateSpecies();
    this.computeSharedFitness();
    
    this.genomes = this.mergeSortGenomes(this.genomes, 0, this.genomes.length - 1);
    this.bestGenome = this.genomes[0];
    this.medianGenome = this.genomes[this.genomes.length/2]; // If the array has an even number of elements, just take one Genome on either 
                                                             // side of the center (We can't find the average of two genomes)
    this.worstGenome = this.genomes[this.genomes.length - 1];
    
    this.cullPopulation();
    this.allocateOffspring();
    this.constructOffspring();
    this.constructNeuralNets(); // Create neural nets for each of the offspring genomes
    
    this.generation++;
  }
  
  void updateSpecies() {
    // Updates the Species instances in the population according to measured fitness data
    
    // Reset each species object
    for (Species species : this.species) {
      species.wipe();
    }
    
    // Organizes each genome into species
    for (Genome genome : this.genomes) {
      // Assign to the first species where the representative and this
      // genome have a compatability distance that is less than the
      // compatability threshold.
      boolean speciesFound = false;
      for (Species species : this.species) {
        GenomeDiff diff = new GenomeDiff(genome, species.repr());
        if (diff.delta < COMPATABILITY_THRESHOLD) {
          speciesFound = true;
          species.addGenome(genome);
        }
      }
      
      if (!speciesFound) {
        // If no compatible species is found, create a new one
        this.species.add(new Species(genome));
      }
    }
    
    // Remove extinct species from the list
    ArrayList<Species> extinct = new ArrayList<Species>();
    for (Species species : this.species) {
      // Find extinct species
      if (species.wiped == true) { // If species.wiped is still true, no new genomes have been added
        extinct.add(species);
      }
    }
    for (Species extinctSpecies : extinct) {
      // remove extinct species from this.species
      this.species.remove(extinctSpecies);
    }
  }
  
  void computeSharedFitness() {
    // Computes the shared fitness of each genome
    // The shared fitness of a genome is just its fitness divided by
    // The population of the species it belongs to
    for (Species species : this.species) {
      for (Genome genome : species.genomes) {
        genome.fitness /= species.population();
      }
    }
  }
  
  void cullPopulation() {
    // Prevent the least fit individuals from reproducing
    // Assumes that this.genomes is already sorted
    int n_cull = int(this.genomes.length*CULL_PERCENT);
    for (int i = this.genomes.length - 1; i >= this.genomes.length - n_cull; --i) {
      this.genomes[i].culled = true; // RIP :(
    }
  }
  
  void allocateOffspring() {
    // Set the number of offspring each species is allowed to produce
    
    float totalFitness = 0; // Sum of the (shared) fitness of all alive genomes
    for (Genome genome : this.genomes) {
      if (!genome.culled)
        totalFitness += genome.fitness;
    }
    
    // Allocate offspring for each species
    int allocated = 0;
    for (Species species : this.species) {
      species.speciesFitness = 0;
      // Calculate speciesFitness
      for (Genome genome : species.genomes) {
        if (!genome.culled)
          species.speciesFitness += genome.fitness;
      }
      
      species.allocatedOffspring = round(this.genomes.length*(species.speciesFitness/totalFitness));
      allocated += species.allocatedOffspring;
    }
    
    // Due to imprecision, the number of allocated offspring may not equal the set population of the simulation
    if (this.genomes.length < allocated) {
      // Find a species that is not extinct and has been allocatedOffspring
      int error = allocated - this.genomes.length;
      for (Species species : this.species) {
        if (species.speciesFitness > 0 && species.allocatedOffspring > error) { // species.speciesFitness == 0 ==> all genomes of species were culled
          species.allocatedOffspring -= error;
        }
      }
    } else if (this.genomes.length > allocated) {
      // Find a species that is not extinct
      int error = this.genomes.length - allocated;
      for (Species species : this.species) {
        if (species.speciesFitness > 0) {
          species.allocatedOffspring += error;
        }
      }
    }
  }
  
  void constructOffspring() {
    // TODO keep track of duplicate innovations btw
  }
  
  void constructNeuralNets() {
    // Constructs a neural net for each genome
    for (int i = 0; i < this.genomes.length; ++i)
      this.neuralNets[i] = new NeuralNet(this.genomes[i], this.activation);
  }
  
  Genome[] mergeSortGenomes(Genome[] arr, int start, int end) {
    // Returns a sorted array of genomes from most to least fit
    if (start == end) {
      // Base case, array of length 1
      Genome out[] = {arr[start]};
      return out;
    } else {
      // Recursive case, split into left and right subarrays
      int mid = (start + end)/2;
      Genome[] left = this.mergeSortGenomes(arr, start, mid);
      Genome[] right = this.mergeSortGenomes(arr, mid + 1, end);
      return this.mergeGenomes(left, right);
    }
  }
  
  Genome[] mergeGenomes(Genome[] left, Genome[] right) {
    // Merge step for this.mergeSortGenomes
    Genome[] mergedArr = new Genome[left.length + right.length];
    
    int i = 0, j = 0, k = 0;
    while (i < left.length && j < right.length) {
      if (left[i].fitness < right[j].fitness) {
        mergedArr[k] = right[j];
        ++j;
      } else {
        mergedArr[k] = left[i];
        ++i;
      }
      ++k;
    }
    
    // When subarray runs out of values, place the remaining values
    // in the subarray into mergedArr in order
    if (i == left.length) {
      for (; j < right.length; ++j) {
        mergedArr[k] = right[j];
        ++k;
      }
    } else if (j == right.length) {
      for (; i < left.length; ++i) {
        mergedArr[k] = left[i];
        ++k;
      }
    }
    
    return mergedArr;
  }
  
  NeuralNet[] getNeuralNets() {
    return neuralNets;
  }
  
  void printGeneration() {
    for (int i = 0; i < this.genomes.length; ++i) {
      println("Individual ", i);
      this.genomes[i].printGenes(false);
      this.neuralNets[i].printConns();
      println();
    }
  }
}
