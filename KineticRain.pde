import processing.video.*;

import java.util.LinkedList;
import java.util.Collections;
//import java.util.List;

class KineticRain extends EquanPlugin {

  int SPEED = 500;
  long nextMove;
  int curColor;
  final float WIGGLE_SPEED = 0.015;

  public KineticRain(int wd, int ht, int dp) {
    super(wd, ht, dp);
    c.colorMode(RGB, 255);
    nextMove = millis() + SPEED;
    curColor = 0;
  }
  
  synchronized void draw() {
    c.background(0, 0, 0);
    long[][] touched = getMidiLastTouched();
    long millis = millis();
    
    //make array of sine wave values to be accessed later      
    float sineWave[];
    int resolution = d*10;
    sineWave = new float[resolution];
    float angle = -2 * PI;
    for (int j = 0; j < resolution; j++) {
      sineWave[j] = sin(angle);
      angle = angle + ((4*PI)/(resolution));
    }

    for (int i = 0; i < w; i++) {
      
      int timeLimit = 2000;
      float msSinceTouch = millis();
      int leftLastTouchedIndex = 0;
      int rightLastTouchedIndex = 0;
      float leftMin = millis() - touched[i][0];
      float rightMin = millis() - touched[i][d-1];
     //get min of each row
      for (int j = 1; j < d/2; j++) {
        float newMsSinceTouch = millis() - touched[i][j];
        if (newMsSinceTouch < leftMin) {
          leftMin = newMsSinceTouch;
          leftLastTouchedIndex = j;
        }
      } 
      for (int j = d/2; j < d; j++){
        float newMsSinceTouch = millis() - touched[i][j];
        if (newMsSinceTouch < rightMin) {
          rightMin = newMsSinceTouch;
          rightLastTouchedIndex = j;
        }
      } 
      if (leftMin > timeLimit) {
        leftMin = -1;
      }
      if (rightMin > timeLimit) {
        rightMin = -1;
      }
      for (int j = 0; j < d; j++) {
          float rightMag = (1 - (rightMin)/(timeLimit)); 
          float leftMag = (1 - (leftMin)/(timeLimit));
          int leftSineWaveIndex = (abs(j-leftLastTouchedIndex)+(int(leftMin)/10))%resolution;
          int rightSineWaveIndex = (abs((d-j)-rightLastTouchedIndex)+(int(rightMin)/10))%resolution;
        if (leftMin > 0 && rightMin < 0) {  
          float mag = leftMag; 
          c.stroke(0, 0, 255);
          c.point(i, h/2 + (sineWave[leftSineWaveIndex]*h/2*mag) + j*h); 
        } else if (leftMin < 0 && rightMin > 0) {
          float mag = rightMag; 
          c.stroke(0, 255, 0);
          c.point(i, h/2 + (sineWave[rightSineWaveIndex]*h/2*mag) + j*h);
        } 
        else if (leftMin > 0 && rightMin > 0){
          float mag = (rightMag + leftMag) / 2;
          c.stroke(255, 0, 0);
          int sineWaveIndex = (leftSineWaveIndex + rightSineWaveIndex) / 2;
          c.point(i, h/2 + (sineWave[sineWaveIndex]*h/2*mag) + j*h);
        } else {
          c.stroke(255, 0, 255);
          c.point(i, h/2 + j*h);
        }
      }
    }     
  }
}
      

    
  

  



