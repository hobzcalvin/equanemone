import toxi.geom.*;
import toxi.geom.Vec3D;

class Sweeps extends EquanPlugin {
  public Sweeps(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    needsFadeIn = false;

    c.colorMode(HSB, 1, 1, 1, 1);    
  }
  
  float HOT_TOL = 0.02;
  public boolean hot(Plane p, float x, float y, float z) {
    x = (x+0.5)/w - 0.5;
    y = (y+0.5)/h - 0.5;
    z = (z+0.5)/d - 0.5;
    
    return p.getDistanceToPoint(new Vec3D(x, y, z)) < HOT_TOL;
  }
  
  float TOLERANCE = 0.1;
  public float hotness(Plane p, float x, float y, float z) {
    x = (x+0.5)/w - 0.5;
    y = (y+0.5)/h - 0.5;
    z = (z+0.5)/d - 0.5;
    
    float dist = p.getDistanceToPoint(new Vec3D(x, y, z));
    if (dist < TOLERANCE) {
      return 1.0 - dist / TOLERANCE;
    }
    return 0; 
  }
  
  int DURATION = 1000;
  long endTime = 0;
  Vec3D norm = null;
  Vec3D target;
  float hue;
  float sat;
  
  //Vec3D origin = null;
  
  float ROOT3 = 1.442249570307408;
  

  synchronized void draw() {
    // construct various planes, rotated/colored randomly, moving past the cube. math will be involved.
    long ms = millis();
    
    if (norm == null || ms > endTime) {
      //norm = new Vec3D(0, SPEED, 0).rotateX(0).rotateZ(3.14/4);
      norm = Vec3D.randomVector();
      //norm = new Vec3D(1, 1, 1).normalize();
      // target is outside the unit cube.
      target = norm.scale(ROOT3);
      
      hue = random(1);
      sat = random(1);
      
      endTime = ms + DURATION;
    }
    
    float progress = (float)(endTime - ms) / DURATION;
    Plane p = new Plane(norm.scale(ROOT3*(progress - 0.5)), target);

    for (int i = 0; i < w; i++) {
      for (int j = 0; j < h; j++) {
        for (int k = 0; k < d; k++) {
          float x, y, z;
          if (SPHERE) {
            // Convert x/y/z in fake grid to actual places in the sphere
            // angle around y-axis is the "width" factor
            float yangle = (float)i/w * 2 * PI;
            // angle around z-axis is the "height" factor
            float zangle = ((float)j/h - 0.5) * PI;
            // Start vector based on "depth" factor, which is probably flat
            Vec3D v = new Vec3D((1.0 - (float)k/d), 0, 0);
            // START HERE: This does something cool! Buuuuut not what was intended. It seems close, though. What could do that weird patterning?
            // Probably best to use a consistent plane path, like top to bottom, and focus to get the math right. 
            // Also, Planes will want the math fixed here too. So maybe just focus on an x-y-z to x-y-z function for when SPHERE is on.
            // Should be easy enough to troubleshoot the with/without SPHERE values, though we thought that was already the case...hmm...
            v = v.getRotatedY(yangle).getRotatedZ(zangle);
            x = (v.x+1)/2*w;
            y = (v.y+1)/2*h;
            z = (v.z+1)/2*d;
          } else {
            x = i;
            y = j;
            z = k;
          }
          //println(i+","+j+","+k+": "+x+","+y+","+z);
          c.stroke(hue, sat, hotness(p, x, y, z));
          //c.stroke(hue, sat, hotness(p, i, j k));
          c.point(i, j + k*h);
        }
      }
    }
  }
}
