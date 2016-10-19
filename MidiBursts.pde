class MidiBursts extends EquanPlugin {

  final float BURST_VELOCITY = 0.0005;
  final float THICKNESS = 0.1;
  // Minimum time between bursts from the same tentacle
  final long BURST_DELAY = 250;
  // Bursts this time apart or greater from same tentacle should be fully saturated (BURST_DELAY between bursts = no saturation)
  final long SATURATED_DELAY = 8*BURST_DELAY;
  // Max simultaneous bursts allowed (we can only process so many)
  final int MAX_BURSTS = 5;
  long lastBursted[][];
  
  LinkedList<Burst> bursts;

  public MidiBursts(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    bursts = new LinkedList<Burst>();
    lastBursted = new long[w][d];

    c.colorMode(HSB, 1);
    // Bursts crossing each other will combine towards white
    c.blendMode(ADD);
  }
  
  class Burst {
    long time;
    // Track the last time this burst was rendered to any pixels
    long lastRendered;
    int tentacleX;
    int tentacleZ;
    float hue;
    float saturation;
    
    public Burst(int tx, int tz, float sat) {
      tentacleX = tx;
      tentacleZ = tz;
      saturation = sat;
      
      time = millis();
      lastRendered = time;
      hue = random(1.0);
    }
  }
  
  synchronized void mouseClicked() {
    // Simulate a burst on mouse click to work out timing kinks
    noteOn(0, 0, 0, 4, 7);
  }
  
  synchronized void noteOn(int channel, int pitch, int velocity, int tentacleX, int tentacleZ) {
    long millis = millis();
    if (lastBursted[tentacleX][tentacleZ] > millis - BURST_DELAY) {
      // Prevent rapid bursts from same place: there's no time!!!
      return;
    }
    if (bursts.size() >= MAX_BURSTS) {
      // We can't afford to render any more bursts, period.
      return;
    }
    
    synchronized(bursts) {
      bursts.addFirst(new Burst(tentacleX, tentacleZ,
        // Base saturation on how recently tentacle was last touched.
        // Subtract BURST_DELAY since touches BURST_DELAY apart should have zero saturation.
        // Clamp to [0.1, 1] (white is boring)
        min(1, max(0.1, (float)(millis - lastBursted[tentacleX][tentacleZ] - BURST_DELAY) / SATURATED_DELAY))));
      lastBursted[tentacleX][tentacleZ] = millis;
    }
    
  }

  synchronized void draw() {
    //println(frameRate);
    c.background(0);
    
    if (random(frameRate) < 1.0) {
      noteOn(0, 0, 0, int(random(w)), int(random(d)));
    }
    
    long millis = millis();
    
    for (int i = 0; i < w; i++) {
      for (int j = 0; j < d; j++) {
        for (int k = 0; k < h; k++) {
          
          synchronized(bursts) {
            ListIterator<Burst> listIterator = bursts.listIterator();
            while (listIterator.hasNext()) {
              Burst b = listIterator.next();
              
              float radius = (millis-b.time) * BURST_VELOCITY;
              float dist = sqrt(pow(float(i - b.tentacleX)/(w-1), 2) + pow(float(j - b.tentacleZ)/(d-1), 2) + pow(float(k - h/2)/(h-1), 2));
              if (dist < radius && dist > radius - THICKNESS) {
                c.stroke(b.hue, b.saturation, 1.0 - abs(THICKNESS/2 - (radius-dist))/(THICKNESS/2));
                c.point(i, j*h + k);
                
                b.lastRendered = millis;
                
              // Otherwise, this pixel doesn't need to render this burst.
              // If it's the last pixel in the display,
              } else if (i == w-1 && j == d-1 && k == h-1 &&
                         // and no other pixels rendered it this time,
                         b.lastRendered < millis) {
                // it's done. Remove it.
                listIterator.remove();      
              }
            }
          }
        }
      }
    }
  }
}
