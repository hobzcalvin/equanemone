class UpDown extends EquanPlugin {
  
  int SPEED = 50;
  long nextMove;

  public UpDown(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    needsFadeIn = false;
    
    nextMove = millis();
    
    /*for (int i = 0; i < w; i++) {
      for (int j = 0; j < d; j++) {
        c.set(i, j*h + 20, color(255, 255, 255));
      }
    }*/
  }
  
  synchronized void draw() {
    if (millis() < nextMove) {
      return;
    }
    c.colorMode(HSB, 255);
    
    for (int i = 0; i < w; i++) {
      for (int j = 0; j < d; j++) {
        boolean up = i % 2 == j % 2;
        PImage img = c.get(i, j*h + (up ? 1 : 0), 1, h-1);
        c.image(img, i, j*h + (up ? 0 : 1));
        int pixY = j*h + (up ? h-1 : 0);
        color pixel = c.get(i, pixY);
        //println(i, j, brightness(pixel));
        if (brightness(pixel) < 100) {
          c.stroke(random(255), random(255), 255);
        } else {
          c.stroke(hue(pixel), saturation(pixel), brightness(pixel) * 0.8);
        }
        c.point(i, pixY);
      }
    }
    nextMove = millis() + SPEED;
  }
}
