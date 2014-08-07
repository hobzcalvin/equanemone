import toxi.geom.*;
import toxi.geom.Vec3D;

class Planes extends EquanPlugin {
  
  float noiseOffset = 0.0;
  float NOISE_INCR = 0.005;
  
  class PlaneObj {
    Vec3D origin = new Vec3D(0, 0, 0);
    ReadonlyVec3D norm = new Vec3D(0, 1, 0);
    
    float xRotOff = random(1000000);
    //float zRotOff = random(1000000);
    
    float TOLERANCE = 0.05;
    public float hotness(float x, float y, float z) {
      x = (x+0.5)/w - 0.5;
      y = (y+0.5)/h - 0.5;
      z = (z+0.5)/d - 0.5;
      
      /*float mx = (float)mouseX / width;
      float my = (float)mouseY / height;
      Plane p = new Plane(origin, norm.getRotatedX(mx).rotateZ(my));*/
      
      Plane p = new Plane(origin, norm.getRotatedX(noise(noiseOffset, xRotOff)*2 - 1.0)
                                        .rotateZ(noise(noiseOffset, xRotOff+100)*2 - 1.0));
      
      float dist = p.getDistanceToPoint(new Vec3D(x, y, z));
      if (dist < TOLERANCE) {
        return 1.0 - dist / TOLERANCE;
      }
      /*if (p.classifyPoint(new Vec3D(x/w-0.5, y/h-0.5, z/d-0.5), 0.05) == Plane.Classifier.ON_PLANE) {
        return 1;
      }*/
      return 0; 
    }
  }
  
  PlaneObj[] planes;
  float hue = random(1);
  float sat = random(1);
  
  public Planes(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    noiseDetail(4);
    
    planes = new PlaneObj[3];
    for (int i = 0; i < 3; i++) {
      planes[i] = new PlaneObj();
    }
  }
  
  synchronized void draw() {
    c.colorMode(RGB, 1);
    for (int i = 0; i < w; i++) {
      for (int j = 0; j < h; j++) {
        for (int k = 0; k < d; k++) {
          c.stroke(planes[0].hotness(i, j, k),
                   planes[1].hotness(i, j, k),
                   planes[2].hotness(i, j, k));
          //c.stroke(hue, sat, planes[0].hotness(i, j, k));
          
          c.point(i, j + k*h);
        }
      }
    }
    noiseOffset += NOISE_INCR;
  }

}
