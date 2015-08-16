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
  
  long[] bubbles;
  
  long nextBubbleMove;
  // Milliseconds between bubble movement
  final int BUBBLE_MS = 50;

  
  public Fish(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    needsFadeIn = false;
    
    c.colorMode(HSB, 1, 1, 1, 1);
    
    bubbles = new long[w*d];
    for (int i = 0; i < bubbles.length; i++) {
      bubbles[i] = 0;
    }
    
    
    // NEW STYLE: Preload/play all movies
    movs = new Movie[NUM_FISH];
    for (int i = 0; i < movs.length; i++) {
      movs[i] = new Movie(parent, files[i % files.length]);
      newFish(i);
    }
    
    nextBubbleMove = millis() + BUBBLE_MS;
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
    c.background(0);
    
    for (int i = 0; i < movs.length; i++) {
      drawFish(i);
    }
    
    // Not sure if we should move bubbles consistently by milliseconds or just do them every draw() frame.
    // They won't move consistently if moved on every draw(), but skipping a draw (which happens every 50 ms or so?) is worse.
    boolean moveBubbles = true;//millis() >= nextBubbleMove ? (nextBubbleMove += BUBBLE_MS)>0 : false;
    
    //c.loadPixels();
    c.stroke(0, 0, 1);
    synchronized(bubbles) {
      for (int i = 0; i < bubbles.length; i++) {
        for (int j = 0; j < h; j++) {
          if ((bubbles[i] & ((long)1 << j)) != 0) {
            // Crazy math to translate to the 1-dimensional pixel space
            //c.pixels[i%w  +  (i/w) * w * h  +  w * (h-j-1)] = 0xFFFFFF;
            // Less crazy math since working on pixels directly doesn't seem to work in the output
            c.point(i%w, (i/w)*h -j+h-1);
          }
        }
        if (moveBubbles) {
          // Make bubbles float up
          bubbles[i] <<= 1;
        }
      }
    }
    //c.updatePixels();

  }
  
  synchronized void noteOn(int channel, int pitch, int velocity, int tentacleX, int tentacleZ) {
    synchronized(bubbles) {
      // Create a bubble at the bottom of this tentacle
      bubbles[tentacleX + tentacleZ*w] |= 1;
    }
  }
  
  synchronized void finish() {
    for (int i = 0; i < movs.length; i++) {
      movs[i].stop();
    }
  }

}
