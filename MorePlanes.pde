import toxi.geom.*;
import toxi.geom.Vec3D;

class MorePlanes extends EquanPlugin {
  Plane[] planes;
  float hue;
  float sat;
  
  public MorePlanes(int wd, int ht, int dp) {
    super(wd, ht, dp);
    planes = new Plane[4];

    
    /*Vec3D p1 = new Vec3D(w/2, 20, d/2);
    Vec3D p2 = new Vec3D(1, 5, 1);
    Vec3D p3 = new Vec3D(w-5, 5, 1);
    Vec3D p4 = new Vec3D(1, 5, d-5);
    planes[0] = new Plane(new Triangle3D(p2, p3, p4));
    planes[1] = new Plane(new Triangle3D(p1, p3, p4));
    planes[2] = new Plane(new Triangle3D(p1, p2, p3));
    planes[3] = new Plane(new Triangle3D(p1, p2, p4));
    */
    
    /*planes[0] = new Plane(new Triangle3D(new Vec3D(0, 0, 1), new Vec3D(0, 1, 1), new Vec3D(1, 0, 5)));
    planes[1] = new Plane(new Triangle3D(new Vec3D(0, 0, 0), new Vec3D(1, 25, 7), new Vec3D(0, 25, 7)));
    planes[2] = new Plane(new Triangle3D(new Vec3D(5, 0, 5), new Vec3D(10, 0, 0), new Vec3D(5, 30, 0)));
    planes[3] = new Plane(new Triangle3D(new Vec3D(5, 0, 5), new Vec3D(4, 1, 1), new Vec3D(4, 0, 1)));*/
    /*Vec3D origin = new Vec3D(wd/2.0, ht/2.0, dp/2.0);
    planes[0] = new Plane(origin, origin.add(2, 2, 0));
    planes[1] = new Plane(origin, origin.add(0, -10, 0));
    planes[2] = new Plane(origin, origin.add(2, 0, 0));*/
  }
  
  Vec3D randomVector() {
    return new Vec3D(random(w), random(h), random(d));
  }
  

  float TOLERANCE = 1.0;
  boolean satisfied = false;
  float SATISFACTION_THRESHOLD = 0.1;
  Vec3D addVector;
  synchronized void draw() {
    c.colorMode(HSB, 1);

    do {    
      c.background(0);
      
      if (!satisfied) {
        hue = random(1);
        sat = random(0.5) + 0.5;
        addVector = new Vec3D(random(0.02), random(0.02), random(0.02));
        for (int i = 0; i < planes.length; i++) {
          planes[i] = new Plane(new Triangle3D(randomVector(), randomVector(), randomVector()));
          // XXX: for some reason we can't create the same plane twice?? so create it in this other way here...
          //planes[i] = new Plane(new Vec3D(planes[i].x, planes[i].y, planes[i].z), planes[i].normal);
        }
      }
      
      int numInside = 0;
      for (int i = 0; i < w; i++) {
        for (int j = 0; j < h; j++) {
          for (int k = 0; k < d; k++) {
            Vec3D vec = new Vec3D(i, j, k);
            
            // SHAPE STYLE
            
            boolean inside = true;
            float closest = TOLERANCE * 2;
            for (Plane plane : planes) {
              if (plane.classifyPoint(vec, 0) == Plane.Classifier.BACK) {
                closest = min(closest, plane.getDistanceToPoint(vec));
              } else {
                inside = false;
              }
            }
            if (inside) {
              numInside++;
              if (closest < TOLERANCE) {
                c.stroke(hue, sat, closest / TOLERANCE);
              } else {
                c.stroke(hue, sat, 1);
              }
              c.point(i, j + k*h);
            }
            
            // DEBUG STYLE
            /*
            satisfied = true;
            for (int pp = 0; pp < planes.length; pp++) {
              Plane plane = planes[pp];
              if (plane.classifyPoint(vec, 0) == Plane.Classifier.BACK) {
                float dist = plane.getDistanceToPoint(vec);
                if (dist < TOLERANCE) {
                  c.stroke(pp/float(planes.length), 1, dist / TOLERANCE);
                  c.point(i, j + k*h);
                  break;
                }
              }
            }
            */
          }
        }
      }
      if (!satisfied && numInside > h*w*d * SATISFACTION_THRESHOLD) {
        satisfied = true;
      }
      // Even if we were satisfied before, redo everything if we see nothing at all
      if (numInside == 0) {
        satisfied = false;
      }
    } while (!satisfied);
    for (int i = 0; i < planes.length; i++) {
      planes[i] = new Plane((new Vec3D(planes[i].x, planes[i].y, planes[i].z)).add(addVector), planes[i].normal.rotateY(0.0001 * frameRate ));
      //planes[i].add(addVector);
      //planes[i].rotateY(0.01);
    }
  }
}
