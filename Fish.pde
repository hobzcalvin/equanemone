import processing.video.*;

class Fish extends EquanPlugin {
  
  int FROM_SCALE = 8;
  String[] files = new String[]{ "fish1.mp4", "fish2.mp4", "fish3.mp4" };
  float[] formerEnd = new float[] {1.5,3.6,3};//{ 1.70, 3.84, 3.35 };
  float[] latterStart = new float[] {1.2,3.3,2.4};//{ 0.9, 3, 1.8 };
  float[] ys = new float[] { 0.3, 0.03, 0.15 };
  float[] heights = new float[] { 0.9, 0.8, 0.7 };
  
  Movie mov;
  int movIndex;
  int plane;
  boolean orient;
  boolean mirror;
  boolean latter;
  
  
  public Fish(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    needsFadeIn = false;
    
    c.colorMode(HSB, 1, 1, 1, 1);
    
    newFish();
  }
  
  synchronized void newFish() {
    movIndex = int(random(files.length));
    
    if (mov != null) mov.stop();
    mov = new Movie(parent, files[movIndex]);
    mov.play();
    
    latter = boolean(int(random(2)));
    if (latter) {
      mov.jump(latterStart[movIndex]);
      // duration() must be called after play() for accuracy.
      //mov.jump(mov.duration() / 2);
    }
    orient = boolean(int(random(2)));
    mirror = boolean(int(random(2)));
    plane = int(random(orient ? w : d));
    c.tint(random(1), random(0.5), 1);
    //println("FISH!", movIndex, latter, orient, mirror, plane);
  }
  
  synchronized void draw() {    
    PImage grab;
    
    // Leftmost column is blank for some reason?
    int grabStart = latter ? 1 : mov.width / 2;
    // Minus one to account for the plus one above.
    int grabSpace = mov.width / 2 / ((orient ? d : w) - 0);
    int grabY = int(ys[movIndex] * mov.height);
    int grabHeight = int(heights[movIndex] * mov.height);
    
    /*image(mov, 100, 10, mov.width/2, mov.height/2);
    stroke(255, 255, 255);
    line(100 + mov.width/4, 10, 100 + mov.width/4, 10 + mov.height/2);
    line(100, 10 + mov.height/2*ys[movIndex], 100 + mov.width/2, 10 + mov.height/2*ys[movIndex]);
    line(100, 10 + mov.height/2*heights[movIndex], 100 + mov.width/2, 10 + mov.height/2*heights[movIndex]);*/
    for (int i = 0; i < (orient ? d : w); i++) {
      grab = mov.get(grabStart, grabY, grabStart + grabSpace*i, grabHeight);
      if (orient) {
        // Moving across depth, with a plane chosen from width
        c.image(grab, plane, (mirror ? d-i-1 : i) * h, 1, h);
      } else {
        // Moving across width, with a plane chosen from depth
        c.image(grab, mirror ? w-i-1 : i, plane * h, 1, h);
      }
      //c.image(ggg, ggg, 1, h);
    }
    
    /*for (int i = 0; i < d; i++) {
      grab = mov.get(mov.width/2 + i*w*FROM_SCALE, mov.height - h*FROM_SCALE - 1, w*FROM_SCALE, h*FROM_SCALE);
      c.image(grab, 0, i*h, w, h);
    }*/
    
    if ((!latter && mov.time() >= formerEnd[movIndex]) ||
        mov.time() >= mov.duration()) {
      newFish();
    }
  }
  
  synchronized void finish() {
    mov.stop();
  }

}
