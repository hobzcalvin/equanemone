import processing.video.*;
import toxi.geom.*;
import toxi.geom.Vec3D;

class SpinVideo extends EquanPlugin {
  
  Movie mov;
  
  public SpinVideo(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    needsFadeIn = true;
    
    mov = new Movie(parent, "4851407.mp4");
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

  int doframerate = 0;
  synchronized void draw() {
    //c.image(bg, 0, 0);
    plane = new Plane(origin, norm.getRotatedY(theta));
    frame = mov.get();
    frame.resize(max(w, d) * 10, h);
        
    for (int i = 0; i < w; i++) {
      for (int j = 0; j < h; j++) {
        for (int k = 0; k < d; k++) {
          //c.stroke(0, 0, hotness(i, j, k));
          //c.point(i, j + k*h);
          /*if (hotness(i, j, k)) {
            c.point(i, j + k*h);
          }*/
          hotness(i, j, k);
          c.point(i, j + k*h);
        }
      }
    }
    theta += 0.01;
    if (doframerate++ % 10 == 0) {
      println(frameRate);
    }
  }
}
