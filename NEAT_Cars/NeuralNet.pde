import java.util.LinkedList;

// Activation functions
interface Activation {
  // Functional interface for activation function.
  float f(float x);
}


class Sigmoid implements Activation {
  float k = 1; // Horizontal compression factor.
  float f(float x) {
    return 1/(1 + exp(-this.k*x));
  }
  
  Sigmoid() {} // Default constructor
  Sigmoid(float k) {this.k = k;}
}


// Softmax function for classification tasks
float[] softmax(float[] input) {
  float[] out = new float[input.length];
  
  float sumExp = 0; // Get the sum of the elements in input after applying the exponential function
  for (int i = 0; i < input.length; ++i) {
    sumExp += exp(input[i]);
  }
  
  // Populate out
  for (int i = 0; i < input.length; ++i) {
    out[i] = exp(input[i])/sumExp;
  }
  
  return out;
}


class Node {
  // A neuron in the neural network
  // Holds a value for neuron activation and data about incoming connections
  NodeGene gene;
  float value = 0;
  
  // Structure of arrays that store information about inbound connections.
  ArrayList<Node> inNodes = new ArrayList<Node>();
  FloatList weights = new FloatList();
  
  Node(NodeGene gene) {
    this.gene = gene;
  }
}


class NeuralNet {
  int depth; // Used for drawing
  Activation activation; // Activation function used in the nn
  Genome genome; // Reference to the genome used to construct this nn
  
  ArrayList<Node> input = new ArrayList<Node>();    // List of input nodes
  ArrayList<Node> output = new ArrayList<Node>();   // List of output nodes
  ArrayList<Node> nodes = new ArrayList<Node>();   // All nodes in topological order
  
  NeuralNet(Genome genome, Activation activation) {
    this.activation = activation;
    this.genome = genome;
    
    // Create the directed graph of Node instances.
    HashMap<NodeGene, Node> existingNodes = new HashMap<NodeGene, Node>(); // Track existing nodes so that the same node isn't created twice
    for (NodeGene outGene : genome.nodeGenes_out) { // Start from the output nodes and work backwards
      Node netOutNode = new Node(outGene);
      
      this.output.add(netOutNode); // Add output node to this.output
      existingNodes.put(outGene, netOutNode);
      
      // Use connection information from the node genes to create and link Node objects.
      // Traverse through the directed graph of Nodes in reverse from the current output Node to the sensors using a queue and BFS
      LinkedList<NodeGene> qNodes = new LinkedList<NodeGene>(); // Queue of nodes to visit next
      LinkedList<Node> qDests = new LinkedList<Node>(); // Stores the output destination of each node in qNodes, forming a "structure of queues"

      for (NodeGene prevGene : outGene.in) {
        // Add initial values to qNodes
        qNodes.add(prevGene);
        qDests.add(netOutNode);
      }
      
      while (qNodes.size() > 0) { // Actual BFS step
        NodeGene currNodeGene = qNodes.remove(); // Get queue heads
        Node destNode = qDests.remove();
        
        // Get the node described by currNodeGene
        Node node;
        boolean visited = false; 
        if ((node = existingNodes.get(currNodeGene)) == null) {
          // If the node is not in existingNodes, construct a new node
          node = new Node(currNodeGene);
          existingNodes.put(currNodeGene, node);
        } else {
          // This node has been visited already
          visited = true;
        }
        
        // Get the weight of the connection between the two nodes
        float weight = 0;
        for (ConnGene conn : genome.connGenes) {
          // Find the ConnGene that created the link in the two NodeGene objects
          if (conn.in == node.gene.id && conn.out == destNode.gene.id) {
            weight = conn.weight;
            break;
          }
        }
        
        // Link nodes
        destNode.inNodes.add(node);      // Add node into destNode's list of inputs
        destNode.weights.append(weight); // Add the weight corresponding to this connection to destNode.weights
        if (visited) {continue;}
        
        for (NodeGene prevGene : currNodeGene.in) {
          // Add the next nodes we need to vist to qNodes and update qDests
          qNodes.add(prevGene);
          qDests.add(node);
        }
      }
    }
    
    // Add sensor nodes to this.input
    for (NodeGene gene : genome.nodeGenes_sen) {
      Node sensor = existingNodes.get(gene);
      this.input.add(sensor); // Sensor nodes have already been created and stored in existingNodes
    }

    this.input.get(0).value = 1.0; // Set bias value to 1.0
                                   // The bias is the node at index 0 of this.input
    
    // Add nodes to this.nodes in topologically sorted order
    for (int i = 0; i < genome.nodeGenes.size(); ++i) {
      NodeGene gene = genome.nodeGenes.get(i); // genome.nodeGenes is already topologically sorted
      this.nodes.add(existingNodes.get(gene));
    }
    
    this.depth = this.computeDepth(); // Find the number of layers in the NN
  }
  
  float[] forward(float[] inputs) {
    // Performs a forward pass on the network
    if (inputs.length != this.input.size() - 1) {
      // Input array size mismatch (subtract 1 from this.input.size() because the bias node doesn't count as an input)
      println("Input array size mismatch. Tried to input a size", inputs.length, "into a size", this.input.size() - 1, "input layer.");
      exit();
    }
    
    // Load inputs into sensor nodes
    for (int i = 0; i < inputs.length; ++i) {
      this.input.get(i + 1).value = inputs[i]; // Offset index by 1 because the bias is at index 0
    }

    // Compute each node in topological order
    for (int i = this.input.size(); i < this.nodes.size(); ++i) {
      Node node = this.nodes.get(i);
      
      node.value = 0; // Wipe previously computed value for this node
      // Compute weighted sum of the inputs to this node
      for (int j = 0; j < node.inNodes.size(); ++j) {
        Node inNode = node.inNodes.get(j);
        float weight = node.weights.get(j);
        
        node.value += weight*inNode.value;
      }
      node.value = this.activation.f(node.value); // Apply activation function
    }
    
    return this.getOutput();
  }
  
  int computeDepth() {
    // Compute the maximum depth of the neural net
    int maxDepth = Integer.MIN_VALUE;
    
    // Go through each possible path from each output node to each sensor node
    // "Structure of queues" 
    LinkedList<Node> qNode = new LinkedList<Node>(); // Stores the current position on each path
    IntList qDepth = new IntList();                  // Stores the number of steps it took to get to the current position of each path
    
    for (Node outNode : this.output) {
      // Initialize the structure of stacks
      qNode.add(outNode);
      qDepth.append(1);
    }
    
    while (qNode.size() > 0) {
      Node node = qNode.remove();
      int depth = qDepth.remove(0);
      
      if (node.gene.type == NodeType.SENSOR) {
        // Reached the end of a possible path
        if (depth > maxDepth) {
          maxDepth = depth;
        }
      } else {
        // If the node is not a sensor, haven't reached the end yet
        for (Node nextNode : node.inNodes) {
          qNode.add(nextNode);
          qDepth.append(depth + 1);
        }
      }
      
    }
    return maxDepth;
  }
  
  float[] getOutput() {
    float[] out = new float[this.output.size()];
    for (int i = 0; i < this.output.size(); ++i) {
      out[i] = this.output.get(i).value;
    }
    return out;
  }
  
  void printOutput() {
    // Print the state of the output nodes
    for (Node outNode : this.output) {
      println("[" + outNode.gene.id + "]", outNode.value);
    }
  }
  
  void printConns() {
    // Print the inputs to each node
    for (Node node : this.nodes) {
      print("{");
      for (Node inNode : node.inNodes) {
        print(str(inNode.gene.id) + " ");
      }
      println("} -> " + str(node.gene.id) + " [" + node.gene.type.str + "]");
    }
  }

  void drawNN(float x1, float y1, float x2, float y2) {
    // Args are the top left and bottom right corners of the bounding box of the drawing
    
    float nodeRadius = 10;
    
    // Colours for neuron activation
    color posColour = color(100, 255, 100);
    color negColour = color(255, 100, 100);
    
    // Hashmap that maps nodes to their x, y positions. Used for drawing connections between nodes.
    HashMap<Node, Vec2f> nodePos = new HashMap<Node, Vec2f>();
    
    // TODO: Remove depth
    
    // Sensors
    float inputDY = (y2 - y1) / (this.input.size() - 1); // Length of the space between sensor nodes (there are n-1 spaces between n nodes)
    for (int i = 0; i < this.input.size(); ++i) {
      Node node = this.input.get(i);
      
      fill(lerpColor(negColour, posColour, node.value));
      circle(x1, y1 + i*inputDY, nodeRadius);
      
      nodePos.put(node, new Vec2f(x1, y1 + i*inputDY));
    }
    
    // Outputs
    float outputDY = (y2 - y1) / (this.output.size() - 1); // Length of the space between output nodes
    for (int i = 0; i < this.output.size(); ++i) {
      Node node = this.output.get(i);
      
      fill(lerpColor(negColour, posColour, node.value));
      circle(x2, y1 + i*outputDY, nodeRadius);
      
      nodePos.put(node, new Vec2f(x2, y1 + i*outputDY));
    }
    
    // Hidden nodes and connections
    for (Node node : this.nodes) {
      if (node.gene.type != NodeType.SENSOR) { // Sensors are already drawn and have no incoming connections
        if (node.gene.type == NodeType.HIDDEN) {
          // Draw the node if it's a hidden node
          float nodeX = random(x1 + 2*nodeRadius, x2 - 2*nodeRadius); // Bounds are set so that hidden nodes won't overlap with input/output nodes
          float nodeY = random(y1 + 20, y2 - 20);

          fill(lerpColor(negColour, posColour, node.value));
          circle(nodeX, nodeY, nodeRadius);
          
          nodePos.put(node, new Vec2f(nodeX, nodeY));
          }
          
          // Draw incoming connections of the node
          for (int i = 0; i < node.inNodes.size(); ++i) {
            Node inNode = node.inNodes.get(i);
            float weight = node.weights.get(i);
            
            Vec2f inPos = nodePos.get(inNode);
            Vec2f outPos = nodePos.get(node);

            if (weight < 0.05) {
              stroke(lerpColor(negColour, posColour, 0.5));
            } else if (weight > 0) {
              stroke(posColour);
            } else if (weight < 0) {
              stroke(negColour);
            }
            line(inPos.x, inPos.y, outPos.x, outPos.y);
        }
        stroke(0); // Reset stroke to black
      }
    }
  }
}
