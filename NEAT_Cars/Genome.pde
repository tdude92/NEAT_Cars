import java.util.Random;

// Note: during mutation keep a list of all createConn and createNode mutations
//       to identify which mutations should have the same innovation number.

// Weight initialization
// The initial values of weights will be sampled from a Gaussian distribution.
float WEIGHT_INIT_MEAN   = 0.0;
float WEIGHT_INIT_STDDEV = 1.0;

float COMPATABILITY_THRESHOLD = 3.0; // Maximum compatability between two genomes while still being considered the same species.

// Mutation chances
float WEIGHT_MUTATION_CHANCE = 0.8;  // Chance of weight mutating in offspring.
float WEIGHT_REASSIGN_CHANCE = 0.1;  // Chance of the mutation being a reassignment to a random value.
                                     // If weight will not be reassigned, perturb it slightly.
                                    
float PERTURBATION_BOUND = 0.2;      // Bounds of the random perturbation (-bound <= perturb < bound). Should be > 0.

// Genome comparison weights
float CW_E  = 1.0; // Weight of excess genes.
float CW_D  = 1.0; // Weight of disjoint genes.
float CW_DW = 0.4; // Weight of average weight difference of matching genes.

int N_NODES = 0;        // Global counter for number of nodes. Used to assign IDs to newly created nodes.
int INNOVATION_N = 0; // Innovation number. Used to track gene origins.


// Utility functions
float sampleGaussian(float mean, float stddev) {
  Random r = new Random();
  return (float)(r.nextGaussian()*stddev + mean);
}


enum NodeType {
  SENSOR("sen"),
  HIDDEN("hid"),
  OUTPUT("out");
  
  final String str; // String abbreviation
  private NodeType(String str) {this.str = str;}
  
  static NodeType getNodeType(String str) {
    // Get NodeType from string abbreviation
    for (NodeType type : NodeType.values()) {
      if (type.str.equals(str))
        return type;
    }
    return null;
  }
};


class NodeGene {
  /* Stores information about a node in an ANN. */
  NodeType type;    // Sensor, Hidden, Output
  int id;           // Identifier for nodes in ConnGenes
  
  NodeGene() {} // Default constructor used when loading from XML.
  
  NodeGene(NodeType type) {
    // Creates a novel node and assigns it a unique id.
    this.type = type;
    this.id = N_NODES++;
  }
  
  NodeGene(NodeGene parent) {
    // Creates an inherited node.
    // An inherited node is just a clone of the parent.
    this.type = parent.type;
    this.id = parent.id;
  }
}


class ConnGene {
  /* Stores information about a connection between nodes in the ANN. */
  int in, out;
  float weight;
  boolean enable; // Connections are disabled when a mutation creates a node between in and out.
  int innovationN;
  
  ConnGene() {} // Default constructor used when loading from XML.
  
  ConnGene(float weight, int in, int out, boolean enable) {
    // Constructor used for a new innovation.
    this.in = in;
    this.out = out;
    this.weight = weight;
    this.enable = enable;
    this.innovationN = INNOVATION_N++;
  }
  
  ConnGene(ConnGene parent) {
    // Constructs a copy of a parent gene.
    this.in = parent.in;
    this.out = parent.out;
    this.weight = parent.weight;
    this.enable = parent.enable; // TODO: chance to reenable
    this.innovationN = parent.innovationN;
  }
  
  void mutateWeight() {
    if (random(0, 1) < WEIGHT_REASSIGN_CHANCE) {
      // TODO
      // Maybe leave unimplemented.
    } else {
      this.weight += random(-PERTURBATION_BOUND, PERTURBATION_BOUND);
    }
  }
}


class Genome {
  /*
    Class that encodes information about the structure of a NeuralNet.
    Contains methods for inheritance, mutation, file i/o, and translation to phenotype.
  */
  
  // TODO: add an id string maybe? It would only act as a human-readable identifier.
  ArrayList<NodeGene> nodeGenes = new ArrayList<NodeGene>(); // TODO: separate sen, hid, out.
  ArrayList<ConnGene> connGenes = new ArrayList<ConnGene>();
  
  /* Constructors */
  Genome(String filepath) {
    // Loads a genome from a .genome file.
    this.readGenome(filepath);
  }
  
  Genome(int nSensor, int nOutput) {
    // Used to construct a starting population genome.
    // Encodes a neural net that connects inputs directly to outputs.

    // Add a bias to the sensor nodes.
    // A bias is a sensor node set to a constant value of 1.
    nSensor++;
    
    /* Initialize this.nodeGenes */
    for (int inID = 0; inID < nSensor; ++inID) {
      // Sensors
      this.nodeGenes.add(new NodeGene(NodeType.SENSOR));
    }
    for (int outID = 0; outID < nOutput; ++outID) {
      // Outputs
      this.nodeGenes.add(new NodeGene(NodeType.OUTPUT));
    }
    
    /* Initialize this.connGenes */
    // Iterate through each output for each input and create a connection.
    for (int inID = 0; inID < nSensor; ++inID) {
      for (int outID = nSensor; outID < nSensor + nOutput; ++outID) {
        this.connGenes.add(new ConnGene(sampleGaussian(WEIGHT_INIT_MEAN, WEIGHT_INIT_STDDEV), inID, outID, true));
      }
    }
  }
  
  Genome(Genome parent1, Genome parent2) { // TODO
    // Create mutated and recombined offspring.
  }
  
  Genome(Genome parent) {
    // Create mutated offspring from only one parent.
    
    /* Copy parent genes */
    for (NodeGene node : parent.nodeGenes) {
      this.nodeGenes.add(new NodeGene(node));
    }
    for (ConnGene conn : parent.connGenes) {
      this.connGenes.add(new ConnGene(conn));
    }
    
    /* Mutate genes */
    for (ConnGene conn : this.connGenes) {
      if (random(0, 1) < WEIGHT_MUTATION_CHANCE) {
        conn.mutateWeight();
      }
    }
  }
  
  void addConn(int nodeInId, int nodeOutId) {
    // Create a new ConnGene connecting two preexisting unconnected nodes.
    this.connGenes.add(new ConnGene(sampleGaussian(WEIGHT_INIT_MEAN, WEIGHT_INIT_STDDEV), nodeInId, nodeOutId, true));
  }
  
  void addNode() {
    // Create a new node between two connected nodes.
    ConnGene oldConn;
    do {oldConn = this.connGenes.get(int(random(0, this.connGenes.size())));} while (!oldConn.enable); // Pick a random enabled connection.
    oldConn.enable = false; // Disable old connection
    
    // Create a new node and connect it to the endpoints of oldConn.
    NodeGene newNode = new NodeGene(NodeType.HIDDEN);
    this.nodeGenes.add(newNode);
    this.connGenes.add(new ConnGene(1.0, oldConn.in, newNode.id, true));              // Create connection from oldConn.in to newNode
    this.connGenes.add(new ConnGene(oldConn.weight, newNode.id, oldConn.out, true));  // Create connection from newNode to oldConn.out
  }
  
  /* I/O functions for reading/writing objects */
  void writeGenome(String filepath) {
    // Write genome to an xml file.
    XML root = parseXML("<genome></genome>");
    root.addChild("node-genes"); // Container for NodeGene
    root.addChild("conn-genes"); // Container for ConnGene
    
    // Write nodeGenes to the XML object.
    XML nodeGeneContainer = root.getChild("node-genes");
    for (NodeGene gene : this.nodeGenes) {
      XML nodeGeneXML = nodeGeneContainer.addChild("node-gene");
      
      nodeGeneXML.setInt("id", gene.id);
      nodeGeneXML.setString("type", gene.type.str);
    }
    
    // Write connGenes to the XML object.
    XML connGeneContainer = root.getChild("conn-genes");
    for (ConnGene gene : this.connGenes) {
      XML connGeneXML = connGeneContainer.addChild("conn-gene");
      
      connGeneXML.setInt("innovation", gene.innovationN);
      connGeneXML.setInt("in", gene.in);
      connGeneXML.setInt("out", gene.out);
      connGeneXML.setInt("enable", gene.enable ? 1 : 0);
      connGeneXML.setFloat("weight", gene.weight);
    }
    
    saveXML(root, filepath);
  }
  
  void readGenome(String filepath) {
    // Copy data from xml into this.connGenes and this.nodeGenes
    XML root = loadXML(filepath);
    
    // Read node-gene data
    for (XML nodeGeneXML : root.getChild("node-genes").getChildren("node-gene")) {
      NodeGene nodeGene = new NodeGene();
      nodeGene.id = nodeGeneXML.getInt("id");
      nodeGene.type = NodeType.getNodeType(nodeGeneXML.getString("type"));

      this.nodeGenes.add(nodeGene);
    }
    
    // Read conn-gene data
    for (XML connGeneXML : root.getChild("conn-genes").getChildren("conn-gene")) {
      ConnGene connGene = new ConnGene();
      connGene.innovationN = connGeneXML.getInt("innovation");
      connGene.in = connGeneXML.getInt("in");
      connGene.out = connGeneXML.getInt("out");
      connGene.enable = (connGeneXML.getInt("enable") == 1) ? true : false;
      connGene.weight = connGeneXML.getFloat("weight");
      
      this.connGenes.add(connGene);
    }
  }
  
  NeuralNet contructNeuralNet() {return null;} // TODO
  
  void printGenes(boolean verbose) {
    // Prints gene information to console.
    println("No. sensor: " + this.getNSensor());
    println("No. hidden: " + this.getNHidden());
    println("No. output: " + this.getNOutput());
    println("No. conns: " + this.connGenes.size());
    if (verbose) {
      print("Nodes: ");
      for (NodeGene node : this.nodeGenes)
        print(node.type.str + "(" + str(node.id) + ") "); // Print the node type and id.
      println();
      println("Connections: ");
      for (ConnGene conn : this.connGenes) {
          String enableStr = (conn.enable) ? "on" : "off";
          String weightStr = (conn.weight < 0) ? str(conn.weight) : " " + str(conn.weight);
          println("[innov: " + str(conn.innovationN) + ", " + enableStr + "]\t" + str(conn.in) + " -> " + str(conn.out) + ",\tw: "  + weightStr);
      }
    }
  }
  
  int getNSensor() {
    int count = 0;
    for (NodeGene node : this.nodeGenes)
      if (node.type == NodeType.SENSOR)
        count++;
    return count;
  }
  int getNHidden() {
    int count = 0;
    for (NodeGene node : this.nodeGenes)
      if (node.type == NodeType.HIDDEN)
        count++;
    return count;
  }
  int getNOutput() {
    int count = 0;
    for (NodeGene node : this.nodeGenes)
      if (node.type == NodeType.OUTPUT)
        count++;
    return count;
  }
}


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
        
        if (g1Inn > g2Inn) { // If g1Inn > g2Inn, the jth g2Gene is disjoint.
          ++j;               // Check next g2Gene.
        }
        else {  // If g1Inn < g2Inn, the ith g1Gene is disjoint.
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
    if (i < g1Genes.size()) {
      // Excess genes in g1Genes.
      while (i < g1Genes.size()) {
        ++this.nE;
        ++i;
      }
      
    } else if (j < g2Genes.size()) {
      // Excess genes in g2Genes.
      while (j < g2Genes.size()) {
        ++this.nE;
        ++j;
      }
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
