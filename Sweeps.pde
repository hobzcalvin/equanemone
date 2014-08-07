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
    
    //float mx = (float)mouseX / width;
    float progress = (float)(endTime - ms) / DURATION;
    //println(progress, ROOT3*(progress*2 - 1), norm, target);
    Plane p = new Plane(norm.scale(ROOT3*(progress - 0.5)), target);
    //Plane p = new Plane(new Vec3D(0, 0, 0), (new Vec3D(0, 1, 0)).rotateX(0).rotateZ(3.14/4));
    
    /*c.noStroke();
    c.fill(0, 0.03);
    c.rect(0, 0, c.width, c.height);
    
    c.stroke(hue, sat, 1);*/
    for (int i = 0; i < w; i++) {
      for (int j = 0; j < h; j++) {
        for (int k = 0; k < d; k++) {
          c.stroke(hue, sat, hotness(p, i, j, k));
          c.point(i, j + k*h);
          /*if (hot(p, i, j, k)) {
            c.point(i, j + k*h);
          }*/
        }
      }
    }
  }
}
