import com.heroicrobot.dropbit.devices.*;
import com.heroicrobot.dropbit.common.*;
import com.heroicrobot.dropbit.discovery.*;
import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.*;

import processing.core.*;
import java.util.*;


int PIX_PER_STRAND = 40;
int STRANDS_PER_STRIP = 4;
int NUM_STRIPS = 4;

DeviceRegistry registry;
TestObserver testObserver;
PApplet parent = this;

Class[] plugins = {
  //TestEquan.class,
  //Noise.class,

  Lava.class,
  Raindrops.class,
  Fire.class,
  Sweeps.class,
  Fireflies.class,
  Planes.class,
  Fish.class,
  UpDown.class,
  Terrain.class,
};

  
PGraphics bg;
EquanPlugin curPlugin;
int nextPluginIndex = 0;
int numRecords = 0;
long startTime;

boolean SPHERE = true;
float SPHERE_TOP_RADIUS = 6;
float SPHERE_TOTAL_RADIUS = 42;

int FADE_TIME = 1500;
int PLUGIN_TIME = 10000;
float CYL_DIA = 2.5;
float CYL_HEIGHT = SPHERE ? 2: 1.23;
int CYL_DETAIL = 8;
float STRAND_SPACING = 12;

boolean modeCycle = true;
boolean recording = true;

PShape cyl;

void setup() {
  size(1024, 768, P3D);
  //registry = new DeviceRegistry();
  testObserver = new TestObserver();
  //registry.addObserver(testObserver);
  //registry.setAntiLog(true);

  background(50, 50, 50);
  colorMode(RGB, 255, 255, 255, 1);

  bg = createGraphics(NUM_STRIPS, PIX_PER_STRAND*STRANDS_PER_STRIP, JAVA2D);
  bg.beginDraw();
  bg.background(0);
  bg.endDraw();

  frameRate(120);
  
  nextPluginIndex = 0;
  
  startTime = millis();
  
  cyl = makeCyl(CYL_DIA/2, CYL_DIA/2, CYL_HEIGHT, CYL_DETAIL);
}

int dragStartX;
int dragStartY;
float dragPosX = 0;
float dragPosY = 0;
float oldDPX;
float oldDPY;
void mousePressed() {
  dragStartX = mouseX;
  dragStartY = mouseY;
  oldDPX = dragPosX;
  oldDPY = dragPosY;
}
void mouseDragged() {
  dragPosX = oldDPX + (float)(mouseX - dragStartX)/width;
  dragPosY = oldDPY + (float)(mouseY - dragStartY)/height;
  //println("DP: " + dragPosX + ", " + dragPosY);
}

void pasteCanvas(PGraphics can) {
  PImage c = can.get();
  image(c, 0, 0);
  image(c, c.width*2, 0,
        c.width*PIX_PER_STRAND/STRANDS_PER_STRIP*2, 
        c.height*2);
  /*noStroke();
  for (int i = 0; i < c.width; i++) {
    for (int j = 0; j < c.height; j++) {
      fill(c.get(i, j));
      rect(c.width*2 + i**/
}

// For any plugins that might use movies...
void movieEvent(Movie m) {
  m.read();
}

/*int CORR_R = 255;
int CORR_G = 100;
int CORR_B = 100;*/

void draw() {
  background(0, 0, 0);

  long ms = millis();
  
  if (curPlugin == null && ms < startTime + 2000) {
    // Stupid pause to avoid opening hiccups
    pasteCanvas(bg);
    scrapeit();
    return;
  }

  if (curPlugin == null ||
      (modeCycle && ms > startTime + PLUGIN_TIME + FADE_TIME)) {
    try {
      if (curPlugin != null) {
        curPlugin.finish();
      }
      if (recording && curPlugin != null && nextPluginIndex == 0) {
        if (numRecords++ == 5) {
          // Full loop: stop
          exit();
        }
      }
      curPlugin = (EquanPlugin)plugins[nextPluginIndex].getConstructors()[0]
          .newInstance(this, NUM_STRIPS, PIX_PER_STRAND, STRANDS_PER_STRIP);
      startTime = ms;
    } catch (Exception e) {
      println("Exception starting plugin", e);
      e.printStackTrace();
      // We'll try instantiating the next plugin on the next go-round
      return;
    } finally {
      if (modeCycle) {
        nextPluginIndex = (nextPluginIndex + 1) % plugins.length;
      }
    }
  }

  curPlugin.draw();
  
  noTint();
  pasteCanvas(bg);
  
  fill(128, 128, 128);
  rect(0, 0, bg.width*PIX_PER_STRAND/STRANDS_PER_STRIP*2 + 20, bg.height*2 + 10);
  
  if (curPlugin.needsFadeIn && ms < startTime + FADE_TIME) {
    // Fade in
    float alpha = 1.0 - (float)(startTime + FADE_TIME - ms) / FADE_TIME;
    //println("IN ", alpha);
    tint(255, alpha);
    //tint(CORR_R, CORR_G, CORR_B, alpha);
  } else if (modeCycle && ms > startTime + PLUGIN_TIME) {
    // Fade out
    float alpha = 1.0 - (float)(ms - (startTime + PLUGIN_TIME)) / FADE_TIME;
    //println("OUT", alpha);
    tint(255, alpha);
    //tint(CORR_R, CORR_G, CORR_B, alpha);
  }
  pasteCanvas(curPlugin.c);
  noTint();
  
  scrapeit();
  

}

void scrapeit() {
  if (testObserver.hasStrips) {
    registry.startPushing();
    List<Strip> strips = registry.getStrips();
    
    if (recording) {
      List<PixelPusher> pushers = registry.getPushers();
      pushers.get(0).startRecording("canned.dat");
    }
    
    for (int i = 0; i < strips.size(); i++) {
      Strip s = strips.get(i);
      for (int j = 0; j < STRANDS_PER_STRIP; j++) {
        for (int k = 0; k < PIX_PER_STRAND; k++) {
          s.setPixel(get(j, k + i*PIX_PER_STRAND), k + (STRANDS_PER_STRIP-1-j)*PIX_PER_STRAND);
        }
      }
    }
  } else if (curPlugin != null) {
    String s = dragPosX + ", " + dragPosY;
    fill(255);
    text(s, 0, height - 20);
    
    ambientLight(40, 40, 40);
    ambient(255, 255, 255);
    directionalLight(40, 40, 40, 0, 0, -1);
    lightFalloff(1, 0, 0);
    lightSpecular(0, 0, 0);
    shapeMode(CENTER);
    
    if (SPHERE) {
      //float SPHERE_TOP_RADIUS = 6;
      //float SPHERE_TOTAL_RADIUS = 42;

      // Global transform of everything drawn below
      translate(width * 0.374, height * 0.505);
      scale(8, 8, 8);
      translate(20, 0);
      rotateY(dragPosX * PI * 2);
      rotateX(dragPosY * -PI);


      for (int i = 0; i < NUM_STRIPS; i++) {
        for (int j = 0; j < STRANDS_PER_STRIP; j++) {
          for (int k = 0; k < PIX_PER_STRAND; k++) {
            // -20 to 20
            float lat = ((float)k/(PIX_PER_STRAND-1) - 0.5) * PI * 0.7;//k - PIX_PER_STRAND/2 + 0.5;
            // 0 to 15
            float lng = (float)(i * STRANDS_PER_STRIP + j)/(STRANDS_PER_STRIP*NUM_STRIPS) * PI * 2;
            emissive(curPlugin.c.get(j, k + i*PIX_PER_STRAND));
            pushMatrix();
              // Set longitude
              rotateY(lng);
              // Account for central cylinder,
              translate(SPHERE_TOP_RADIUS, 0, 0);
              // Set latitude,
              rotateZ(lat);
              // Draw at equator,
              translate(SPHERE_TOTAL_RADIUS - SPHERE_TOP_RADIUS, 0, 0);
              shape(cyl);
            popMatrix();
          }
        }
      }
    } else {
      // Global transform of everything drawn below
      translate(width * 0.374, height * 0.505);
      scale(8, 8, 8);
      translate(width * dragPosX, height * dragPosY);
      rotateY(-0.05 * -PI * 2);
      rotateX(0.05 * -PI);
      
      for (int i = 0; i < NUM_STRIPS; i++) {
        for (int j = 0; j < STRANDS_PER_STRIP; j++) {
          for (int k = 0; k < PIX_PER_STRAND; k++) {
            emissive(curPlugin.c.get(j, k + i*PIX_PER_STRAND));
            pushMatrix();
              translate(i*STRAND_SPACING, CYL_HEIGHT * k, j*STRAND_SPACING);
              shape(cyl);
            popMatrix();
          }
        }
      }
    }
  }
}


PShape makeCyl(float topRadius, float bottomRadius, float tall, int sides) {
  PShape s = createShape();
  float angle = 0;
  float angleIncrement = TWO_PI / sides;
  s.beginShape(QUAD_STRIP);
  s.noStroke();
  for (int i = 0; i < sides + 1; ++i) {
    s.vertex(topRadius*cos(angle), 0, topRadius*sin(angle));
    s.vertex(bottomRadius*cos(angle), tall, bottomRadius*sin(angle));
    angle += angleIncrement;
  }
  s.endShape();
  s.disableStyle();
  return s;
}




void unuzed() {
  //println("hi", mouseX, mouseY, width, height);
  float mx = (float)mouseX / width;
  float my = (float)mouseY / height;
  
  float cx = mx;
  float cy = my;
  float cz = mx;
  float radius = 0.25;
  float edge = 0.05;
  
  
  Plane base = Plane.XZ;
  
  colorMode(RGB, 1, 1, 1, 1);
  for (int x = 0; x < STRANDS_PER_STRIP; x++) {
    for (int y = 0; y < PIX_PER_STRAND; y++) {
      for (int z = 0; z < 4; z++) {
        color c = color(0, 0, 0, 1);
        
        //base.normal = new Vec3D(mx, my, 0);
        //Plane plane = new Plane(new Vec3D(0.5, 0.5, 0.5), new Vec3D(0.5, 1, 0.5));
        //Plane plane = new Plane(new Triangle3D(Vec3D.ZERO
        /*Plane plane = new Plane(new Vec3D(0.5, 0.5, 0.5), new Vec3D(0.5, 1.5, 0.5).rotateX(mx).rotateZ(my));
        if (plane.classifyPoint(new Vec3D(x/4.0, y/40.0, z/4.0), 0.05) == Plane.Classifier.ON_PLANE) {
          c = color(1, 0, 0);
        } else {
          c = color(0);
        }*/
        float dist = sqrt(pow(x/4.0-cx, 2) + pow(y/40.0-cy, 2) + pow(z/4.0-cz, 2));
        if (dist < radius) {
          c = color(1, 1, 0, 1);
        } else if (dist > radius + edge) {
          c = color(0, 0, 0, 1);
        } else {
          c = color(1, 0, 0, 1);
          float part = 1.0-(dist-radius)/edge;
          c = color(part, part, 0, 1);
        }
        
        set(x, y + z*PIX_PER_STRAND, c);
      }
    }
  }
  /*for (int i = 0; i < 4; i++) {
    set(i, 0, pic.get((int)((mx-0.5)*2.0*pic.width) + i*10, 0, 1, 40));
  }*/

  scrapeit();
}




