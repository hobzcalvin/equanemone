class TennisBalls extends EquanPlugin {
  
  class Ball extends Thread {        
    int a, b;
    boolean running;
    boolean doFlash;
    
    Ball (int av, int bv) {
      a=av;
      b=bv;
      running = true;
      
      doFlash = false;                
    }
    
    void slp(long ms) {                
      if (doFlash) return;      
      try {
        Ball.sleep(ms);                
      } catch(InterruptedException e) {
      }
    }
    
    void run() {
      while (running) {                
        slp((long)random(100*3));      
        for (int k = h; k > 0; k = k/2){   
          //Draws the downward bounce.
          for (int i = 0; i < k; i++) {
            synchronized(c) {
              c.beginDraw();
              c.set(a, (i - k) + h + b*h, yellow);  
              c.endDraw();
            }
            slp(200/(i + 1));                     
            synchronized(c) {
              c.beginDraw();
              c.set(a, (i - k) + h +  b*h, black);    
              c.endDraw();
            }
          }
          //Draws the upward bounce.
          for (int i = k/2; i > 0; i += -1) {
            synchronized(c) {
              c.beginDraw();
              c.set(a, (i - (k/2 + 1)) + h  + b*h, yellow);  
              c.endDraw();
            }
            slp((20-1));
            synchronized(c) {
              c.beginDraw();
              c.set(a, (i - (k/2 + 1)) + h + b*h, black);    
              c.endDraw();
            }
          }
          if (doFlash) {                 
            doFlash = false;
            //Draw tennis court profile when LED tubes are touched.
            synchronized(c) {
              c.beginDraw();
              c.stroke(purple);  
              c.line(a, b*h, a, b*h + h-1);   
              c.stroke(green);
              c.line(a, b*h + h-2, a, b*h + h-1);
              c.line(a, b*h, a, b*h + 1);
              c.set(a, b*h + h/2, white);
              c.endDraw();
            }
            slp(200);    
            //Returns LED tubes to black after tennis court profile.            
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
  
  Ball drops[];
  color yellow, black, green, purple, white;

  public TennisBalls(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    needsFadeIn = false;                          
    
    c.colorMode(RGB, 255);                        
    yellow = color(78, 93, 17);                   //Tennis ball yellow.
    black = color(0, 0, 0);                       
    green = color(44, 82, 52);                    //Tennis court green.
    purple = color(64, 58, 96);                   //Tennis court purple.
    white = color(255, 255, 255);
    
    drops = new Ball[w*d];                        
    for (int i = 0; i < w; i++) {
      for (int j = 0; j < d; j++) {
        drops[i * d + j] = new Ball(i, j);
        drops[i * d + j].start();                  
      }
    }
  }
  
  synchronized void noteOn(int channel, int pitch, int velocity, int tentacleX, int tentacleZ) {
    drops[tentacleX * d + tentacleZ].lightning();  //lightning turns doFlash to true (i.e., someone is touching the specific tube)
  }
  
  synchronized void finish() {
    for (int i = 0; i < drops.length; i++) {
      drops[i].quit();
    }
  }
}
