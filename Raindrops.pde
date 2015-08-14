class Raindrops extends EquanPlugin {
  
  class Dropper extends Thread {
    int a, b;
    boolean running;
    boolean doFlash;
    
    Dropper (int av, int bv) {
      a=av;
      b=bv;
      running = true;
      
      doFlash = false;
    }
    
    void slp(long ms) {
      if (doFlash) return;
      try {
        Dropper.sleep(ms);
      } catch(InterruptedException e) {
      }
    }
    
    void run() {
      while (running) {
        slp((long)random(1000*3));
        //println("drop!", a, b);
        for (int i = 0; i < h; i++) {
          synchronized(c) {
            c.beginDraw();
            c.set(a, i + b*h, blue);
            c.endDraw();
          }
          slp(7);
          synchronized(c) {
            c.beginDraw();
            c.set(a, i + b*h, black);
            c.endDraw();
          }
          if (doFlash) {
            doFlash = false;
            synchronized(c) {
              c.beginDraw();
              c.stroke(255, 255, 255);
              c.line(a, b*h, a, b*h + h -1);
              c.endDraw();
            }
            slp(20);
            synchronized(c) {
              c.beginDraw();
              c.stroke(black);
              c.line(a, b*h, a, b*h + h -1);
              c.endDraw();
            }
          }
        }
      }
    }
    
    void lightning() {
      doFlash = true;
      interrupt();
    }
    
    void quit() {
      running = false;
      // In case the thread is sleeping
      interrupt();
    }
  }
  
  Dropper drops[];
  color blue, black;

  public Raindrops(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    needsFadeIn = false;
    
    c.colorMode(RGB, 255);
    blue = color(0, 0, 255);
    black = color(0, 0, 0);
    
    drops = new Dropper[w*d];
    for (int i = 0; i < w; i++) {
      for (int j = 0; j < d; j++) {
        drops[i * d + j] = new Dropper(i, j);
        drops[i * d + j].start();
      }
    }
  }
  
  synchronized void noteOn(int channel, int pitch, int velocity, int tentacleX, int tentacleZ) {
    drops[tentacleX * d + tentacleZ].lightning();
  }
  
  synchronized void finish() {
    for (int i = 0; i < drops.length; i++) {
      drops[i].quit();
    }
  }
}
