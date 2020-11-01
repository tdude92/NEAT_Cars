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
