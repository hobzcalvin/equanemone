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
    c.tint(0.075, 0.7, 1);
  }
  
  synchronized void draw() {
    /*float hue = (float)mouseX / width / 4.0;
    float sat = (float)mouseY / height;
    c.tint(hue, sat, 1);
    if (random(100) < 2) println(hue, sat);*/
    
    PImage grab;
    for (int i = 0; i < d; i++) {
      grab = mov.get(mov.width/2 + i*w*FROM_SCALE, mov.height - h*FROM_SCALE - 1, w*FROM_SCALE, h*FROM_SCALE);
      c.image(grab, 0, i*h, w, h);
    }
  }
  
  synchronized void finish() {
    mov.stop();
  }

}
