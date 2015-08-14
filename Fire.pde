import processing.video.*;

class Fire extends EquanPlugin {
  
  Movie mov;
  int FROM_SCALE = 4;
  
  public Fire(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    needsFadeIn = false;
    
    mov = new Movie(parent, "loopingd.mp4");
    mov.loop();
    
    c.colorMode(HSB, 1, 1, 1, 1);
  }
  
  synchronized void draw() {
    /*float hue = (float)mouseX / width / 4.0;
    float sat = (float)mouseY / height;
    c.tint(hue, sat, 1);
    if (random(100) < 2) println(hue, sat);*/
    
    // store last-touched times for each tentacle locally
    long[][] touched = getMidiLastTouched();
    // Remember this so we don't keep calling millis()
    long millis = millis();

    PImage grab;
    for (int i = 0; i < d; i++) {
      c.tint(0.075, 0.7, 1);
      grab = mov.get(mov.width/2 + i*w*FROM_SCALE, mov.height - h*FROM_SCALE - 1, w*FROM_SCALE, h*FROM_SCALE);
      c.image(grab, 0, i*h, w, h);
      
      for (int j = 0; j < w; j++) {
        // Now apply an alpha'd inverse for touched tentacles
        float invert = cos(min(0.001*(millis-touched[j][i]), PI/2));
        if (invert > 0.001) {
          PImage col = c.get(j, i*h, 1, h);
          col.filter(INVERT);
          c.tint(1, 1.0 * invert);
          c.image(col, j, i*h);
        }
      }
    }
  }
  
  synchronized void finish() {
    mov.stop();
  }

}
