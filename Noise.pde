class Noise extends EquanPlugin {
  public Noise(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    noiseDetail(4);
    c.colorMode(HSB, 1);
  }
  
  synchronized void draw() {
    for (int i = 0; i < w; i++) {
      for (int j = 0; j < d; j++) {
        for (int k = 0; k < h; k++) {
          c.stroke(0);
          c.point(i, j*h + k);
        }
      }
    }
  }
}
