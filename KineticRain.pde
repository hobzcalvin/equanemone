import processing.video.*;

import java.util.LinkedList;

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

    for (int i = 0; i < w; i++) {
      for (int j = 0; j < d; j++) {
        float msSinceTouch = millis() - touched[i][j];
        float sine;
        if(msSinceTouch < 1000){
          float mag = (1 - (msSinceTouch/1000));
          println(mag);
          sine = sin(mag*2*PI);
          c.stroke(0, 255, 255);
          c.point(i, h/2 + (sine*h/2) + j*h);
        }
        else {
          sine = sin((float(i)/w)*2*PI);
          c.stroke(0, 255, 255);
          c.point(i, h/2 + (sine*h/2) + j*h);
        }
///change what im passing to sine to be in radian range, then offset with time.
///get sin wavae that responds to one tentacle being pushed and then decays, then get sin waves that add or subtract based on other tentacles
//        float min = min(l_max, r_max);
//        float adjustment;
//        if (min != 0) {
//          adjustment = l_max + r_max / 2;
//        } else {
//          adjustment = max(l_max, r_max);
//        }
//        float sine;
//        if (millis() - adjustment < 1000) {
//          
//          float msSinceRowTouch = millis() - adjustment;
////          i*msSinceRowTouch
//          sine = sin(i*msSinceRowTouch);
//        }else {
//          sine = sin(i);
//        }
//        c.stroke(0, 255, 255);
//        c.point(i, h/2 + (sine*h/2) + j*h);
//
      }
    }
  }

      
}
    
  

  

//  synchronized void draw() {
//    c.background(0, 0, 0);
//    long[][] touched = getMidiLastTouched();
//    long millis = millis();
//    println(millis(), millis);
//    for (int i = 0; i < w; i++) {
//      for (int j = 0; j < d; j++) {
//        long l_max = 0;
//        long r_max = 0;
//        for (int il = 0; il <= i; il++) {
//          if (touched[il][j] > l_max) {
//            l_max = touched[il][j];
//          }
//        }
//        for (int ir = i+1; ir < w; ir++) {
//          if (touched[ir][j] > r_max) {
//            r_max = touched[ir][j];
//          }
//        }
/////change what im passing to sine to be in radian range, then offset with time.
/////get sin wavae that responds to one tentacle being pushed and then decays, then get sin waves that add or subtract based on other tentacles
//        float min = min(l_max, r_max);
//        float adjustment;
//        if (min != 0) {
//          adjustment = l_max + r_max / 2;
//        } else {
//          adjustment = max(l_max, r_max);
//        }
//        float sine;
//        if (millis() - adjustment < 1000) {
//          
//          float msSinceRowTouch = millis() - adjustment;
////          i*msSinceRowTouch
//          sine = sin(i*msSinceRowTouch);
//        }else {
//          sine = sin(i);
//        }
//        c.stroke(0, 255, 255);
//        c.point(i, h/2 + (sine*h/2) + j*h);
//
//      }
//
//      
//    }
//  
//
//  }
  
//}

