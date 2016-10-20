class RainbowGoo extends EquanPlugin {
  
  public RainbowGoo(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    needsFadeIn = true;
    
    c.colorMode(HSB, 360, 1, 1);
  }
  
  synchronized void draw() {
    for (int i = 0; i < w; i++) {
        for (int j = 0; j < h; j++) {
          for (int k = 0; k < d; k++) {
            c.stroke((i*50 + j*10 + k*50 + millis() / 5) % 360, 1, 1);
            c.point(i, j + k*h);
          }
        }
    }
  }

}
