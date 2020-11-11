// Car acceleration physics implemented as described:
// https://asawicki.info/Mirror/Car%20Physics%20for%20Games/Car%20Physics%20for%20Games.html

// Note: in this simulation, 5 pixels = 1 meter

// CAR CONSTANTS
float CAR_MASS = 500; // kg
float CAR_W = 10; // Car width
float CAR_L = 20; // Car length
float STEERING_ANGLE = 2*PI/5; // Radians
float VISION_RANGE = 500; // pixels

// Adjust these to adjust car physics
float TRACTIVE_FORCE = 8000; // N
float DRAG_CONSTANT = 0.4257f;
float RR_CONSTANT = DRAG_CONSTANT*30; // Rolling resistance
float BRAKING_CONSTANT = 5000;
float LATV_DECAY = 0.93;

// Utility
float clamp(float x, float lower, float upper) {
  // Clamp a value x between lower and upper bounds
  return min(max(x, lower), upper);
}

float roundN(float x, int n) {
  // Round x to n decimals
  return round(x*pow(10, n))/pow(10, n);
}

class Car {
  // In its most basic form, a Car instance is just a rectangle
  
  Course course; // Course object so that we can access walls and checkpoints
  
  NeuralNet nn;
  float fitness = 0;
  boolean crashedFlag = false;
  boolean lapCompleted = false;
  
  // Visual
  int colour;
  String state1 = "null"; // gas/brake/cruise
  String state2 = "null"; // left/right/straight
  
  // Holds the distance from each wall
  float[] wallDistances = new float[7]; // {0deg, -20deg, -45deg, -90deg, 90deg, 45deg, 20deg} if 0 deg is straight ahead and the angle increases counterclockwise
  
  // Index of the next checkpoint the car should be visiting
  // Ensures that the car visits checkpoints in the correct order
  int idxNextCheckpoint = 0;
  
  // Used to track the number of .update() calls on the car.
  // If the time elapsed passes the time limit, the evaluation for this car finishes
  // Crossing a checkpoint increases the time limit
  int timer = 0;
  int timeLimit = TIME_LIMIT*int(FRAMERATE);
  
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
    
    // Update fitness (number of checkpoints crossed)
    if (this.crashed(this.course.checkpoints[this.idxNextCheckpoint])) { // crashed lol
      this.fitness += 0.1;
      this.timeLimit += round(FRAMERATE*0.75); // Give the .update() calls equivalent of 0.75 seconds worth of extra time
      this.idxNextCheckpoint++;
      if (this.idxNextCheckpoint == this.course.checkpoints.length) {
        // If in training mode, end the evaluation when a lap is completed
        this.lapCompleted = true;
        this.idxNextCheckpoint = 0;
      }
    }
    
    timer++; // Increment timer
  }
  
  void scanWalls() {
    LineSegment[] visionLines = {
      new LineSegment(this.pos, this.pos.add(this.dir.scale(VISION_RANGE))),
      new LineSegment(this.pos, this.pos.add(this.dir.rotate(PI/32).scale(VISION_RANGE))),
      new LineSegment(this.pos, this.pos.add(this.dir.rotate(PI/4).scale(VISION_RANGE))),
      new LineSegment(this.pos, this.pos.add(this.dir.rotate(PI/2).scale(VISION_RANGE))),
      new LineSegment(this.pos, this.pos.add(this.dir.rotate(-PI/2).scale(VISION_RANGE))),
      new LineSegment(this.pos, this.pos.add(this.dir.rotate(-PI/4).scale(VISION_RANGE))),
      new LineSegment(this.pos, this.pos.add(this.dir.rotate(-PI/32).scale(VISION_RANGE)))
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
    }
  }
  
  void performAction() {
    // Poll the nn for an action to perform
    // NN INPUT: {FRONT, -20deg, FRONT RIGHT, RIGHT, LEFT, FRONT LEFT, 20deg}
    // NN OUTPUT: {GAS, STEERING}
    float[] nnInput = {
      this.wallDistances[0],
      this.wallDistances[1],
      this.wallDistances[2],
      this.wallDistances[3],
      this.wallDistances[4],
      this.wallDistances[5],
      this.wallDistances[6]
    };
    
    float[] logits = this.nn.forward(nnInput);
    
    // Transform logits to be a sigmoid function between -1 and 1
    // Round the logits to -1, 0, or 1, since there are three possible choices for each decision
    int aLong = round(2*logits[0] - 1); // brake/cruise/drive (a stands for action)
    int aLat  = round(2*logits[1] - 1); // left/straight/right
    
    switch (aLong) {
      case -1: this.brake();  break;
      case  0: this.cruise(); break;
      case  1: this.gas();    break;
    }
    
    switch (aLat) {
      case -1: this.steerLeft();  break;
      case  0: this.straight();   break;
      case  1: this.steerRight(); break;
    }
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
  
  void reset(Vec2f pos, Vec2f dir) {
    // Resets the car to a position and orientation, clearing/resetting all fields
    this.fitness = 0;
    this.timer = 0;
    this.timeLimit = TIME_LIMIT*int(FRAMERATE);
    this.lapCompleted = false;
    this.idxNextCheckpoint = 0;
    
    // Reset position, direction
    this.pos = pos;
    this.dir = dir;
    
    this.crashedFlag = false; // Reset crashed flag
    
    // Reset velocity, acceleration, steering angle
    this.v = new Vec2f(0, 0);
    this.a = new Vec2f(0, 0);
    this.steeringAngle = 0;
    
    // Reset forces
    this.fTraction = new Vec2f(0, 0);
    this.fDrag = new Vec2f(0, 0);
    this.fRR = new Vec2f(0, 0);
    this.fBraking = new Vec2f(0, 0);
  }
  
  // Actions that the car can perform
  void gas() {
    // Update forces to simulate if the driver stepped on the gas
    this.state1 = "gas";
    this.fBraking = new Vec2f(0, 0);
    this.fTraction = this.dir.scale(TRACTIVE_FORCE);
  }
  void cruise() {
    // Update forces to simulate if the driver did nothing
    this.state1 = "cruise";
    this.fBraking = new Vec2f(0, 0);
    this.fTraction = new Vec2f(0, 0);
  }
  void brake() {
    // Update forces to simulate if the driver stepped on the brakes
    this.state1 = "brake";
    this.fBraking = this.dir.scale(-BRAKING_CONSTANT);
    this.fTraction = new Vec2f(0, 0);
  }
  void steerLeft() {
    this.state2 = "left";
    this.steeringAngle = -STEERING_ANGLE;
  }
  void steerRight() {
    this.state2 = "right";
    this.steeringAngle = STEERING_ANGLE;
  }
  void straight() {
    this.state2 = "straight";
    this.steeringAngle = 0;
  }
  
  void draw() {
    // Draw car, nn, vision lines, and write information onto sketch
    fill(255);
    text(str(roundN(this.timer/FRAMERATE, 2)) + " sec", 1150, 20);
    text(str(roundN(this.v.magnitude()*3.6/5, 1)) + " km/h", 1150, 40);
    text("Fitness: " + str(roundN(this.fitness, 2)), 1150, 60);
    text("Action 1: " + this.state1, 1150, 80);
    text("Action 2: " + this.state2, 1150, 100);
    
    this.nn.drawNN(1060, 620, 1240, 720);
    
    // Draw vision lines
    LineSegment[] visionLines = {
      new LineSegment(this.pos, this.pos.add(this.dir.scale(VISION_RANGE))),
      new LineSegment(this.pos, this.pos.add(this.dir.rotate(PI/32).scale(VISION_RANGE))),
      new LineSegment(this.pos, this.pos.add(this.dir.rotate(PI/4).scale(VISION_RANGE))),
      new LineSegment(this.pos, this.pos.add(this.dir.rotate(PI/2).scale(VISION_RANGE))),
      new LineSegment(this.pos, this.pos.add(this.dir.rotate(-PI/2).scale(VISION_RANGE))),
      new LineSegment(this.pos, this.pos.add(this.dir.rotate(-PI/4).scale(VISION_RANGE))),
      new LineSegment(this.pos, this.pos.add(this.dir.rotate(-PI/32).scale(VISION_RANGE)))
    };
    if (VISION_LINES) {
      for (int i = 0; i < visionLines.length; ++i) {
        LineSegment line = visionLines[i];
        float distance = this.wallDistances[i];
        
        color fillCol = lerpColor(color(255, 100, 100), color(100, 255, 100), distance);
        stroke(fillCol);
        fill(fillCol);
        line(line.p1.x, line.p1.y, line.p2.x, line.p2.y);
        
        if (distance < 1) {
          Vec2f circleCenter = line.p1.add(line.p2.sub(line.p1).direction().scale(distance*VISION_RANGE));
          circle(circleCenter.x, circleCenter.y, 10);
        }
      }
      stroke(0); // Reset stroke to black
    }
    
    fill(this.colour);
    quad(
      this.vertices[0].x, this.vertices[0].y,
      this.vertices[1].x, this.vertices[1].y,
      this.vertices[2].x, this.vertices[2].y,
      this.vertices[3].x, this.vertices[3].y
    );
  }
}
