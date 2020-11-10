// Chart classes
class PieChart {
  float x, y, r;
  
  PieChart(float x, float y, float r) {
    this.x = x;
    this.y = y;
    this.r = r;
  }
  
  void draw(Evaluator eval) {
    float currAngle = 0;
    for (int i = 0; i < eval.species.size(); ++i) {
      Species species = eval.species.get(i);
      float percentage = float(species.population()) / eval.genomes.length;
      fill(species.colour);
      arc(this.x, this.y, 2*this.r, 2*this.r, currAngle, currAngle + 2*PI*percentage);
      fill(255);
      textAlign(LEFT, CENTER);
      text(str(species.population()), this.x + cos(currAngle + PI*percentage)*this.r, this.y + sin(currAngle + PI*percentage)*this.r);
      currAngle += 2*PI*percentage;
    }
    for (int i = 0; i < eval.extinct.size(); ++i) {
      // If a species was completely culled in eval.update(), it gets removed from eval.species
      // We still need to draw the extinct ones because the pie chart is a visualization of the
      // makeup of the population BEFORE .update() was called.
      Species species = eval.extinct.get(i);
      float percentage = float(species.population()) / eval.genomes.length;
      fill(species.colour);
      arc(this.x, this.y, 2*this.r, 2*this.r, currAngle, currAngle + 2*PI*percentage);
      fill(255);
      textAlign(LEFT, CENTER);
      text(str(species.population()), this.x + cos(currAngle + PI*percentage)*this.r, this.y + sin(currAngle + PI*percentage)*this.r);
      currAngle += 2*PI*percentage;
    }
  }
}

class Histogram {
  float x1, y1, x2, y2;
  float paddedX1, paddedY2;
  float w, h;
  float paddedW, paddedH, padRight;
  float textSize;
  float axisPadding;
  float upperBound;
  
  int nBars;
  
  String xText, yText;
  
  Histogram(String xText, String yText, float x1, float y1, float x2, float y2, float textSize, int nBars, float upperBound) {
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
    
    this.xText = xText;
    this.yText = yText;
    
    this.nBars = nBars;
    
    this.upperBound = upperBound;
    
    this.w = x2 - x1;
    this.h = y2 - y1;
    
    this.textSize = textSize;
    this.axisPadding = 4*this.textSize;
    
    this.paddedX1 = x1 + this.axisPadding;
    this.paddedY2 = y2 - this.axisPadding;
    
    this.padRight = 2*this.textSize;
    this.paddedW = this.w - this.axisPadding - this.padRight;
    this.paddedH = this.h - this.axisPadding;
  }
  
  void draw(Evaluator eval) {
    fill(255);
    rect(x1, y1, w, h);
    
    // Draw axes
    line(this.paddedX1, this.y1, this.paddedX1, this.paddedY2);
    line(this.paddedX1, this.paddedY2, this.x2, this.paddedY2);
    fill(0);
    textAlign(CENTER, BOTTOM);
    text(this.xText, this.paddedX1 + this.paddedW/2, this.y2);
    textAlign(CENTER, TOP);
    pushMatrix();
    translate(this.x1, this.y1 + this.paddedH/2);
    rotate(-PI/2);
    text(this.yText, 0, 0);
    popMatrix();
    
    // Find min and max fitness values
    ArrayList<Species> allSpecies = new ArrayList<Species>();
    allSpecies.addAll(eval.species);
    allSpecies.addAll(eval.extinct);
    
    // Sort genomes into their respective bars
    float intervalWidth = this.upperBound / this.nBars;
    int[] intervals = new int[this.nBars];
    for (Species s : allSpecies) {
      // Iterate through genomes in species because genomes in eval.genomes are the next generation
      for (Genome g : s.genomes) {
        if (g.rawFitness > this.upperBound) {
          // This data point is not within the bounds of the graph
          continue;
        }
        
        int idx = int(g.rawFitness/intervalWidth);
        intervals[idx]++;
      }
    }
    
    float dx = this.paddedW/nBars; // How many pixels wide each bar is
    float dy = 3*this.paddedH/eval.genomes.length/4; // How many pixels tall one individual is in a bar
    
    // Draw bars and numbers
    textAlign(CENTER, TOP);
    textSize(8);
    pushMatrix();
    translate(this.paddedX1, this.paddedY2);
    rotate(-PI/2);
    text("0.0", this.paddedX1, this.paddedY2);
    popMatrix();
    for (int i = 0; i < intervals.length; ++i) {
      fill(255, 100, 100);
      rect(this.paddedX1 + i*dx, this.paddedY2 - intervals[i]*dy, dx, intervals[i]*dy);
      fill(0);
      textAlign(CENTER, BOTTOM);
      text(str(intervals[i]), this.paddedX1 + i*dx + dx/2, this.paddedY2 - intervals[i]*dy);
      textAlign(RIGHT, CENTER);
      pushMatrix();
      translate(this.paddedX1 + (i + 1)*dx, this.paddedY2 + 2);
      rotate(-PI/2);
      text(str(roundN((i + 1)*intervalWidth, 2)), 0, 0);
      popMatrix();
    }
    textSize(12);
  }
}
