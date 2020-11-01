import java.util.LinkedList;

class Node {
  NodeGene gene;
  float value = 0;
  float recurredValue = 0; // Doesn't get wiped when a NeuralNet calls .reset() after a forward pass
  
  // Structure of arrays that store information about outbound connections.
  ArrayList<Node> outNodes = new ArrayList<Node>();
  FloatList weights = new FloatList();
  
  Node(NodeGene gene) {
    this.gene = gene;
  }
}


class NeuralNet {
  int depth; // Used for drawing. TODO: compute with DFS?
  Activation activation; // Activation function used in the nn
  
  ArrayList<Node> input = new ArrayList<Node>();    // List of input nodes
  ArrayList<Node> output = new ArrayList<Node>();   // List of output nodes
  LinkedList<Node> active = new LinkedList<Node>(); // Queue of active nodes
  
  NeuralNet(Genome genome, Activation activation) {
    this.activation = activation;
    
    // Create the directed graph of Node instances.
    HashMap<NodeGene, Node> existingNodes = new HashMap<NodeGene, Node>(); // Track existing nodes so that the same node isn't created twice
    for (NodeGene senGene : genome.nodeGenes_sen) {
      Node newSen = new Node(senGene);
      
      this.input.add(newSen); // Add sensor node to this.inputs
      existingNodes.put(senGene, newSen);
      
      // Use connection information from the genome to create and link Node objects.
      // Traverse through the directed graph of Nodes from the current sensor Node using a queue and BFS
      LinkedList<NodeGene> qNodes = new LinkedList<NodeGene>(); // Queue of nodes to visit next
      LinkedList<Node> qInbound = new LinkedList<Node>();       // A queue parallel to qNodes that stores the inbound node for each node described in qNodes (forming a "structure of queues")
      for (NodeGene nextGene : senGene.out) {
        // Add initial values to qNodes
        qNodes.add(nextGene);
        qInbound.add(newSen);
      }
      
      while (qNodes.size() > 0) { // Actual BFS step
        NodeGene currNodeGene = qNodes.remove(); // Get queue heads
        Node inboundNode = qInbound.remove();
        
        // Get the node described by currNodeGene
        Node node;
        if ((node = existingNodes.get(currNodeGene)) == null) {
          // If the node is not in existingNodes, construct a new node
          node = new Node(currNodeGene);
          existingNodes.put(currNodeGene, node);
        }
        
        // Get the weight of the connection between the two nodes
        float weight = 0;
        for (ConnGene conn : genome.connGenes) {
          // The ConnGene describing the connection between inboundNode and node is guaranteed to exist
          // Because the link between the two NodeGenes describing inboundNode and node was created using
          // a ConnGene in genome.linkNodes()
          if (conn.in == inboundNode.gene.id && conn.out == node.gene.id) {
            weight = conn.weight;
            break;
          }
        }
        
        // Link nodes
        inboundNode.outNodes.add(node);     // Add the destination node into inboundNode.outNodes
        inboundNode.weights.append(weight); // Add the weight corresponding to this connection to inboundNode.weights
        
        for (NodeGene nextGene : currNodeGene.out) {
          // Add the next nodes we need to vist to qNodes
          // Update qInbound 
          qNodes.add(nextGene);
          qInbound.add(node);
        }
      }
    }
    
    // Add output nodes to this.output
    for (NodeGene gene : genome.nodeGenes_out) {
      this.output.add(existingNodes.get(gene)); // Output nodes have already been created and stored in existingNodes
    }
  }
  
  void forward(float[] inputs) { // inputs should not include the bias. TODO
    // Performs a forward pass on the network
    if (inputs.length != this.input.size() - 1) {
      // Input array size mismatch (subtract 1 from this.input.size() because the bias node doesn't count as an input)
      println("Input array size mismatch. Tried to input a size", inputs.length, "into a size", this.input.size(), "input layer.");
      exit();
    }
  }
  
  void reset() {} // TODO
  
  void drawNN() {} // TODO
  
  void printOutput() {
    for (Node outNode : this.output) {
      println("[" + outNode.gene.id + "]", outNode.value);
    }
  }
}
