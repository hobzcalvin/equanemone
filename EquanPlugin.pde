public abstract class EquanPlugin {
  int w; // width
  int h; // height
  int d; // depth
  PGraphics c; // canvas of dimensions w x (h*d)
  
  boolean needsFadeIn = true;
  
  public EquanPlugin(int wd, int ht, int dp) {
    this.c = createGraphics(wd, ht*dp, JAVA2D);
    c.beginDraw();
    c.background(0);
    c.endDraw();

    this.w = wd;
    this.h = ht;
    this.d = dp;
  }
  
  synchronized void draw() {
    // c is about to be scraped for pixels; do what you will.
  }
  
  synchronized void finish() {
    // This plugin is being turned off; stop any threads.
  }
  
  synchronized void mouseClicked() {
  }
  
  synchronized void noteOn(int channel, int pitch, int velocity, int tentacleX, int tentacleZ) {
  }
  
  synchronized void noteOff(int channel, int pitch, int velocity, int tentacleX, int tentacleZ) {
  }

  
  String randomVideo() {
    //if (true) return "videos/1617358.mp4";
    java.io.File folder = new java.io.File(dataPath("videos"));
    String[] filenames = folder.list();
    
    while (true) {
      String f = filenames[int(random(filenames.length))];
      if (!f.equals(".DS_Store")) {
        return "videos/" + f;
      }
    }
  }
}
