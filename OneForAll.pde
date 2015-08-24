import processing.video.*;

import java.util.Random;

class OneForAll extends EquanPlugin {

  int SPEED = 500;
  long nextMove;
  int curColor;

  public OneForAll(int wd, int ht, int dp) {
    super(wd, ht, dp);
    c.colorMode(RGB, 255);
    nextMove = millis() + SPEED;
    curColor = 0;
  }
  
  
  synchronized void draw() {
    Random randomGenerator = new Random();
    
    long[][] touched = getMidiLastTouched();
    long millis = millis();
    println(millis(), millis);
    for (int i = 0; i < w; i++) {
      for (int j = 0; j < d; j++) {
        float msSinceTouch = millis - touched[i][j];
        if (msSinceTouch < 10) {
          int randomInt = randomGenerator.nextInt(255);
          curColor = (curColor + 1) % 3;
          if (curColor == 0) {
            c.background(0, 0, randomInt);
          } else if (curColor == 1) {
            c.background(randomInt, 0, 0);
          } else{
            c.background(0, randomInt, 0);
          } 
        }
     
      }
    }

      
    }

  
}
