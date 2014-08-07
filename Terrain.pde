class Terrain extends EquanPlugin {

  float noiseOffset = 0.0;
  float NOISE_INCR = 0.02;
  float SPEED = 1/4.0;
  float BREADTH = 1/7.0;
  
  public Terrain(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    noiseDetail(2);
  }
  
  synchronized void draw() {
    c.colorMode(HSB, 1);
    c.clear();
    for (int i = 0; i < w; i++) {
      for (int j = 0; j < d; j++) {
        // START HERE: figure out good SPEED first, and use noiseDetail() to make it look
        // less jittery. then experiment with a little BREADTH, and figure out a better way
        // to cover the whole hue/sat spectrum too. noise doesn't work well here because it
        // hovers around 0.5. Also, anti-alias the terrain? Maybe not if not jittery??
        // Note that hue/sat don't need to be continuous either; sudden changes are
        // sometimes okay...
        float noiseX = noiseOffset + i*SPEED;
        float noiseY = j*BREADTH;
        float y = noise(noiseX, noiseY, 0) * h;
        float hue = noise(noiseX / 2, noiseY / 2, 10) * 2 - 0.5;
        float sat = noise(noiseX / 2, noiseY / 2, 20) * 2 - 0.5;
        
        c.stroke(hue, sat, 1);
        c.line(i, y + j*h, i, (j+1)*h-1);
      }
    }
    noiseOffset += NOISE_INCR;
  }
}
