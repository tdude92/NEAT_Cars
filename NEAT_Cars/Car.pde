// Car acceleration physics implemented as described:
// https://asawicki.info/Mirror/Car%20Physics%20for%20Games/Car%20Physics%20for%20Games.html

// Note: in this simulation, 5 pixels = 1 meter

// CAR CONSTANTS
float CAR_MASS = 500; // kg
float CAR_W = 10; // Car width
float CAR_L = 20; // Car length
float STEERING_ANGLE = 3*PI/8; // Radians
float VISION_RANGE = 200; // pixels

// Adjust these to adjust car physics
float TRACTIVE_FORCE = 8000; // N
float DRAG_CONSTANT = 0.4257f;
float RR_CONSTANT = DRAG_CONSTANT*30; // Rolling resistance
float BRAKING_CONSTANT = 5000;
float LATV_DECAY = 0.90;

// Utility
public float clamp(float x, float lower, float upper) {
  // Clamp a value x between lower and upper bounds
  return min(max(x, lower), upper);
}

class Car {
  // In its most basic form, a Car instance is just a rectangle
  
  Course course; // Course object so that we can access walls and checkpoints
  
  NeuralNet nn;
  boolean crashedFlag = false;
  int colour;
  
  // Holds the distance from each wall
  float[] wallDistances = new float[5]; // {0deg, -45deg, -90deg, 90deg, 45deg} if 0 deg is straight ahead and the angle increases counterclockwise
  
  // The car's position
  Vec2f[] vertices = new Vec2f[4]; // {front left, front right, rear right, rear left}
  Vec2f pos; // Position of the point mass
  Vec2f dir; // Unit vector for direction
  
  // Fields that describe the car's motion
  Vec2f v = new Vec2f(0, 0), a = new Vec2f(0, 0); // Velocity and accelaration, m/s, m/s^2
  float steeringAngle = 0; // Angle between the front wheels direction and this.dir
  
  // Forces are all in N
  Vec2f fNet; // Net force
  Vec2f fTraction = new Vec2f(0, 0);    // Traction force
  Vec2f fDrag = new Vec2f(0, 0);        // Drag force
  Vec2f fRR = new Vec2f(0, 0);          // Rolling resistance
  Vec2f fBraking = new Vec2f(0, 0);     // Force from braking
  
  Car(Vec2f pos, Vec2f dir, Course course, int colour) {
    this.pos = pos;
    this.dir = dir.direction();
    this.course = course;
    this.colour = colour;
    
    this.computeVertices();
  }
  
  void setNN(NeuralNet nn) {
    this.nn = nn;
  }
  
  void computeVertices() {
    this.vertices[0] = this.pos.add(this.dir.scale(CAR_L/2)).add(this.dir.perpendicular(false).scale(CAR_W/2));  // Front left
    this.vertices[1] = this.pos.add(this.dir.scale(CAR_L/2)).add(this.dir.perpendicular(true).scale(CAR_W/2));   // Front right
    this.vertices[2] = this.pos.add(this.dir.scale(-CAR_L/2)).add(this.dir.perpendicular(true).scale(CAR_W/2));  // Rear right
    this.vertices[3] = this.pos.add(this.dir.scale(-CAR_L/2)).add(this.dir.perpendicular(false).scale(CAR_W/2)); // Rear left
  }
  
  void update() {
    this.fNet = new Vec2f(0, 0);
    
    this.scanWalls(); // Get distance from walls
    this.performAction(); // Perform an action from the nn
    
    // Steering
    if (this.steeringAngle != 0) {
      float turnRadius = CAR_L / sin(this.steeringAngle);
      float av = this.v.magnitude() / turnRadius; // angular velocity
      this.dir = this.dir.rotate(av*DT);
    }
    
    // Decay lateral velocity of the car (DRIFTING)
    Vec2f vRefDir = this.v.rotate(-this.dir.angle()); // Velocity vector in the reference frame of this.dir
    vRefDir.y *= LATV_DECAY;
    this.v = vRefDir.rotate(this.dir.angle()); // Set velocity to vRefDir after moving it back to world reference frame
    
    // Compute drag and rolling resistance
    this.fDrag = this.v.scale(-DRAG_CONSTANT*this.v.magnitude());
    this.fRR   = this.v.scale(-RR_CONSTANT);
    
    // Set velocity and braking force to null vectors when velocity is below some value
    // To stop the braking force from making the car go backwards.
    if (this.v.magnitude() < 5 && this.fBraking.magnitude() > 0) {
      this.v = new Vec2f(0, 0);
      this.fBraking = new Vec2f(0, 0);
    }
    
    // Compute Fnet
    this.fNet = this.fNet.add(this.fTraction).add(this.fDrag).add(this.fRR).add(this.fBraking);
    
    // Compute acceleration, velocity, and position
    // Acceleration is obtained from Newton's Second law
    // Velocity and position are obtained by numerical integration
    this.a = this.fNet.scale(1/CAR_MASS); // Using a = Fnet/m
    this.v = this.v.add(this.a.scale(5*DT)); // v = v + dt*a
    this.pos = this.pos.add(this.v.scale(5*DT)); // p = p + dt*v (multiply by 5 to convert from m to pixels)
    
    // Normalize dir so that imprecisions from calculations don't accumulate
    this.dir = this.dir.direction();
    
    this.computeVertices();
    
    // Check for collisions with walls
    for (LineSegment wall : this.course.walls) {
      if (this.crashed(wall)) {
        this.crashedFlag = true;
      }
    }
    
    this.draw();
  }
  
  void scanWalls() {
    LineSegment[] visionLines = {
      new LineSegment(this.pos, this.pos.add(this.dir.scale(VISION_RANGE))),
      new LineSegment(this.pos, this.pos.add(this.dir.rotate(PI/4).scale(VISION_RANGE))),
      new LineSegment(this.pos, this.pos.add(this.dir.rotate(PI/2).scale(VISION_RANGE))),
      new LineSegment(this.pos, this.pos.add(this.dir.rotate(-PI/2).scale(VISION_RANGE))),
      new LineSegment(this.pos, this.pos.add(this.dir.rotate(-PI/4).scale(VISION_RANGE)))
    };
    
    // Iterate through each vision line and find the nearest intersection with a wall, if any.
    // Then set this.wallDistances
    for (int i = 0; i < visionLines.length; ++i) {
      LineSegment visionLine = visionLines[i];
      
      // Find the nearest intersection to the visionLine, if any
      Vec2f nearestIntersection = null;
      for (LineSegment wall : this.course.walls) {
        Vec2f intersection = visionLine.intersection(wall);
        if (intersection != null && (nearestIntersection == null || nearestIntersection.sub(this.pos).magnitude() > intersection.sub(this.pos).magnitude())) {
          // If there is an intersection and that intersection is the closest we've seen so far, set nearestIntersection
          nearestIntersection = intersection;
        }
      }
      
      // Set the corresponding value in this.wallDistances
      // Normalize the value to between 0 and 1
      if (nearestIntersection != null) {
        this.wallDistances[i] = nearestIntersection.sub(this.pos).magnitude() / VISION_RANGE;
      } else {
        this.wallDistances[i] = 1;
      }
      
      if (VISION_LINES) {
        // Draw vision lines and intersections
        color fill = lerpColor(color(255, 100, 100), color(100, 255, 100), this.wallDistances[i]);
        stroke(fill);
        fill(fill);
        line(visionLine.p1.x, visionLine.p1.y, visionLine.p2.x, visionLine.p2.y);
        if (nearestIntersection != null) {
          circle(nearestIntersection.x, nearestIntersection.y, 10);
        }
        stroke(0);
      }
    }
  }
  
  void performAction() {
    // Poll the nn for an action to perform
    // NN INPUT: {FRONT, FRONT RIGHT, RIGHT, LEFT, FRONT LEFT, VELOCITY} <-- velocity is normalized between 1 and 0 using max speed
    // NN OUTPUT: {GAS, BRAKE, CRUISE, LEFT, RIGHT, STRAIGHT}
    // NOTE: Softmax is applied once to gas, brake, cruise, and once to left, right, straight.
    //       The neural net makes two decisions at once: one on gas/brake/cruise and one on turning

    float maxSpeed = (-RR_CONSTANT + sqrt(pow(RR_CONSTANT, 2) + 4*TRACTIVE_FORCE*DRAG_CONSTANT))/(2*DRAG_CONSTANT); // Find top speed by using the quadratic
                                                                                                                    // formula to solve for the zeros of
                                                                                                                    // a = (TRACTIVE_FORCE - RR_CONSTANT*v - DRAG_CONSTANT*v^2)/CAR_MASS
    float[] nnInput = {
      this.wallDistances[0],
      this.wallDistances[1],
      this.wallDistances[2],
      this.wallDistances[3],
      this.wallDistances[4],
      this.v.magnitude() / maxSpeed
    };
    
    float[] logits = this.nn.forward(nnInput);
    float[] decision1 = {logits[0], logits[1], logits[2]}; // gas/brake/cruise
    float[] decision2 = {logits[0], logits[1], logits[2]}; // left/right/straight
    
    // Appply softmax to get probabilities for each decision
    decision1 = softmax(decision1);
    decision2 = softmax(decision2);
    
    // Decision 1
    // Find the output with the highest probability
    float max = decision1[0];
    int idxMax = 0;
    for (int idx = 1; idx < decision1.length; ++idx) {
      if (decision1[idx] > max) {
        max = decision1[idx];
        idxMax = idx;
      }
    }
    
    switch (idxMax) {
      case 0: this.gas();    break;
      case 1: this.brake();  break;
      case 2: this.cruise(); break;
    }
    
    // Decision 2
    // Find the output with the highest probability
    max = decision2[0];
    idxMax = 0;
    for (int idx = 1; idx < decision2.length; ++idx) {
      if (decision2[idx] > max) {
        max = decision2[idx];
        idxMax = idx;
      }
    }
    
    switch (idxMax) {
      case 0: this.steerLeft();  break;
      case 1: this.steerRight(); break;
      case 2: this.straight();   break;
    }
    // Draw this.nn
    this.nn.drawNN(1200, 520, 1390, 710);
  }
  
  boolean crashed(LineSegment wall) {
    // Checks if any of the line segments linking the car vertices are intersecting with a wall
    for (int i = 0; i < 4; ++i) {
      Vec2f v1 = this.vertices[i];
      Vec2f v2 = this.vertices[(i + 1) % 4];
      
      LineSegment carSide = new LineSegment(v1, v2);
      if (carSide.intersection(wall) != null) {
        return true;
      }
    }
    return false;
  }
  
  // Actions that the car can perform
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
  void steerLeft() {
    this.steeringAngle = -STEERING_ANGLE;
  }
  void steerRight() {
    this.steeringAngle = STEERING_ANGLE;
  }
  void straight() {
    this.steeringAngle = 0;
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
