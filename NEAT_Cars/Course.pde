LineSegment[] COURSE_WALLS = {
  new LineSegment(new Vec2f(945, 189), new Vec2f(258, 188)),
  new LineSegment(new Vec2f(258, 188), new Vec2f(238, 198)),
  new LineSegment(new Vec2f(238, 198), new Vec2f(239, 572)),
  new LineSegment(new Vec2f(239, 572), new Vec2f(272, 584)),
  new LineSegment(new Vec2f(272, 584), new Vec2f(307, 570)),
  new LineSegment(new Vec2f(307, 570), new Vec2f(307, 323)),
  new LineSegment(new Vec2f(307, 323), new Vec2f(328, 280)),
  new LineSegment(new Vec2f(328, 280), new Vec2f(403, 247)),
  new LineSegment(new Vec2f(403, 247), new Vec2f(673, 244)),
  new LineSegment(new Vec2f(673, 244), new Vec2f(748, 269)),
  new LineSegment(new Vec2f(748, 269), new Vec2f(786, 323)),
  new LineSegment(new Vec2f(786, 323), new Vec2f(791, 573)),
  new LineSegment(new Vec2f(791, 573), new Vec2f(811, 583)),
  new LineSegment(new Vec2f(811, 583), new Vec2f(841, 579)),
  new LineSegment(new Vec2f(841, 579), new Vec2f(962, 500)),
  new LineSegment(new Vec2f(962, 500), new Vec2f(960, 196)),
  new LineSegment(new Vec2f(960, 196), new Vec2f(945, 189)),
  new LineSegment(new Vec2f(1058, 76), new Vec2f(139, 76)),
  new LineSegment(new Vec2f(139, 76), new Vec2f(61, 107)),
  new LineSegment(new Vec2f(61, 107), new Vec2f(30, 161)),
  new LineSegment(new Vec2f(30, 161), new Vec2f(30, 161)),
  new LineSegment(new Vec2f(30, 161), new Vec2f(31, 611)),
  new LineSegment(new Vec2f(31, 611), new Vec2f(62, 658)),
  new LineSegment(new Vec2f(62, 658), new Vec2f(144, 691)),
  new LineSegment(new Vec2f(144, 691), new Vec2f(384, 693)),
  new LineSegment(new Vec2f(384, 693), new Vec2f(495, 647)),
  new LineSegment(new Vec2f(495, 647), new Vec2f(512, 611)),
  new LineSegment(new Vec2f(512, 611), new Vec2f(514, 359)),
  new LineSegment(new Vec2f(514, 359), new Vec2f(581, 359)),
  new LineSegment(new Vec2f(581, 359), new Vec2f(583, 610)),
  new LineSegment(new Vec2f(583, 610), new Vec2f(616, 659)),
  new LineSegment(new Vec2f(616, 659), new Vec2f(711, 695)),
  new LineSegment(new Vec2f(711, 695), new Vec2f(914, 693)),
  new LineSegment(new Vec2f(914, 693), new Vec2f(1162, 549)),
  new LineSegment(new Vec2f(1162, 549), new Vec2f(1169, 155)),
  new LineSegment(new Vec2f(1169, 155), new Vec2f(1139, 111)),
  new LineSegment(new Vec2f(1139, 111), new Vec2f(1097, 89)),
  new LineSegment(new Vec2f(1097, 89), new Vec2f(1058, 76))
};

class Course {
  LineSegment[] walls;
  
  Course(LineSegment[] walls) {
    this.walls = walls;
  }
  
  void draw() {
    stroke(255);
    for (LineSegment line : this.walls) {
      line(line.p1.x, line.p1.y, line.p2.x, line.p2.y);
    }
    stroke(0);
  }
}
