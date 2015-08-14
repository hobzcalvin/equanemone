import processing.video.*;
import toxi.geom.*;
import toxi.geom.Vec3D;

class SpinVideo extends EquanPlugin {
  
  Movie mov;
  
  public SpinVideo(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    needsFadeIn = true;
    
    String f = this.randomVideo();
    println("Loading", f);
    mov = new Movie(parent, f);// "2059820.mp4");
    mov.loop();
    
    c.colorMode(HSB, 255);
  }

  Plane plane;
  Vec3D origin = new Vec3D(0, 0, 0);
  ReadonlyVec3D norm = new Vec3D(1, 0, 0);
  PImage frame;
  
  float TOLERANCE = 0.5;
  float theta = 0;

  public boolean hotness(float x, float y, float z) {
    x = (x+0.5)/w - 0.5;
    y = (y+0.5)/h - 0.5;
    z = (z+0.5)/d - 0.5;
    Vec3D pt = new Vec3D(x, y, z);
    
    float dist = plane.getDistanceToPoint(pt);
    if (dist < TOLERANCE) {
      /*if (y >= 0.4) {
        c.stroke(0, 0, (1.0 - dist/TOLERANCE) * 255.0);
        return true;
      }*/
      Vec3D shadow = plane.getProjectedPoint(pt).getRotatedY(-theta);
      //println(shadow.x, shadow.y, shadow.z);
      float xx = (shadow.z + 0.5) * frame.width;
      float yy = (shadow.y + 0.5) * frame.height;
      //c.stroke(shadow.z + 0.5, shadow.y + 0.5, 1.0 - dist / TOLERANCE);
      color pix = frame.get((int)xx, (int)yy);
      /*dist = 1.0 - dist / TOLERANCE;
      c.stroke(red(pix) * dist, green(pix) * dist, blue(pix) * dist);*/
      //println(hue(pix), saturation(pix), brightness(pix));
      c.stroke(hue(pix), saturation(pix), brightness(pix) * (1.0 - dist / TOLERANCE));
      
      //c.stroke(0, 0, 1.0 - dist / TOLERANCE);
      return true;
    }
    c.stroke(0, 0, 0);
    return false;
    /*if (dist < TOLERANCE) {
      return 1.0 - dist / TOLERANCE;
    }
    return 0; */
  }

  //int doframerate = 0;
  synchronized void draw() {
    //c.image(bg, 0, 0);
    plane = new Plane(origin, norm.getRotatedY(theta));
    frame = mov.get();
    
    if (frame.width == 0 || frame.height == 0) {
      // This never happens on Mac, but trying to resize a 0x0 frame on Windows and Linux crashes.
      return;
    }

    frame.resize(max(w, d) * 10, h);
    
    // store last-touched times for each tentacle locally
    long[][] touched = getMidiLastTouched();
    // Remember this so we don't keep calling millis()
    long millis = millis();

        
    for (int i = 0; i < w; i++) {
      for (int k = 0; k < d; k++) {
        for (int j = 0; j < h; j++) {
          //c.stroke(0, 0, hotness(i, j, k));
          //c.point(i, j + k*h);
          /*if (hotness(i, j, k)) {
            c.point(i, j + k*h);
          }*/
          hotness(i, j, k);
          c.point(i, j + k*h);
        }
        
        // Now apply an alpha'd inverse for touched tentacles
        float invert = cos(min(0.001*(millis-touched[i][k]), PI/2));
        if (invert > 0.001) {
          PImage col = c.get(i, k*h, 1, h);
          col.filter(INVERT);
          c.tint(255, 255.0 * invert);
          c.image(col, i, k*h);
        }
          
      }
    }
    theta += 0.01;
    /*if (doframerate++ % 10 == 0) {
      println(frameRate);
    }*/
  }
  
  
  synchronized void finish() {
    mov.stop();
    mov = null;
  }
}
