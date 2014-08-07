class Fireflies extends EquanPlugin {
  HashSet positions = new HashSet();
  class Firefly extends Thread {
    boolean running = true;
    
    long lastStart = 0;
    int x,y,z;
    
    void slp(long ms) {
      try {
        Firefly.sleep(ms);
      } catch(InterruptedException e) {
      }
    }
    
    void run() {
      while (running) {
        slp((long)random(1000*5));
        synchronized(positions) {
          if (lastStart != 0) {
            positions.remove(new int[]{x,y,z});
          }
          do {
            x = int(random(w));
            y = int(random(h));
            z = int(random(d));
          } while (positions.contains(new int[]{x,y,z}));
          positions.add(new int[]{x,y,z});
        }
        lastStart = millis();
      }
    }
    
    void quit() {
      running = false;
      // In case the thread is sleeping
      interrupt();
    }
  }
  
  Firefly flies[];
  
  static final float FADE_IN = 500;
  static final float LIGHT_HOLD = 1000;
  static final float FADE_OUT = 750;

  synchronized void draw() {
    c.beginDraw();
    c.colorMode(HSB, 255, 1, 1, 1);
    c.background(0);
    long ms = millis();
    for (int i = 0; i < flies.length; i++) {
      Firefly f = flies[i];
      float bright;
      if (ms <= f.lastStart + FADE_IN) {
        bright = 1 - min((f.lastStart + FADE_IN - ms) / FADE_IN, 1);
      } else if (ms <= f.lastStart + FADE_IN + LIGHT_HOLD) {
        bright = 1;
      } else {
        bright = max((f.lastStart + FADE_IN + LIGHT_HOLD + FADE_OUT - ms) / FADE_OUT, 0);
      }
      //if (i == 0) println("B", bright, f.x, f.y, f.z);
      c.stroke(40, 1, bright);
      c.point(f.x, f.y + f.z*h);
    }
    c.endDraw();
  }
  
  synchronized void finish() {
    for (int i = 0; i < flies.length; i++) {
      flies[i].quit();
    }
  }
  
  public Fireflies(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    needsFadeIn = false;
    
    flies = new Firefly[12];
    for (int i = 0; i < flies.length; i++) {
      flies[i] = new Firefly();
      flies[i].start();
    }
  }
  
}
