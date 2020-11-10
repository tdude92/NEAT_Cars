int N_NODES = 0;        // Global counter for number of nodes. Used to assign IDs to newly created nodes.
int INNOVATION_N = 0;   // Innovation number. Used to track gene origins.

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
  
  // ArrayLists for nodes that are linked to this instance
  // These should be initialized with the .linkNodes() in Genome
  ArrayList<NodeGene> in = new ArrayList<NodeGene>();
  ArrayList<NodeGene> out = new ArrayList<NodeGene>();
  
  NodeGene() {} // Default constructor used when loading from XML. Fields are set manually.
  
  NodeGene(NodeType type) {
    // Creates a new node with a unique id.
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
    this.enable = parent.enable;
    this.innovationN = parent.innovationN;
  }
  
  void mutateWeight() {
    this.weight += random(-PERTURBATION_BOUND, PERTURBATION_BOUND);
  }
}


/* Classes used to compare innovations                           */
/* So that we can identify duplicate innovations in a generation */

class NodeInnovation {
  int in, out;                                  // The ids of the nodes whose connection gets split by the new node
  NodeGene nodeInnovation;                      // The mutated NodeGene instance
  ConnGene inConnInnovation, outConnInnovation; // The mutated ConnGene instances
  
  NodeInnovation(NodeGene nodeInnovation, ConnGene inConnInnovation, ConnGene outConnInnovation) {
    this.nodeInnovation = nodeInnovation;
    this.inConnInnovation = inConnInnovation;
    this.outConnInnovation = outConnInnovation;
    this.in = inConnInnovation.in;
    this.out = outConnInnovation.out;
  }
  
  boolean equals(NodeInnovation other) {
    // Checks if two innovations are identical
    if (other.in == this.in && other.out == this.out)
      return true;
    else
      return false;
  }
}

class ConnInnovation {
  int in, out; // Node IDs of the input and output nodes
  ConnGene innovation;
  
  ConnInnovation(ConnGene innovation) {
    this.innovation = innovation;
    this.in = innovation.in;
    this.out = innovation.out;
  }
  
  boolean equals(ConnInnovation other) {
    // Check if the input and destination of the connections are the same
    if (other.in == this.in && other.out == this.out)
      return true;
    else
      return false;
  }
}
