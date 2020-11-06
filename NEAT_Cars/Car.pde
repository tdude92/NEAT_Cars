// Car physics implemented as described:
// https://asawicki.info/Mirror/Car%20Physics%20for%20Games/Car%20Physics%20for%20Games.html

// Note: in this simulation, 5 pixels = 1 meter

// CAR + PHYSICS CONSTANTS
float CAR_MASS = 500; // kg
float CAR_W = 10; // Car width
float CAR_L = 20; // Car length

// Adjust these to adjust car physics
float TRACTIVE_FORCE = 5000; // N
float DRAG_CONSTANT = 0.4257;
float RR_CONSTANT = DRAG_CONSTANT*30;
float BRAKING_CONSTANT = 5000;

// Utility
float clamp(float x, float lower, float upper) {
  // Clamp a value x between lower and upper bounds
  return min(max(x, lower), upper);
}

class Car {
  // In its most basic form, a Car instance is just a rectangle
  
  NeuralNet nn;
  color colour;
  
  // The car's position
  Vec2f[] vertices = new Vec2f[4]; // {front left, front right, rear right, rear left}
  Vec2f pos; // Position of the point mass
  Vec2f dir; // Unit vector for direction
  
  // Field that describe the car's motion
  Vec2f v = new Vec2f(0, 0), a = new Vec2f(0, 0);      // Velocity and accelaration, m/s, m/s^2
  
  // Forces are all in N
  Vec2f fNet; // Net force
  Vec2f fTraction = new Vec2f(0, 0); // Traction force
  Vec2f fDrag = new Vec2f(0, 0);     // Drag force
  Vec2f fRR = new Vec2f(0, 0);       // Rolling resistance
  Vec2f fBraking = new Vec2f(0, 0);  // Force from braking
  
  Car(Vec2f pos, Vec2f dir, color colour) {
    this.pos = pos;
    this.dir = dir.direction();
    this.colour = colour;
    
    this.computeVertices();
  }
  
  void computeVertices() {
    this.vertices[0] = this.pos.add(this.dir.scale(CAR_L/2)).add(this.dir.perpendicular(false).scale(CAR_W/2));  // Front left
    this.vertices[1] = this.pos.add(this.dir.scale(CAR_L/2)).add(this.dir.perpendicular(true).scale(CAR_W/2));   // Front right
    this.vertices[2] = this.pos.add(this.dir.scale(-CAR_L/2)).add(this.dir.perpendicular(true).scale(CAR_W/2));  // Rear right
    this.vertices[3] = this.pos.add(this.dir.scale(-CAR_L/2)).add(this.dir.perpendicular(false).scale(CAR_W/2)); // Rear left
  }
  
  void update() {
    // Compute resistive forces
    this.fDrag = this.v.scale(-DRAG_CONSTANT*this.v.magnitude());
    this.fRR   = this.v.scale(-RR_CONSTANT);
    
    // Set velocity and braking force to null vectors when velocity is below some value
    // To stop the braking force from making the car go backwards.
    if (this.v.magnitude() < 5 && this.fBraking.magnitude() > 0) {
      this.v = new Vec2f(0, 0);
      this.fBraking = new Vec2f(0, 0);
    }
    
    // Compute Fnet
    this.fNet = new Vec2f(0, 0).add(this.fTraction).add(this.fDrag).add(this.fRR).add(this.fBraking);
    
    // Compute acceleration, velocity, and position
    // Acceleration is obtained from Newton's Second law
    // Velocity and position are obtained by numerical integration
    this.a = this.fNet.scale(1/CAR_MASS); // Using a = Fnet/m
    this.v = this.v.add(this.a.scale(5*DT)); // v = v + dt*a
    this.pos = this.pos.add(this.v.scale(5*DT)); // p = p + dt*v (multiply by 5 to convert from m to pixels)
    
    this.computeVertices();
    this.draw();
  }
  
  
  void gas() {
    // Update forces to simulate if the driver stepped on the gas
    this.fBraking = new Vec2f(0, 0);
    this.fTraction = this.dir.scale(TRACTIVE_FORCE);
  }
  void cruise() {
    // Update forces to simulate if the driver did nothing
    this.fBraking = new Vec2f(0, 0);
    this.fTraction = new Vec2f(0, 0);
  }
  void brake() {
    // Update forces to simulate if the driver stepped on the brakes
    this.fBraking = this.dir.scale(-BRAKING_CONSTANT);
    this.fTraction = new Vec2f(0, 0);
  }
  
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
