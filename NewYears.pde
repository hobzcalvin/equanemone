class NewYears extends EquanPlugin {
  public NewYears(int wd, int ht, int dp) {
    super(wd, ht, dp);
    c.colorMode(HSB, 1);
    
    needsFadeIn = false;
  }
  
  boolean strobe = true;
  
  synchronized void draw() {
    strobe = !strobe;
    
    if (strobe) {
      c.fill(0, 0, 0);
      c.stroke(0, 0, 0);
      c.rect(0, 0, w, h);
      return;
    }
    
    for (int i = 0; i < w; i++) {
      for (int j = 0; j < d; j++) {
        for (int k = 0; k < h; k++) {
          c.stroke(random(1), 0.5, 1);
          c.point(i, j*h + k);
        }
      }
    }
  }
}
