// Car physics implemented as described:
// https://asawicki.info/Mirror/Car%20Physics%20for%20Games/Car%20Physics%20for%20Games.html

// CAR + PHYSICS CONSTANTS
float WHEEL_RADIUS = 0.33; // m
float CAR_MASS = 500; // kg
float CAR_W = 10; // Car width
float CAR_L = 20; // Car length
float TRACTION_CONSTANT = 1.0;

// Utility
float clamp(float x, float lower, float upper) {
  // Clamp a value x between lower and upper bounds
  return min(max(x, lower), upper);
}

float slipRatio(float wheelAngularV, float vLongMagnitude) {
  return (wheelAngularV*WHEEL_RADIUS)/vLongMagnitude - 1;
}

float wheelAngularVelocity(float vLongMagnitude) {
  // Returns the angular velocity of a wheel according to longitudinal velocity
  return clamp(vLongMagnitude/WHEEL_RADIUS, 0.001, Float.MAX_VALUE); // rad/s. Clamped to a minimum of 0.001 in order to actually let the car accelerate
}

class Car {
  // In its most basic form, a Car instance is just a rectangle
  
  NeuralNet nn;
  color colour;
  
  // The car's position
  Vec2f[] vertices = new Vec2f[4]; // 4 corners of the rectangular car
  Vec2f pos; // Position of the point mass
  Vec2f dir; // Unit vector for direction
  
  // Field that describe the car's motion
  Vec2f v, a;      // Velocity and accelaration, m/s, m/s^2
  
  // Forces are all in N
  Vec2f fNet;      // Net force
  Vec2f fLong;     // Longitudinal force
  Vec2f fDrag;     // Drag force
  Vec2f fRR;       // Rolling resistance
  Vec2f fBraking;  // Force from braking
  
  Car(Vec2f pos, Vec2f dir, color colour) {
    this.pos = pos;
    this.dir = dir.direction();
    this.colour = colour;
    
    this.computeVertices();
  }
  
  void computeVertices() {} // TODO
  
  void update() {} // TODO
  
  void gas() {
    // Update forces to simulate if the driver stepped on the gas
    this.fBraking = this.fBraking.scale(0);
    
    float fLongMagnitude = TRACTION_CONSTANT*slipRatio(wheelAngularVelocity(this.v.magnitude()), this.v.magnitude());
    this.fLong = this.dir.scale(fLongMagnitude);
  }
  
  void brake() {}
  
  void draw() {
    fill(this.colour);
    quad(
      this.vertices[0].x, this.vertices[0].y,
      this.vertices[1].x, this.vertices[1].y,
      this.vertices[2].x, this.vertices[2].y,
      this.vertices[3].x, this.vertices[3].y
    );
  }
}
