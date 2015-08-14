import processing.video.*;

 
class Fish extends EquanPlugin {
  
  final int NUM_FISH = 3;
  
  String[] files = new String[]{ "fish1.mp4", "fish2.mp4", "fish3.mp4" };
  Movie[] movs;
  float[] formerEnd = new float[] {1.63,3.8,3.15};//{ 1.70, 3.84, 3.35 };
  float[] latterStart = new float[] {1.2,3.3,2.0};//{ 0.9, 3, 1.8 };
  float[] ys = new float[] { 0.3, 0.03, 0.15 };
  float[] heights = new float[] { 0.9, 0.8, 0.7 };
  
  int[] plane = new int[NUM_FISH];
  boolean[] orient = new boolean[NUM_FISH];
  boolean[] mirror = new boolean[NUM_FISH];
  boolean[] latter = new boolean[NUM_FISH];
  float[] hue = new float[NUM_FISH];
  float[] sat = new float[NUM_FISH];
  
  int[] grabStart = new int[NUM_FISH];
  int[] grabSpace = new int[NUM_FISH];
  int[] grabY = new int[NUM_FISH];
  int[] grabHeight = new int[NUM_FISH];

  
  public Fish(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    needsFadeIn = false;
    
    c.colorMode(HSB, 1, 1, 1, 1);
    
    // NEW STYLE: Preload/play all movies
    movs = new Movie[NUM_FISH];
    for (int i = 0; i < movs.length; i++) {
      movs[i] = new Movie(parent, files[i % files.length]);
      newFish(i);
    }
  }
  
  synchronized void newFish(int i) {
    movs[i].pause();
    
    latter[i] = boolean(int(random(2)));
    if (latter[i]) {
      movs[i].jump(latterStart[i % files.length]);
    } else {
      movs[i].jump(0);
    }
    orient[i] = boolean(int(random(2)));
    mirror[i] = boolean(int(random(2)));
    plane[i] = int(random(orient[i] ? w : d));
    hue[i] = random(1);
    sat[i] = random(0.5);

    // Leftmost column is blank for some reason?
    grabStart[i] = latter[i] ? 1 : movs[i].width / 2;
    grabSpace[i] = movs[i].width / 2 / (orient[i] ? d : w);
    grabY[i] = int(ys[i % files.length] * movs[i].height);
    grabHeight[i] = int(heights[i % files.length] * movs[i].height);
    
    movs[i].play();
  }
  
  synchronized void drawFish(int i) {    
    PImage grab;
    
    c.tint(hue[i], sat[i], 1.0);
    
    for (int j = 0; j < (orient[i] ? d : w); j++) {
      grab = movs[i].get(grabStart[i] + grabSpace[i]*j, grabY[i], grabSpace[i], grabHeight[i]);
      if (orient[i]) {
        // Moving across depth, with a plane chosen from width
        c.image(grab, plane[i], (mirror[i] ? d-j-1 : j) * h, 1, h);
      } else {
        // Moving across width, with a plane chosen from depth
        c.image(grab, mirror[i] ? w-j-1 : j, plane[i] * h, 1, h);
      }
    }
    
    if ((!latter[i] && movs[i].time() >= formerEnd[i % files.length]) ||
        movs[i].time() >= movs[i].duration()) {
      newFish(i);
    }
  }
  
  synchronized void draw() {
    for (int i = 0; i < movs.length; i++) {
      drawFish(i);
    }
    println(frameRate);
  }
  
  synchronized void finish() {
    for (int i = 0; i < movs.length; i++) {
      movs[i].stop();
    }
  }

}
