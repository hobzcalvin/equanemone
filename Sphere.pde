class Sphere extends EquanPlugin {
  public Sphere(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    noiseDetail(2);
    c.colorMode(HSB, 1);
  }
  
  float THRESHOLD = 0.4;
  float FULL_CENTER = 0.1;
  float NOISE_INCR = 0.03;
  
  float noiseOffset = 0;
  
  float spreadNoise(float in) {
    return (max(0.25, min(0.75, in)) - 0.25) * 2;
  }
  
  synchronized void draw() {
    float mult = THRESHOLD - FULL_CENTER;
    float hue = spreadNoise(noise(noiseOffset/10, noiseOffset, 100));
    //println(hue);
    float sat = spreadNoise(noise(noiseOffset, noiseOffset/10, 100));
    c.image(bg, 0, 0);
    float x = noise(noiseOffset, 0, 0);
    float y = noise(0, noiseOffset, 0);
    float z = noise(0, 0, noiseOffset);
    //println(z, y, z);
    for (float i = 0; i < w; i++) {
      for (float j = 0; j < d; j++) {
        for (float k = 0; k < h; k++) {
          float dist = sqrt(pow(i/(w-1) - x, 2) + pow(j/(d-1) - y, 2) + pow(k/(h-1) - z, 2));
          if (dist < THRESHOLD) {
            dist -= FULL_CENTER;
            dist = (mult - dist) / mult;
            c.stroke(hue, sat, pow(dist, 1));
            c.point(i, j*h + k);
          }
        }
      }
    }
    noiseOffset += NOISE_INCR;
  }
}
