with open("tracksegs1200x720.txt", "w") as wf:
    with open("trackverticesinner1200x720.txt", "r") as rf:
        lines = rf.readlines()
        for i in range(len(lines)):
            p1 = lines[i].strip("\n,")
            p2 = lines[(i + 1) % len(lines)].strip("\n,")
            wf.write("new LineSegment(" + p1 + ", " + p2 + "),\n")
    with open("trackverticesouter1200x720.txt", "r") as rf:
        lines = rf.readlines()
        for i in range(len(lines)):
            p1 = lines[i].strip("\n,")
            p2 = lines[(i + 1) % len(lines)].strip("\n,")
            wf.write("new LineSegment(" + p1 + ", " + p2 + "),\n")
