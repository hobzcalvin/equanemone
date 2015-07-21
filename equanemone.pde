import com.heroicrobot.dropbit.devices.*;
import com.heroicrobot.dropbit.common.*;
import com.heroicrobot.dropbit.discovery.*;
import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.*;

import processing.core.*;
import java.util.*;

boolean SPHERE = false;

int PIX_PER_STRAND = 40;
int STRANDS_PER_STRIP = 8; // "depth" (if non-square, make this smaller than width)
int NUM_STRIPS = 8; // "width"
// Ratio of pixel x/z distance over pixel y distance
int WH_CORRECT = 10;

int WIDTH, HEIGHT, DEPTH;

DeviceRegistry registry;
TestObserver testObserver;
PApplet parent = this;

Img2Opc i2o;

Class[] plugins = {
  //TestEquan.class,
  //Noise.class,
  EchoVideo.class,
  UpDown.class,
  Fire.class,
  Sphere.class,
  SpinVideo.class,
  Planes.class,
  EchoVideo.class,
  Raindrops.class,
  //NewYears.class,
  Terrain.class,
  Fish.class,
  Sweeps.class,
  SpinVideo.class,
  Lava.class,
  Fireflies.class,
  //Leap.class,
  //Midi.class,
};

  
PGraphics bg;
EquanPlugin curPlugin;
int nextPluginIndex = 0;
int numRecords = 0;
long startTime;

float SPHERE_TOP_RADIUS = 6;
float SPHERE_TOTAL_RADIUS = 42;

int FADE_TIME = 1500;
int PLUGIN_TIME = 60000;
float CYL_DIA = 2.5;
float CYL_HEIGHT = SPHERE ? 2: 1.23;
int CYL_DETAIL = 8;
float STRAND_SPACING = 12;

boolean modeCycle = true;
boolean recording = false;
boolean USE_OPC = false;

PShape cyl;
//PShape woman;
boolean clicked = false;

void setup() {
  if (SPHERE) {
    WIDTH = STRANDS_PER_STRIP * NUM_STRIPS;
    HEIGHT = PIX_PER_STRAND;
    DEPTH = 1;
  } else {
    HEIGHT = PIX_PER_STRAND;
    //WIDTH = NUM_STRIPS;
    //DEPTH = STRANDS_PER_STRIP;
    WIDTH = STRANDS_PER_STRIP;
    DEPTH = NUM_STRIPS;
  }
  
  size(1280, 600, P3D);
  registry = new DeviceRegistry();
  testObserver = new TestObserver();
  registry.addObserver(testObserver);
  registry.setAntiLog(true);
  //registry.setAutoThrottle(true);
  
  //woman = loadShape("scylla_2064/scylla_2064.obj");

  background(50, 50, 50);
  colorMode(RGB, 255, 255, 255, 1);

  bg = createGraphics(WIDTH, HEIGHT*DEPTH, JAVA2D);
  bg.beginDraw();
  bg.background(0);
  bg.endDraw();

  frameRate(120);
  
  nextPluginIndex = 0;
  
  startTime = millis();
  
  if (USE_OPC) {
    i2o = new Img2Opc(this, "127.0.0.1", 7890, WIDTH, HEIGHT*DEPTH);
  } else {
    cyl = makeCyl(CYL_DIA/2, CYL_DIA/2, CYL_HEIGHT, CYL_DETAIL);
  }
  
}

int lastX;
int lastY;
/*float mainPosX = -0.00546878;
float mainPosY = -0.19333327;
float shiftPosX = 0.010156246;
float shiftPosY = -0.111666664;*/
float mainPosX = -0.025781278;
float mainPosY = -0.0966666;
float shiftPosX = 0.0078124884;
float shiftPosY = 0.76999956;
float altPosX = 1;
float altPosY = 1;
void mousePressed() {
  lastX = mouseX;
  lastY = mouseY;
}
void mouseDragged() {
  float xmove = (float)(mouseX - lastX) / width;
  float ymove = (float)(mouseY - lastY) / height;
  mousePressed();
  
  if (keyPressed && keyCode == SHIFT) {
    shiftPosX += xmove;
    shiftPosY += ymove;
  } else if (keyPressed && keyCode == ALT) {
    altPosX += xmove;
    altPosY += ymove;
  } else {
    mainPosX += xmove;
    mainPosY += ymove;
  }
  //dragPosX = oldDPX + (float)(mouseX - dragStartX)/width;
  //dragPosY = oldDPY + (float)(mouseY - dragStartY)/height;
  //println("DP: " + dragPosX + ", " + dragPosY);
  println("POSs", mainPosX, mainPosY, shiftPosX, shiftPosY, altPosX, altPosY);
}
void mouseClicked() {
  if (keyPressed) {
    if (curPlugin != null) {
      curPlugin.mouseClicked();
    }
  } else {
    clicked = true;
  }
}

void pasteCanvas(PGraphics can) {
  PImage c = can.get();
  image(c, 0, 0);
  // No need for this when we have 3D! Right?
  /*image(c, c.width + 10, 0,
        c.width*2*WH_CORRECT,
        c.height*2);*/
  //noFill();
  //stroke(128, 128, 128);
  // Could do more stuff here to outline the draw areas, but who cares?
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
/*
int CORR_R = 255;
int CORR_G = 100;
int CORR_B = 100;*/

void draw() {
  background(0, 0, 0);

  long ms = millis();
  
  if (curPlugin == null && ms < startTime + 10000) {
    // Stupid pause to avoid opening hiccups
    pasteCanvas(bg);
    scrapeit();
    return;
  }

  if (curPlugin == null ||
      (modeCycle && ms > startTime + PLUGIN_TIME + FADE_TIME) ||
      clicked) {
    clicked = true;
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
          .newInstance(this, WIDTH, HEIGHT, DEPTH);
      startTime = ms;
    } catch (Exception e) {
      println("Exception starting plugin", e);
      e.printStackTrace();
      // We'll try instantiating the next plugin on the next go-round
      return;
    } finally {
      if (modeCycle || clicked) {
        nextPluginIndex = (nextPluginIndex + 1) % plugins.length;
      }
    }
    clicked = false;
  }

  curPlugin.draw();
  
  noTint();
  pasteCanvas(bg);
  
  //fill(128, 128, 128);
  //rect(0, 0, bg.width*HEIGHT/DEPTH*2 + 20, bg.height*2 + 10);
  
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
    
    if (strips.size() != NUM_STRIPS) {
      println("strips.size() != NUM_STRIPS; "+strips.size()+" != "+NUM_STRIPS+"; THAT'S BAD!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }
    for (int i = 0; i < NUM_STRIPS; i++) {
      Strip s = strips.get(i);
      for (int j = 0; j < STRANDS_PER_STRIP; j++) {
        for (int k = 0; k < PIX_PER_STRAND; k++) {
          color c;
          if (SPHERE) {
            c = get(i*STRANDS_PER_STRIP + j, k);
          } else {
            //c = get(i, k + j*PIX_PER_STRAND);
            c = get(j, k + i*PIX_PER_STRAND);
          }
          s.setPixel(c, k + (STRANDS_PER_STRIP-1-j)*PIX_PER_STRAND);
        }
      }
    }
  } else if (curPlugin != null) {
    
    if (USE_OPC) {
      i2o.sendImg(curPlugin.c);
    } else {
      /*String s = dragPosX + ", " + dragPosY;
      fill(255);
      text(s, 0, height - 20);*/
      
      
      ambientLight(40, 40, 40);
      ambient(255, 255, 255);
      directionalLight(40, 40, 40, 0, 0, -1);
      lightFalloff(1, 0, 0);
      lightSpecular(0, 0, 0);
      shapeMode(CENTER);
      
      //shape(woman);
      
      if (SPHERE) {
        //float SPHERE_TOP_RADIUS = 6;
        //float SPHERE_TOTAL_RADIUS = 42;
  
        // Global transform of everything drawn below
        translate(width * 0.374, height * 0.505);
        scale(8, 8, 8);
        translate(20, 0);
        rotateY(mainPosX * PI * 2);
        rotateX(mainPosY * -PI);
  
  
        for (int i = 0; i < WIDTH; i++) {
          for (int k = 0; k < HEIGHT; k++) {
            // -20 to 20
            float lat = ((float)k/(HEIGHT-1) - 0.5) * PI * 0.7;
            // 0 to 15
            float lng = (float)i/WIDTH * PI * 2;
            emissive(curPlugin.c.get(i, k));
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
      } else {
        // Global transform of everything drawn below
        translate(width * 0.374 * altPosX, height * 0.505 * altPosY);
        float scl = 4 + shiftPosY * 4;
        scale(scl, scl, scl);
        translate(width * mainPosX / 2, height * mainPosY / 2);
        rotateY((shiftPosX - 0) * -PI * 2);
        rotateX(0.05 * -PI);
        
        for (int i = 0; i < WIDTH; i++) {
          for (int j = 0; j < DEPTH; j++) {
            for (int k = 0; k < HEIGHT; k++) {
              emissive(curPlugin.c.get(i, k + j*HEIGHT));
              pushMatrix();
                rotateX(-0.3);
                translate(i*STRAND_SPACING, CYL_HEIGHT * k, j*STRAND_SPACING);
                shape(cyl);
              popMatrix();
            }
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
  for (int x = 0; x < DEPTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {
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
        
        set(x, y + z*HEIGHT, c);
      }
    }
  }
  /*for (int i = 0; i < 4; i++) {
    set(i, 0, pic.get((int)((mx-0.5)*2.0*pic.width) + i*10, 0, 1, 40));
  }*/

  scrapeit();
}




