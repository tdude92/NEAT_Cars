import java.util.Random;


// Utility functions
float sampleGaussian(float mean, float stddev) { // Used for weight initialization
  Random r = new Random();
  return (float)(r.nextGaussian()*stddev + mean);
}


class Genome {
  /*
    Class that encodes information about the structure of a NeuralNet.
    Contains methods for inheritance, mutation, file i/o, and translation to phenotype.
  */
  
  ArrayList<NodeGene> nodeGenes     = new ArrayList<NodeGene>(); // All node genes. Will be kept topologically ordered.
  ArrayList<NodeGene> nodeGenes_sen = new ArrayList<NodeGene>(); // Only sensors
  ArrayList<NodeGene> nodeGenes_out = new ArrayList<NodeGene>(); // Only outputs
  ArrayList<ConnGene> connGenes = new ArrayList<ConnGene>();
  
  float fitness = 0;
  float rawFitness = 0; // fitness value before applying fitness sharing. Used to find best, median, worst performance
  boolean culled = false; // Set to true if this genome gets eliminated by selection
  int allocatedOffspring; // Set by Species.allocateOffspring. The number of offspring this Genome can produce
  
  // These are set if a major innovation happens during construction of this object
  // At most one node innovation and one conn innovation can happen during mutation, so no array is needed
  NodeInnovation nodeInnov = null;
  ConnInnovation connInnov = null;
  
  /* Constructors */
  Genome(String filepath) {
    // Loads a genome from a .xml file.
    this.readGenome(filepath);
    this.linkNodes();
  }
  
  Genome(int nSensor, int nOutput) {
    // Used to construct a starting population genome.
    // Encodes a neural net that fully connects inputs directly to outputs.

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
    // NOTE: Each starting genome is IDENTICAL topologically, so the ids of their nodes should be identical as well.
    // This is why the node ids are set using the value of the counter variable of the for loops
    
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
    
    this.linkNodes();
  }
  
  Genome(Genome p1, Genome p2) {
    // Create mutated and recombined offspring.
    
    // Homologous recombination
    // NOTE: ConnGenes in this.connGenes are always in order of innovation number because:
    //       1. The order of the ConnGenes in the genomes of the initial population is sorted from lowest to highest in terms of innovation number
    //       2. Newly mutated connections are added to the end of this.connGenes and are assigned a new higher innovation number
    //       3. The following loop iterates through parent genomes, which are sorted, so genes are inherited in order of innovation number
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
        
        if ((!p1.connGenes.get(i).enable) ^ (!p2.connGenes.get(j).enable)) {
          // If only one of the parent genes are disabled, the gene will be reenabled
          inheritedGene.enable = true;
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
    
    // Set senEnd
    int senEnd = -1; // One greater than the index of the last sensor node in this.nodeGenes
    for (int i = 0; i < this.nodeGenes.size(); ++i) {
      if (this.nodeGenes.get(i).type != NodeType.SENSOR) {
        senEnd = i;
        break;
      }
    }
    
    // Pick an input node and output node
    NodeGene inNode, outNode;
    boolean invalid; // Flag set to whether a link between inNode and outNode is invalid
    int attempts = 0; // Track number of attempts
    do {
      invalid = false;
      
      // Since the this.nodeGenes is topologically sorted, we can avoid creating recurrent connections
      // by choosing two indices of this.nodeGenes such that inIdx < outIdx.
      int inIdx = int(random(0, this.nodeGenes.size() - 1)); // There's no clear-cut boundary between the output nodes and hidden (hidden nodes could be topologically
                                                             // ordered after outputs) nodes in this.nodeGenes, so we can't set an upper bound to avoid picking output nodes.
                                                             
                                                             // The input node can't be the final element because the output needs to be after the input.
                                                             
      int outIdx = int(random(max(inIdx + 1, senEnd), this.nodeGenes.size())); // Clamp the lower bounds to be greater than the index of the first non-sensor node
                                                                               // Prevents the outIdx from referring to a sensor node.
      inNode = this.nodeGenes.get(inIdx);
      outNode = this.nodeGenes.get(outIdx);
      
      // Check if inIdx refers to an output node
      if (this.nodeGenes.get(inIdx).type == NodeType.OUTPUT) {invalid = true;}
      
      // Check if the connection already exists
      for (ConnGene conn : this.connGenes) {
        if (conn.in == inNode.id && conn.out == outNode.id) {
          invalid = true;
          break;
        }
      }
      ++attempts;
    } while (invalid && attempts < 100); // Give up after 100 attempts; the network is likely fully-connected
    
    if (attempts < 100) { // If unconnected inNodes and outNodes have been found before giving up
      ConnGene innovation = new ConnGene(sampleGaussian(WEIGHT_INIT_MEAN, WEIGHT_INIT_STDDEV), inNode.id, outNode.id, true);
      this.connGenes.add(innovation);
      
      // Set this.connInnov
      this.connInnov = new ConnInnovation(innovation);
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
        this.nodeGenes.add(i, newNode); // Inserting the new node to be before its output destination
                                        // ensures that topological order is maintained
        break;
      }
    }
    
    ConnGene inConn  = new ConnGene(1.0, oldConn.in, newNode.id, true);
    ConnGene outConn = new ConnGene(oldConn.weight, newNode.id, oldConn.out, true);
    
    this.connGenes.add(inConn);   // Create connection from oldConn.in to newNode
    this.connGenes.add(outConn);  // Create connection from newNode to oldConn.out
    
    // Set this.nodeInnov
    this.nodeInnov = new NodeInnovation(newNode, inConn, outConn);
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
