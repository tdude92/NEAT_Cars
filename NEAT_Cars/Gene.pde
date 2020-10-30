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
  
  NodeGene() {} // Default constructor used when loading from XML.
  
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
