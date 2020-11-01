import java.util.Random;
import java.util.LinkedList;

// Note: during mutation keep a list of all createConn and createNode mutations
//       to identify which mutations should have the same innovation number.

// Weight initialization
// The initial values of weights will be sampled from a Gaussian distribution.
float WEIGHT_INIT_MEAN   = 0.0;
float WEIGHT_INIT_STDDEV = 1.0;

// Mutation chances
float INHERITED_CONN_DISABLED_RATE = 0.75; // Chance an inherited disabled gene remains disabled.
float NEW_NODE_CHANCE        = 0.03; // Chance of mutating a new node.
float NEW_CONN_CHANCE        = 0.05; // Chance of mutating a new connection.
float WEIGHT_MUTATION_CHANCE = 0.8;  // Chance of weight mutating in offspring.
float WEIGHT_REASSIGN_CHANCE = 0.1;  // Chance of the mutation being a reassignment to a random value.
                                     // If weight will not be reassigned, perturb it slightly.
                                    
float PERTURBATION_BOUND = 0.2;      // Bounds of the random perturbation (-bound <= perturb < bound). Should be > 0.


// Utility functions
float sampleGaussian(float mean, float stddev) {
  Random r = new Random();
  return (float)(r.nextGaussian()*stddev + mean);
}


class Genome {
  /*
    Class that encodes information about the structure of a NeuralNet.
    Contains methods for inheritance, mutation, file i/o, and translation to phenotype.
  */
  
  // TODO: add an id string maybe? It would only act as a human-readable identifier.
  ArrayList<NodeGene> nodeGenes     = new ArrayList<NodeGene>(); // All node genes. Will be kept topologically ordered.
  ArrayList<NodeGene> nodeGenes_sen = new ArrayList<NodeGene>(); // Only sensors
  ArrayList<NodeGene> nodeGenes_out = new ArrayList<NodeGene>(); // Only outputs
  ArrayList<ConnGene> connGenes = new ArrayList<ConnGene>();
  float fitness = 0;
  
  /* Constructors */
  Genome(String filepath) {
    // Loads a genome from a .genome file.
    this.readGenome(filepath);
    this.linkNodes();
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
      NodeGene sensor = new NodeGene();
      sensor.id = inID;
      sensor.type = NodeType.SENSOR;
      
      this.nodeGenes_sen.add(sensor);
      this.nodeGenes.add(sensor);
    }
    for (int outID = nSensor; outID < nSensor + nOutput; ++outID) {
      // Outputs
      NodeGene output = new NodeGene();
      output.id = outID;
      output.type = NodeType.OUTPUT;
      
      this.nodeGenes_out.add(output);
      this.nodeGenes.add(output);
    }
    N_NODES = nSensor + nOutput;
    
    /* Initialize this.connGenes */
    // Iterate through each output for each input and create a connection.
    for (int inID = 0; inID < nSensor; ++inID) {
      for (int outID = 0; outID < nOutput; ++outID) {
        // Create initial ConnGenes with the appropriate correct innovation number.
        ConnGene conn = new ConnGene();
        conn.weight = sampleGaussian(WEIGHT_INIT_MEAN, WEIGHT_INIT_STDDEV);
        conn.in = inID;
        conn.out = nSensor + outID;
        conn.enable = true;
        conn.innovationN = inID*nOutput + outID;
        
        this.connGenes.add(conn);
      }
    }
    INNOVATION_N = nSensor*nOutput;
    
    //this.linkNodes();
  }
  
  Genome(Genome p1, Genome p2) {
    // Create mutated and recombined offspring.
    
    // Homologous recombination
    int i = 0, j = 0;
    while (i < p1.connGenes.size() && j < p2.connGenes.size()) {
      // Iterate through both parent genomes in parallel.
      int p1Inn = p1.connGenes.get(i).innovationN;
      int p2Inn = p2.connGenes.get(j).innovationN;

      if (p1Inn != p2Inn) {
        // The gene is disjoint if the innovation numbers do not match
        
        // Inherit the gene only if it belongs to the fitter parent.
        if (p1Inn > p2Inn) {
          // If g1Inn > g2Inn, the p2 gene at index j is disjoint.
          if (p1.fitness < p2.fitness) {
            ConnGene inheritedDisjoint = p2.connGenes.get(j);
            this.connGenes.add(new ConnGene(inheritedDisjoint));
          }
          ++j; // Check next p2 gene
        } else if (p1Inn < p2Inn) {
          // If g1Inn < g2Inn, the p1 gene at index i is disjoint.
          if (p1.fitness >= p2.fitness) {
            ConnGene inheritedDisjoint = p1.connGenes.get(i);
            this.connGenes.add(new ConnGene(inheritedDisjoint));
          }
          ++i; // Check next p1 gene
        }
      } else {
        // The genes are matching if the innovation numbers match
        
        // Randomly pick which gene to inherit
        ConnGene inheritedGene;
        int choice = round(random(0, 1));
        if (choice == 0) {
          // Inherit from p1
          inheritedGene = new ConnGene(p1.connGenes.get(i));
        } else {
          // Inherit from p2
          inheritedGene = new ConnGene(p2.connGenes.get(j));
        }
        
        if (!p1.connGenes.get(i).enable || !p2.connGenes.get(j).enable) {
          // If either of the parent genes are disabled, there's a chance
          // that the gene will stay deactivated.
          if (random(0, 1) < INHERITED_CONN_DISABLED_RATE) { // NOTE: some genes that were previous enabled in the fitter parent may be disabled.
            inheritedGene.enable = false;
          } else {
            inheritedGene.enable = true;
          }
        }
        
        this.connGenes.add(inheritedGene);
        
        // Increment both counters
        ++i;
        ++j;
      }
    }
    
    // Inherit excess genes from the fitter parent.
    while (p1.fitness < p2.fitness && j < p2.connGenes.size()) {
      ConnGene inheritedExcess = p2.connGenes.get(j);
      this.connGenes.add(new ConnGene(inheritedExcess));
      ++j;
    }
    
    while (p1.fitness >= p2.fitness && i < p1.connGenes.size()) {
      ConnGene inheritedExcess = p1.connGenes.get(i);
      this.connGenes.add(new ConnGene(inheritedExcess));
      ++i;
    }
    
    // Since only the only genes being inherited are matching genes and
    // the disjoints/excesses from the fitter parent, inherit the
    // NodeGenes of the fitter parent.
    Genome fitter = (p1.fitness < p2.fitness) ? p2 : p1;
    for (NodeGene node : fitter.nodeGenes) {
      NodeGene inheritedNode = new NodeGene(node);
      this.nodeGenes.add(inheritedNode);
      
      if (inheritedNode.type == NodeType.SENSOR) {
        this.nodeGenes_sen.add(inheritedNode);
      } else if (inheritedNode.type == NodeType.OUTPUT) {
        this.nodeGenes_out.add(inheritedNode);
      }
    }
    
    // Mutate connection weights
    for (ConnGene conn : this.connGenes) {
      if (random(0, 1) < WEIGHT_MUTATION_CHANCE) {
        conn.mutateWeight();
      }
    }
    
    // Mutate topology
    if (random(0, 1) < NEW_NODE_CHANCE) {
      this.addNode();
    }
    if (random(0, 1) < NEW_CONN_CHANCE) {
      this.addConn();
    }
    
    this.linkNodes();
  }
  
  Genome(Genome parent) {
    // Create mutated offspring from only one parent
    
    // Deep copy node gene ArrayLists
    for (NodeGene node : parent.nodeGenes) {
      NodeGene inheritedNode = new NodeGene(node);
      this.nodeGenes.add(inheritedNode);
      
      if (inheritedNode.type == NodeType.SENSOR) {
        this.nodeGenes_sen.add(inheritedNode);
      } else if (inheritedNode.type == NodeType.OUTPUT) {
        this.nodeGenes_out.add(inheritedNode);
      }
    }
    
    // Deep copy conn gene ArrayList
    for (ConnGene conn : parent.connGenes) {
      this.connGenes.add(new ConnGene(conn));
    }
    
    // Mutate connection weights
    for (ConnGene conn : this.connGenes) {
      if (random(0, 1) < WEIGHT_MUTATION_CHANCE) {
        conn.mutateWeight();
      }
    }
    
    // Mutate topology
    if (random(0, 1) < NEW_NODE_CHANCE) {
      this.addNode();
    }
    if (random(0, 1) < NEW_CONN_CHANCE) {
      this.addConn();
    }
    
    this.linkNodes();
  }
  
  void linkNodes() {
    // Iterate through each connection and update the in and out arrays of each NodeGene.
    ArrayList<NodeGene> allNodes = this.nodeGenes;
    for (ConnGene conn : this.connGenes) {
      if (!conn.enable) {continue;}
      
      int inId = conn.in, outId = conn.out;
      
      // Find NodeGene instances specified by inId and outId
      NodeGene in = null, out = null;
      int i = 0;
      while (i < allNodes.size() && (in == null || out == null)) {
        // Iterate through each NodeGene instance and check if its id matches with inId or outId
        if (allNodes.get(i).id == inId) {
          in = allNodes.get(i);
        } else if (allNodes.get(i).id == outId) {
          out = allNodes.get(i);
        }
        ++i;
      }
      
      // If in or out are null, then the genome is malformed
      if (in == null && out == null) {
        println("Error: ConnGene tried to connect " + conn.in + " and " + conn.out + ", but the input node and output node don't exist.");
        exit();
      } else if (in == null) {
        println("Error: ConnGene tried to connect " + conn.in + " and " + conn.out + ", but the input node doesn't exist.");
        exit();
      } else if (out == null) {
        println("Error: ConnGene tried to connect " + conn.in + " and " + conn.out + ", but the output node doesn't exist.");
        exit();
      } else {
        in.out.add(out);
        out.in.add(in);
      }
    }
  }
  
  void addConn() {
    // Create a new ConnGene connecting two preexisting unconnected nodes
    // While avoiding recurrent connections
    
    int senEnd = -1; // One greater than the index of the last sensor node in this.nodeGenes
    int outBeg = -1; // Index of the first output node in this.nodeGenes
    
    // Set senEnd and outBeg
    for (int i = 0; i < this.nodeGenes.size(); ++i) {
      if (this.nodeGenes.get(i).type != NodeType.SENSOR) {
        senEnd = i;
        break;
      }
    }
    for (int i = senEnd; i < this.nodeGenes.size(); ++i) {
      if (this.nodeGenes.get(i).type == NodeType.OUTPUT) {
        outBeg = i;
        break;
      }
    }
    
    // Pick an input node and output node
    NodeGene inNode, outNode;
    boolean exists; // Flag set to whether the connection already exists
    int attempts = 0; // Track number of attempts
    do {
      exists = false;
      inNode = this.nodeGenes.get(int(random(0, outBeg)));
      outNode = this.nodeGenes.get(int(random(senEnd, this.nodeGenes.size())));
      
      // Check if the connection already exists
      // TODO: Change this to compute all nonexistent connections and then pick one.
      for (ConnGene conn : this.connGenes) {
        if (conn.in == inNode.id && conn.out == outNode.id) {
          exists = true;
          break;
        }
      }
      ++attempts;
    } while (exists && attempts < 100); // Give up after 100 attempts; the network is likely fully-connected
    
    if (attempts < 100) { // If unconnected inNodes and outNodes have been found before giving up
      this.connGenes.add(new ConnGene(sampleGaussian(WEIGHT_INIT_MEAN, WEIGHT_INIT_STDDEV), inNode.id, outNode.id, true));
    }
  }
  
  void addNode() {
    // Create a new node between two connected nodes.
    ConnGene oldConn;
    do {oldConn = this.connGenes.get(int(random(0, this.connGenes.size())));} while (!oldConn.enable); // Pick a random enabled connection.
    oldConn.enable = false; // Disable old connection
    
    // Create a new node and connect it to the endpoints of oldConn.
    NodeGene newNode = new NodeGene(NodeType.HIDDEN);
    
    int nodeGenesLength = this.nodeGenes.size();
    for (int i = 0; i < nodeGenesLength; ++i) {
      if (this.nodeGenes.get(i).id == oldConn.out) {
        this.nodeGenes.add(i, newNode); // Insert the new node into the sorted ArrayList
                                        // Inserting the new node this way allows this.nodeGenes
                                        // to represent the topological order of each node.
        break;
      }
    }
    
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
    for (int i = 0; i < this.nodeGenes.size(); ++i) {
      NodeGene gene = this.nodeGenes.get(i);
      XML nodeGeneXML = nodeGeneContainer.addChild("node-gene");
      
      nodeGeneXML.setInt("order", i); // Preserve topological order
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
  
  void readGenome(String filepath) { // BIG TODO: READ TOPOLOGICAL ORDER AND REORDER this.nodeGenes IF NEEDED IN CASE AN XML IMPLEMENTATION DOES NOT PRESERVE ORDER
    // Copy data from xml into this.connGenes and this.nodeGenes
    XML root = loadXML(filepath);
    
    // Read node-gene data
    for (XML nodeGeneXML : root.getChild("node-genes").getChildren("node-gene")) {
      NodeGene nodeGene = new NodeGene();
      nodeGene.id = nodeGeneXML.getInt("id");
      nodeGene.type = NodeType.getNodeType(nodeGeneXML.getString("type"));

      // Add node gene the container corresponding to its type
      this.nodeGenes.add(nodeGene);
      if (nodeGene.type == NodeType.SENSOR) {
        this.nodeGenes_sen.add(nodeGene);
      } else if (nodeGene.type == NodeType.OUTPUT) {
        this.nodeGenes_out.add(nodeGene);
      }
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
  
  void printGenes(boolean verbose) {
    // Prints gene information to console.
    println("No. sensor:", this.nodeGenes_sen.size());
    println("No. hidden:", this.nodeGenes.size() - this.nodeGenes_sen.size() - this.nodeGenes_out.size());
    println("No. output:", this.nodeGenes_out.size());
    println("No. conns:", this.connGenes.size());
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
}
