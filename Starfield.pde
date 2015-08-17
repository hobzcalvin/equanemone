class Starfield extends EquanPlugin {
  public Starfield(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    c.colorMode(HSB, 1);
  }

  synchronized void draw() {
    // Shift everything over one pixel
    PImage shift = c.get(0, 0, w-1, h*d);
    c.background(0);
    c.image(shift, 1, 0);
    
    // Add a new pixel somewhere
    c.stroke(0, 0, 1);
    c.point(0, random(h*d));
  }
  
  synchronized void noteOn(int channel, int pitch, int velocity, int tentacleX, int tentacleZ) {
    c.stroke(random(1), 1, 1);
    c.point(tentacleX, tentacleZ*h + random(h));
  }  
}
