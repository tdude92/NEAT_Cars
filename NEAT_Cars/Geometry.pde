class Vec2f {
  // A 2D vector class used for physics
  
  float x, y;
  
  Vec2f(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  Vec2f add(Vec2f v) {
    return new Vec2f(this.x + v.x, this.y + v.y);
  }
  
  Vec2f sub(Vec2f v) {
    return new Vec2f(this.x - v.x, this.y - v.y);
  }
  
  Vec2f scale(float c) {
    // Multiply by a scalar
    return new Vec2f(this.x * c, this.y * c);
  }
  
  Vec2f rotate(float theta) {
    // Rotate by theta radians
    return new Vec2f(this.x*cos(theta) - this.y*sin(theta), this.x*sin(theta) + this.y*cos(theta));
  }
  
  Vec2f perpendicular(boolean clockwise) {
    // Returns the vector perpendicular to this
    if (clockwise) {
      // Clockwise
      return new Vec2f(this.y, -this.x);
    } else {
      // Counterclockwise
      return new Vec2f(-this.y, this.x);
    }
  }
  
  float dot(Vec2f v) {
    // Dot product of two vectors
    return this.x*v.x + this.y*v.y;
  }
  
  float magnitude() {
    return sqrt(pow(this.x, 2) + pow(this.y, 2));
  }
  
  Vec2f direction() {
    // Returns a unit vector for direction
    return this.scale(1/this.magnitude());
  }
  
  void printVec() {
    println("[" + str(this.x) + ", " + str(this.y) + "]");
  }
}


class LineSegment {
  Vec2f p1, p2;
  
  LineSegment(Vec2f p1, Vec2f p2) {
    this.p1 = p1;
    this.p2 = p2;
  }
  
  boolean overlaps(LineSegment seg) {
    // TODO Calculates whether this line segment overlaps with another line segment
    return false;
  }
}
