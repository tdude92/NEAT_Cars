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

LineSegment[] CHECKPOINTS = {
  // When the car crosses a checkpoint, it gains one point of fitness and extends its timer
  new LineSegment(new Vec2f(640.0, 230.0), new Vec2f(564.0, 382.0)),
  new LineSegment(new Vec2f(713.0, 245.0), new Vec2f(577.0, 407.0)),
  new LineSegment(new Vec2f(783.0, 293.0), new Vec2f(569.0, 427.0)),
  new LineSegment(new Vec2f(802.0, 363.0), new Vec2f(568.0, 447.0)),
  new LineSegment(new Vec2f(804.0, 406.0), new Vec2f(571.0, 469.0)),
  new LineSegment(new Vec2f(806.0, 451.0), new Vec2f(566.0, 500.0)),
  new LineSegment(new Vec2f(804.0, 496.0), new Vec2f(566.0, 532.0)),
  new LineSegment(new Vec2f(802.0, 525.0), new Vec2f(563.0, 559.0)),
  new LineSegment(new Vec2f(802.0, 550.0), new Vec2f(565.0, 607.0)),
  new LineSegment(new Vec2f(808.0, 566.0), new Vec2f(601.0, 670.0)),
  new LineSegment(new Vec2f(822.0, 565.0), new Vec2f(701.0, 705.0)),
  new LineSegment(new Vec2f(835.0, 564.0), new Vec2f(784.0, 705.0)),
  new LineSegment(new Vec2f(851.0, 554.0), new Vec2f(877.0, 697.0)),
  new LineSegment(new Vec2f(872.0, 536.0), new Vec2f(948.0, 687.0)),
  new LineSegment(new Vec2f(907.0, 513.0), new Vec2f(1027.0, 651.0)),
  new LineSegment(new Vec2f(930.0, 497.0), new Vec2f(1111.0, 599.0)),
  new LineSegment(new Vec2f(941.0, 472.0), new Vec2f(1192.0, 468.0)),
  new LineSegment(new Vec2f(942.0, 402.0), new Vec2f(1192.0, 402.0)),
  new LineSegment(new Vec2f(938.0, 336.0), new Vec2f(1210.0, 332.0)),
  new LineSegment(new Vec2f(942.0, 253.0), new Vec2f(1200.0, 249.0)),
  new LineSegment(new Vec2f(931.0, 213.0), new Vec2f(1190.0, 106.0)),
  new LineSegment(new Vec2f(900.0, 198.0), new Vec2f(1043.0, 37.0)),
  new LineSegment(new Vec2f(851.0, 198.0), new Vec2f(840.0, 24.0)),
  new LineSegment(new Vec2f(710.0, 199.0), new Vec2f(702.0, 47.0)),
  new LineSegment(new Vec2f(560.0, 202.0), new Vec2f(574.0, 45.0)),
  new LineSegment(new Vec2f(423.0, 199.0), new Vec2f(424.0, 35.0)),
  new LineSegment(new Vec2f(289.0, 201.0), new Vec2f(288.0, 53.0)),
  new LineSegment(new Vec2f(255.0, 208.0), new Vec2f(68.0, 59.0)),
  new LineSegment(new Vec2f(250.0, 243.0), new Vec2f(17.0, 223.0)),
  new LineSegment(new Vec2f(252.0, 301.0), new Vec2f(13.0, 323.0)),
  new LineSegment(new Vec2f(252.0, 365.0), new Vec2f(25.0, 416.0)),
  new LineSegment(new Vec2f(250.0, 457.0), new Vec2f(20.0, 485.0)),
  new LineSegment(new Vec2f(254.0, 508.0), new Vec2f(23.0, 589.0)),
  new LineSegment(new Vec2f(262.0, 558.0), new Vec2f(46.0, 663.0)),
  new LineSegment(new Vec2f(280.0, 564.0), new Vec2f(266.0, 706.0)),
  new LineSegment(new Vec2f(299.0, 551.0), new Vec2f(456.0, 698.0)),
  new LineSegment(new Vec2f(293.0, 511.0), new Vec2f(520.0, 625.0)),
  new LineSegment(new Vec2f(294.0, 450.0), new Vec2f(533.0, 521.0)),
  new LineSegment(new Vec2f(287.0, 379.0), new Vec2f(535.0, 419.0)),
  new LineSegment(new Vec2f(336.0, 262.0), new Vec2f(520.0, 401.0))
};

class Course {
  LineSegment[] walls;
  LineSegment[] checkpoints;
  
  Course(LineSegment[] walls, LineSegment[] checkpoints) {
    this.walls = walls;
    this.checkpoints = checkpoints;
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
