

class SimpleMidi extends EquanPlugin {
  
  // Track hue and saturation values for each tentacle
  char[][] hues;
  char[][] sats;
  
  final float DECAY = 0.001;
  
  public SimpleMidi(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    // Calls to c.stroke() etc. will be passed hue/saturation/brightness values in range 0-255
    c.colorMode(HSB, 255, 255, 255);
    // Default, but make sure: lines are 1 pixel wide.
    c.strokeWeight(1);
    
    hues = new char[w][d];
    sats = new char[w][d];
  }

  
  synchronized void draw() {
    
    // just making sure this works; return value is unused
    getRecentMidiEvents();
    
    // store last-touched times for each tentacle locally
    long[][] touched = getMidiLastTouched();
    // Remember this so we don't keep calling millis()
    long millis = millis();
    
    // For each tentacle (in width/depth), set stroke color based on
    // when it was last touched.
    for (int i = 0; i < w; i++) {
      for (int j = 0; j < d; j++) {
        // Use hue/sat set in noteOn; brightness is based on how long ago it was last touched.
        c.stroke(hues[i][j], sats[i][j], 255.0 * cos(min(DECAY*(millis-touched[i][j]), PI/2)));
        // This draws the entire tentacle in the chosen stroke color.
        c.line(i, j*h, i, j*h+h-1);
      }
    }
  }
  
  
  void noteOn(int channel, int pitch, int velocity, int tentacleX, int tentacleZ) {
    // Another way to hear about notes being played / tentacles being touched.
    // Here we use this to set hue/saturation on the tentacle once.
    // (Brightness "decays" over time.)
    hues[tentacleX][tentacleZ] = (char)random(256);
    sats[tentacleX][tentacleZ] = (char)random(256);
  }  

  void noteOff(int channel, int pitch, int velocity, int tentacleX, int tentacleZ) {
    // Currently this will never be sent: why clog the system with note-off events if we don't need them?
  }  
}


