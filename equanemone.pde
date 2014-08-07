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
long startTime;

int FADE_TIME = 1500;
int PLUGIN_TIME = 30000;

boolean modeCycle = true;
boolean recording = true;


void setup() {
  size(600, 400, P3D);
  registry = new DeviceRegistry();
  testObserver = new TestObserver();
  registry.addObserver(testObserver);
  registry.setAntiLog(true);

  background(#7f7f7f);
  colorMode(RGB, 255, 255, 255, 1);

  bg = createGraphics(NUM_STRIPS, PIX_PER_STRAND*STRANDS_PER_STRIP, JAVA2D);
  bg.beginDraw();
  bg.background(0);
  bg.endDraw();

  frameRate(120);
  
  nextPluginIndex = 0;
  
  startTime = millis();
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
        // Full loop: stop
        exit();
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
  
  /*long ms = millis();
  if (curPlugin != null) {
    curPlugin.draw();
  }
  if (nextPlugin != null) {
    nextPlugin.draw();
  }
  
  if (ms > nextTransition - FADE_TIME) {
    float curAlpha =
      max(float(ms - (nextTransition - FADE_TIME)) / FADE_TIME, 1);
    println("CUR", curAlpha);
    tint(255, 1);
  } else {
    noTint();
  }
  pasteCanvas(curPlugin.c);
  if (ms > nextTransition - FADE_TIME) {
    float curAlpha =
      max(float(ms - (nextTransition - FADE_TIME)) / FADE_TIME, 1);
    println("CUR", curAlpha);
    tint(255, 1);
  }
  pasteCanvas(curPlugin.c);
  
  
  
  
  
  
  if (curPlugin == null) {
    return;
  }
  
  curPlugin.draw();


  scrapeit();
  
  if (millis() > target) {
    println("TARGET!!!!!!!!!");
    curPlugin.finish();
    curPlugin = null;
  }*/
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
  }
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




