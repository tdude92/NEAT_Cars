// Genome comparison weights
float CW_E  = 1.0; // Weight of excess genes.
float CW_D  = 1.0; // Weight of disjoint genes.
float CW_DW = 0.4; // Weight of average weight difference of matching genes.

float COMPATABILITY_THRESHOLD = 3.0; // Maximum compatability between two genomes while still being considered the same species.

class GenomeDiff {
  /* A struct to hold data about the differences between two genomes */
  int nD, nE, n;  // no. disjoint, no. excess, size of larger genome.
  float DW;       // Average difference in weights of matching genes.
  float delta;    // Compatability distance between two genomes.
  int share;      // 1 if delta < COMPATABILITY_THRESHOLD, otherwise 0. Used for computing shared fitness.
  
  GenomeDiff(Genome g1, Genome g2) {
    // Compute differences between genomes in constructor
    
    // A gene is disjoint when it is contained in only one genome and its innovation
    // number is within the range of innovation numbers of the other genome.
    
    // A gene is excess when it is contained in only one genome and its innovation number
    // exceeds the highest innovation number in the other genome.
    
    this.nD = 0;     // no. disjoint
    this.nE = 0;     // no. excess
    int nM = 0;      // no. matching
    float sumDW = 0; // sum of weight differences.
    ArrayList<ConnGene> g1Genes = g1.connGenes;
    ArrayList<ConnGene> g2Genes = g2.connGenes;
    
    int i = 0, j = 0;
    while (i < g1Genes.size() && j < g2Genes.size()) {
      // Count disjoint genes.
      
      int g1Inn = g1Genes.get(i).innovationN;
      int g2Inn = g2Genes.get(j).innovationN;
      if (g1Inn != g2Inn) {
        // If the innovation numbers are not equal, there is a disjoint gene.
        ++this.nD;
        
        if (g1Inn > g2Inn) { // If g1Inn > g2Inn, the g2Gene at index j is disjoint.
          ++j;               // Check next g2Gene.
        }
        else {  // If g1Inn < g2Inn, the g1Gene at index i is disjoint.
          ++i;  // Check next g1Gene.
        }
      } else {
        // The ith g1Gene and jth g2Gene are matching.
        sumDW += abs(g1Genes.get(i).weight - g2Genes.get(j).weight);
        ++nM;
        
        ++i;
        ++j;
      }
    }
    
    // Count excess genes.
    // Excess genes in g1Genes.
    while (i < g1Genes.size()) {
      ++this.nE;
      ++i;
    }
    
    // Excess genes in g2Genes.
    while (j < g2Genes.size()) {
      ++this.nE;
      ++j;
    }
    
    // If there are no matching genes, return avgDW = Float.MAX_VALUE
    this.DW = Float.MAX_VALUE;
    if (nM > 0)
      this.DW = sumDW/nM;
    
    // Compute the compatability distance between two genomes.
    // Given by the formula (CW_E*nE)/N + (CW_D*nD)/N + CW_DW*DW
    float n = max(g1Genes.size(), g2Genes.size());
    this.delta = (CW_E*nE)/n + (CW_D*nD)/n + CW_DW*DW;
    
    // Set sh
    this.share = (this.delta < COMPATABILITY_THRESHOLD) ? 1 : 0;
  }
}
