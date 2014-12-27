class Lava extends EquanPlugin {
  public Lava(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    noiseDetail(3);
    c.colorMode(HSB, 1);
  }
  
  float THRESHOLD = 0.5;
  float NOISE_INCR = 0.003;
  
  float noiseOffset = 0;
  
  synchronized void draw() {
    c.image(bg, 0, 0);
    for (float i = 0; i < w; i++) {
      for (float j = 0; j < d; j++) {
        for (float k = 0; k < h; k++) {
            if (noise(noiseOffset + j/d, i/w, k/h) > THRESHOLD) {
              float hue = noise(i/w/4, noiseOffset/4 + j/d/4, k/h/4) * 1.5;
              if (hue > 1) {
                hue -= 1;
              }
              float sat = noise(i/w, j/d, noiseOffset/2 + k/h);
              float bright = min(1, noise(i/w, j/d, 100 + noiseOffset/2 + k/h) + 0.25);
              c.stroke(hue, sat, bright);
              c.point(i, j*h + k);
            }
        }
      }
    }
    noiseOffset += NOISE_INCR;
  }
}
