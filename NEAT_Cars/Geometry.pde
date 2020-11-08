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
  
  float angle() {
    // The angle between this vector and the x-axis
    return atan(this.y/this.x);
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
    // Ensure that p1 is the point with the lower x value
    this.p1 = p1;
    this.p2 = p2;
  }
  
  Vec2f intersection(LineSegment seg) {
    // Calculate the intersection between two line segments, if any
    Vec2f diff1 = this.p2.sub(this.p1);
    Vec2f diff2 = seg.p2.sub(seg.p1);
    
    float intX, intY;
    
    // Account for vertical line segments
    if (diff1.x == 0 && diff2.x == 0) {
      return null; // No intersection (or infinite intersections, assume line segments do not intersect if they exactly the same)
    } else if (diff1.x == 0) {
      float m2 = diff2.y / diff2.x;
      float x2 = seg.p1.x, y2 = seg.p1.y;
      float x1 = this.p1.x;

      intY = m2*(x1 - x2) + y2;
      intX = x1;
    } else if (diff2.x == 0) {
      float m1 = diff1.y / diff1.x;
      float x1 = this.p1.x, y1 = this.p1.y;
      float x2 = seg.p1.x;

      intY = m1*(x2 - x1) + y1;
      intX = x2;
    } else {
      // Regular case
      float m1 = diff1.y / diff1.x;
      float m2 = diff2.y / diff2.x;
      
      float x1 = this.p1.x, y1 = this.p1.y;
      float x2 = seg.p1.x, y2 = seg.p1.y;
      
      if (m1 == m2) {
        return null; // No intersection (or infinite intersections, assume no intersection in this case)
      }
      
      intY = (m1*y2 - m2*y1 + m1*m2*(x1 - x2)) / (m1 - m2);
      
      // Avoid division by zero if one of the lines have slope zero
      if (m1 != 0)
        intX = (intY - y1)/m1 + x1;
      else
        intX = (intY - y2)/m2 + x2;
    }
    
    // Find the leftmost, rightmost, upper, and lower bounds of both line segments
    // The intersection must be within both sets of bounds in order for it to exist on both line segments
    float left1  = min(this.p1.x, this.p2.x), left2  = min(seg.p1.x, seg.p2.x);
    float right1 = max(this.p1.x, this.p2.x), right2 = max(seg.p1.x, seg.p2.x);
    float upper1 = min(this.p1.y, this.p2.y), upper2 = min(seg.p1.y, seg.p2.y);
    float lower1 = max(this.p1.y, this.p2.y), lower2 = max(seg.p1.y, seg.p2.y);
    
    // Check if the point of intersection is within the bounds of the line segments
    if (left1 <= intX && left2 <= intX && intX <= right1 && intX <= right2 &&
        upper1 <= intY && upper2 <= intY && intY <= lower1 && intY <= lower2) {
      return new Vec2f(intX, intY);
    } else {
      return null;
    }
  }
}
