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
}
