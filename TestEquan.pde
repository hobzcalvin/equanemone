class TestEquan extends EquanPlugin {
  public TestEquan(int wd, int ht, int dp) {
    super(wd, ht, dp);
  }
  
  float hues[] = { 0, 1.0/3, 2.0/3, 5.0/6 };
  
  synchronized void draw() {
    c.colorMode(HSB, 1);
    for (int i = 0; i < w; i++) {
      for (int j = 0; j < d; j++) {
        c.stroke(hues[i], (j+1) / 4.0, 1);
        c.point(i, j*h + h/2);
      }
    }
  }
}
