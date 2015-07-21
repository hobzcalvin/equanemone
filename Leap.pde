import de.voidplus.leapmotion.*;

class Leap extends EquanPlugin {

  LeapMotion leap;

  //float maxx = 0, minx = 0, maxy = 0, miny = 0, maxz = 0, minz = 0;
  float maxx = 1000, minx = 0, maxy = 500, miny = 0, maxz = 75, minz = 0;

  public Leap(int wd, int ht, int dp) {
    super(wd, ht, dp);
    c.colorMode(HSB, 1);
    //colorMode(HSB, 1);
    
    leap = new LeapMotion(parent);
    //leap.setWorld(w, h, d);
    //leap.moveWorld(0, 0, 0);
    
    threshold = 3.0;//sqrt(pow(w, 2) + pow(h, 2) + pow(d, 2));
    
  }
  
  float threshold;
  
  synchronized void draw() {
    
    c.image(bg, 0, 0);
    
    float curFinger = 0;
    /*for (Finger f : leap.getFingers()) {
      //stroke(255, 255, 255);
      //f.draw(false);
      PVector pos = f.getPosition();
      if (pos.x < minx) minx = pos.x;
      if (pos.x > maxx) maxx = pos.x;
      if (pos.y < miny) miny = pos.y;
      if (pos.y > maxy) maxy = pos.y;
      if (pos.z < minz) minz = pos.z;
      if (pos.z > maxz) maxz = pos.z;
    }*/
      
    for (Finger f : leap.getFingers()) {
      PVector pos = f.getPosition();
      pos.x = (pos.x - minx) / (maxx - minx) * (d-1);
      pos.y = (pos.y - miny) / (maxy - miny) * (h-1);
      pos.z = (1.0 - (pos.z - minz) / (maxz - minz)) * (w-1);
      // XXX: Hack: swap these so the preview looks right.
      float temp = pos.x;
      pos.x = pos.z;
      pos.z = temp;
      
      println(curFinger, pos);

      for (float i = 0; i < w; i++) {
        for (float j = 0; j < d; j++) {
          for (float k = 0; k < h; k++) {
            float dist = pos.dist(new PVector(j, k, i));
            /*if (i == 0 && j == 0 && k == 0) {
              //println("pos", pos);//f.getPosition());
              println("dist", dist);
            }*/
            if (dist < threshold) {
              dist = pow((threshold-dist)/threshold, 2);
              c.stroke(curFinger / 10.0, 1, 1, dist);
              c.point(i, j*h + k);
            }
          }
        }
      }
      

      curFinger++;
    }
    //println("minmax", minx, maxx, miny, maxy, minz, maxz, "thres", threshold);
    //minmax -374.6292 1451.4341 -139.26947 608.3326 -20.114578 127.96602

  }
}
