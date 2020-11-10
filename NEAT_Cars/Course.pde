class Course {
  LineSegment[] walls;
  LineSegment[] checkpoints;
  
  Course() {} // Default constructor
  
  void load(String filePath) {
    // Parse a _tck.txt file and load its values into this.walls and this.checkpoints
    String[] lines = loadStrings(filePath);
    
    // Count the number of walls and checkpoints
    // _tck.txt files MUST HAVE NO EMPTY LINES
    // AND A SPECIFIER FOR LINE SEGMENT TYPE MUST
    // BE ON THE FIRST LINE
    int nWalls = 0, nCheckpoints = 0;
    String currType = "";
    for (int i = 0; i < lines.length; ++i) {
      if (trim(lines[i]).substring(0, 1).equals("#")) {
        currType = trim(lines[i]).toUpperCase();
        continue;
      }
      
      if (currType.equals("#WALLS")) {
        nWalls++;
      } else if (currType.equals("#CHECKPOINTS")) {
        nCheckpoints++;
      }
    }
    
    this.walls = new LineSegment[nWalls];
    this.checkpoints = new LineSegment[nCheckpoints + 1]; // Add the first checkpoint to the end so that its a full loop
    
    int i = 0;
    LineSegment[] loadDest = null;
    for (int ctr = 0; ctr < lines.length; ++ctr) {
      if (trim(lines[ctr]).toUpperCase().equals("#WALLS")) {
        i = 0;
        loadDest = walls;
        continue;
      } else if (trim(lines[ctr]).toUpperCase().equals("#CHECKPOINTS")) {
        i = 0;
        loadDest = checkpoints;
        continue;
      }
      
      String[] parsedLine = splitTokens(lines[ctr], ", ");
      if (parsedLine.length == 4) {
        // Null pointer access here means the file didn't specify #walls or #checkpoints
        loadDest[i] = new LineSegment(
          new Vec2f(float(parsedLine[0]), float(parsedLine[1])),
          new Vec2f(float(parsedLine[2]), float(parsedLine[3]))
        );
        ++i;
      }
    }
    this.checkpoints[this.checkpoints.length - 1] = this.checkpoints[0];
  }
  
  void draw() {
    stroke(255);
    for (LineSegment line : this.walls) {
      line(line.p1.x, line.p1.y, line.p2.x, line.p2.y);
    }
    
    if (DRAW_CHECKPOINTS) {
      stroke(0, 255, 0);
      for (LineSegment line : this.checkpoints) {
        line(line.p1.x, line.p1.y, line.p2.x, line.p2.y);
      }
     }
     
    stroke(0);
  }
}
