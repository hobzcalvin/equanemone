



import com.heroicrobot.dropbit.devices.*;
import com.heroicrobot.dropbit.common.*;
import com.heroicrobot.dropbit.discovery.*;
import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.*;

import processing.core.*;
import java.util.*;

import themidibus.*;



// COMMON SETTINGS

// List of plugins to cycle through, in order. Duplicates allowed.
Class[] plugins = {
  RainbowGoo.class,
  MidiBursts.class,
  Starfield.class,
  MorePlanes.class,
  //TennisBalls.class,
  //KineticRain.class,
  EchoVideo.class,
  Lava.class,
  Fireflies.class,
  
  
  Fish.class,
  
  //OneForAll.class,
//  SimpleTest.class,
  //SimpleMidi.class,
  //TestEquan.class,
  //Noise.class,
  EchoVideo.class,
  UpDown.class,
  Fire.class,
  Sphere.class,
  SpinVideo.class,
  Planes.class,
  
  Raindrops.class,
  //NewYears.class,
  Terrain.class,
  
  Sweeps.class,
  SpinVideo.class,
  
  //Leap.class,
  

};

final int PIX_PER_STRAND = 50; // "height"
final int STRANDS_PER_STRIP = 8; // "depth" (if non-square, make this smaller than width)
final int NUM_STRIPS = 8; // "width"
// Hacky way to turn on two-pusher, half-strip mode. Set to 1 for normal mode.
final int STRIP_DIVIDER = 2;
// Each strand goes down and then up: first pixel is on top, last is below it, etc.
final boolean SNAKE_MODE = true;

// Time a plugin fades in/out (if needsFadeIn is set true, the default)
final int FADE_TIME = 1500;
// Time to show each plugin if modeCycle is true
final int PLUGIN_TIME = 60000;
// Cycle modes automatically (clicking always cycles modes)
final boolean modeCycle = true;
// Recording starts when this number of pushers are detected, to ~/canned{N}.dat, or never if zero.
final int NUM_RECORDING = 0;
// Instead of local simulator, send to a local OpenPixelControl server
final boolean USE_OPC = false;

final int OFF_HOUR = -1;
final int OFF_MINUTE = -1;

/*
To get a quick and simple MIDI source:
- download/install vmpk
- Audio Midi Setup > Midi window > IAC Driver > "Device is online" checked
- add a port in IAC Driver properties: "ProcessingPort"
- to hear the MIDI produced, maybe start up GarageBand too
- set MIDI_IN_PORT below to "ProcessingPort"

I can play notes on vmpk, hear them in GarageBand, and see the plugin react 
to them in Processing. Neat!
*/

final String MIDI_IN_PORT = "Teensy MIDI";

// For now, we don't care about note-off events.
final boolean MIDI_IGNORE_OFFS = true;









// LESS COMMON SETTINGS (plugin developers can probably stop here!!!!!!)

final boolean SPHERE = false;

// Ratio of pixel x/z distance over pixel y distance
final int WH_CORRECT = 10;

final float SPHERE_TOP_RADIUS = 6;
final float SPHERE_TOTAL_RADIUS = 42;

final float CYL_DIA = 2.5;
final float CYL_HEIGHT = SPHERE ? 2: 1.23;
final int CYL_DETAIL = 8;
final float STRAND_SPACING = 12;






// VARS

int WIDTH, HEIGHT, DEPTH;
long[][] lastTouched;

DeviceRegistry registry;
TestObserver testObserver;
PApplet parent = this;

MidiBus midiBus;
Img2Opc i2o;

PGraphics bg;
EquanPlugin curPlugin;
int nextPluginIndex = 0;
// -1 if no recording started; otherwise number of completed loops through the plugins array
int numRecords = -1;
long startTime;

PShape cyl;
boolean clicked = false;

int lastX;
int lastY;
// Seed these with initial values that have worked well for me at the current window size
float mainPosX = -0.035781275;
float mainPosY = -0.09833326;
float shiftPosX = -0.014843752;
float shiftPosY = 0.16333339;
float altPosX = 1.0867198;
float altPosY = 0.6900003;





// MAIN SETUP FUNCTION

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
  
  size(1200, 600, P3D);
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
  
  //MidiBus.list();
  midiBus = new MidiBus(this, MIDI_IN_PORT, -1);
  
  lastTouched = new long[WIDTH][DEPTH];
  for (int i = 0; i < WIDTH; i++) {
    for (int j = 0; j < DEPTH; j++) {
      lastTouched[i][j] = 0;
    }
  }
}

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



// MAIN DRAW FUNCTION

void draw() {
  background(0, 0, 0);

  long ms = millis();
  
  if ((curPlugin == null && ms < startTime + 100) ||
      // Also wait to load first plugin if we want to record but haven't started yet
      (NUM_RECORDING > 0 && numRecords < 0)) {
    // Stupid pause to avoid opening hiccups
    pasteCanvas(bg);
    scrapeit();
    return;
  }

  if (curPlugin == null ||
      (modeCycle && ms > startTime + PLUGIN_TIME + FADE_TIME) ||
      clicked) {
    checkTimedExit();
    
    clicked = true;
    try {
      if (curPlugin != null) {
        curPlugin.finish();
      }
      if (numRecords > 0 && curPlugin != null && nextPluginIndex == 0) {
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
  
  // XXX: Hack that makes futher 2D drawing on top of existing 3D drawing work. Not sure why/what this might break.
  hint(DISABLE_DEPTH_TEST);
  camera();
  noLights();
  
  simulateMidi(false);
  
  // Last bit of the hack.
  hint(ENABLE_DEPTH_TEST);


  //println(frameRate, '.');
}



void checkTimedExit() {
  // XXX: Won't handle midnight boundary nicely.
  if (OFF_HOUR >= 0 && OFF_MINUTE >= 0) {
    int off_minutes = OFF_HOUR*60 + OFF_MINUTE;
    int cur_minutes = hour()*60 + minute();
    // Exit if the time is equal to OFF_* or up to 5 minutes after
    if (cur_minutes >= off_minutes && cur_minutes < off_minutes + 5) {
      pasteCanvas(bg);
      scrapeit();
      exit();
    }
  }
}



// MIDI STUFF

class MidiEvent {
  long time;
  int channel;
  int pitch;
  int velocity;
  boolean on;
  int tentacleX;
  int tentacleZ;
  
  public MidiEvent (int c, int p, int v, boolean o, int tx, int tz) {
    time = millis();
    channel = c;
    pitch = p;
    velocity = v;
    on = o;
    tentacleX = tx;
    tentacleZ = tz;
    
    fireEvent();
  }
  public MidiEvent(int c, int p, int v, boolean o) {
    time = millis();
    channel = c;
    pitch = p;
    velocity = v;
    on = o;
    tentacleX = -1;
    tentacleZ = -1;
    
    fireEvent();
  }
  
  void fireEvent() {
    if (curPlugin != null) {
      if (on) {
        curPlugin.noteOn(channel, pitch, velocity, tentacleX, tentacleZ);
      } else {
        curPlugin.noteOff(channel, pitch, velocity, tentacleX, tentacleZ);
      }
    }
    
    addMidiEvent(this);
  }
}

long MIDI_TIMEOUT = 5000;

LinkedList<MidiEvent> recentMidiEvents = new LinkedList<MidiEvent>();
void addMidiEvent(MidiEvent m) {
  // add it to the linked list and remove stale ones.
  recentMidiEvents.addFirst(m);
  
  if (m.tentacleX != -1 && m.tentacleZ != -1) {
    lastTouched[m.tentacleX][m.tentacleZ] = millis();
  }
}

long[][] getMidiLastTouched() {
  return lastTouched;
}


LinkedList<MidiEvent> getRecentMidiEvents() {
  while (recentMidiEvents.size() > 0) {
    MidiEvent old = recentMidiEvents.removeLast();
    if (old.time > millis() - MIDI_TIMEOUT) {
      // We've removed a not-expired event; put it back and break
      recentMidiEvents.addLast(old);
      //println("valid event!");
      break;
    } else {
      //println("stale event.");
    }
  }
  return recentMidiEvents;
}

void noteOn(int channel, int pitch, int velocity) {
  if (pitch < WIDTH*DEPTH) {
    //println("on", WIDTH - 1 - pitch % WIDTH, pitch / WIDTH);
    new MidiEvent(channel, pitch, velocity, true, WIDTH - 1 - pitch % WIDTH, pitch / WIDTH);//pitch % WIDTH, pitch / WIDTH);
  } else {
    new MidiEvent(channel, pitch, velocity, true, -1, -1);
  }
}
void noteOff(int channel, int pitch, int velocity) {
  if (MIDI_IGNORE_OFFS) {
    return;
  }
  if (pitch < WIDTH*DEPTH) {
    new MidiEvent(channel, pitch, velocity, false, WIDTH - 1 - pitch % WIDTH, pitch / WIDTH);//pitch % WIDTH, pitch / WIDTH);
  } else {
    new MidiEvent(channel, pitch, velocity, false, -1, -1);
  }
}



/*

simpler system

void noteOn(int channel, int pitch, int velocity) {
  if (curPlugin != null) {
    if (pitch < WIDTH*DEPTH) {
      curPlugin.noteOn(channel, pitch, velocity, pitch % WIDTH, pitch / WIDTH);
    } else {
      curPlugin.noteOn(channel, pitch, velocity, -1, -1);
    }
  }
}
void noteOff(int channel, int pitch, int velocity) {
  if (curPlugin != null) {
    if (pitch < WIDTH*DEPTH) {
      curPlugin.noteOff(channel, pitch, velocity, pitch % WIDTH, pitch / WIDTH);
    } else {
      curPlugin.noteOff(channel, pitch, velocity, -1, -1);
    }
  }
}*/

int midiSimSize = 4;
int midiSimSpacing = 10;
int midiSimFingerSize = 8;
void simulateMidi(boolean moved) {
  fill(255, 255, 255, 0.5);
  noStroke();
  for (int i = 1; i <= WIDTH; i++) {
    for (int j = 1; j <= DEPTH; j++) {
      int x = width - i*midiSimSpacing;
      int y = height - j*midiSimSpacing;
      if (moved) {
        if (dist(mouseX, mouseY, x, y) <= midiSimFingerSize/2) {
          noteOn(0, i-1 + (j-1)*WIDTH, 128);
          noteOff(0, i-1 + (j-1)*WIDTH, 128);
          fill(255, 0, 0, 1);
          ellipse(x, y, midiSimSize, midiSimSize);
        }
      } else {
        ellipse(x, y, midiSimSize, midiSimSize);
      }
    }
  }
  
  if (!moved && mouseX > width - WIDTH*midiSimSpacing - midiSimFingerSize &&
      mouseY > height - DEPTH*midiSimSpacing - midiSimFingerSize) {
     ellipse(mouseX, mouseY, midiSimFingerSize, midiSimFingerSize);
  }
  
  fill(255, 255, 255, 1);
}

void mouseMoved() {
  simulateMidi(true);
}


// Indexed like: stripPixelXY[strip][pixel][0 for x on canvas, 1 for y]
int[][][] stripPixelXY = null;

void scrapeit() {

  if (testObserver.hasStrips) {
    registry.startPushing();
    List<Strip> strips = registry.getStrips();
    
    if (NUM_RECORDING > 0 && numRecords < 0) {
      List<PixelPusher> pushers = registry.getPushers();
      //pushers.get(0).startRecording("canned.dat");
      if (pushers.size() == NUM_RECORDING) {
        for (int i = 0; i < pushers.size(); i++) {
          pushers.get(i).startRecording("canned"+i+".dat");
        }
        numRecords = 0;
      }
    }
    
    if (stripPixelXY == null || stripPixelXY.length != strips.size()) {
      // Build the map (as expensively as you like!)
      stripPixelXY = new int[strips.size()][][];
      for (int i = 0; i < stripPixelXY.length; i++) {
        stripPixelXY[i] = new int[STRANDS_PER_STRIP/STRIP_DIVIDER*PIX_PER_STRAND][];
        int xStart = i < 8 ? 4 : 0;
        int yStart = (i%8) * PIX_PER_STRAND;
        for (int j = 0; j < stripPixelXY[i].length; j++) {
          stripPixelXY[i][j] = new int[2];
          int planeX = xStart + j / PIX_PER_STRAND;
          int planeY = j % PIX_PER_STRAND;
          if (SNAKE_MODE) {
            planeY = planeY >= PIX_PER_STRAND / 2 ? (PIX_PER_STRAND - planeY)*2 - 1 : 2*planeY;
          }
          stripPixelXY[i][j][0] = planeX;
          stripPixelXY[i][j][1] = yStart + planeY;
        }
      }
      /*
      println("built array");
      for (int i = 0; i < stripPixelXY.length; i++) {
        String s = "";
        for (int j = 0; j < stripPixelXY[i].length; j++) {
          s += Arrays.toString(stripPixelXY[i][j]);
          if (j % PIX_PER_STRAND == PIX_PER_STRAND - 1) {
            s += "\n    ";
          }
        }
        println(i, ":", s);
      }
      */
    }    
    /*if (strips.size() != NUM_STRIPS * STRIP_DIVIDER) {
      println("strips.size() != NUM_STRIPS; "+strips.size()+" != "+NUM_STRIPS+"*"+STRIP_DIVIDER+"; THAT'S BAD!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }*/
    

    //println(strips.size(), '!');
    
    for (int i = 0; i < strips.size(); i++) {
      Strip s = strips.get(i);
      
      for (int j = 0; j < stripPixelXY[i].length; j++) {
        s.setPixel(get(stripPixelXY[i][j][0], stripPixelXY[i][j][1]), j);
      }
      
      
      /*
      // XXX: Hack for now; what's the real best logic?
      //int curDivider = i >= NUM_STRIPS ? 2 : 1;
      int curDivider = i / NUM_STRIPS + 1;
      println("curDiv "+curDivider+", "+i+", "+strips.size()+", "+NUM_STRIPS+", "+STRIP_DIVIDER);
      for (int j = 0; j < STRANDS_PER_STRIP / STRIP_DIVIDER; j++) {
        for (int k = 0; k < PIX_PER_STRAND; k++) {
          
          color c;
          if (SPHERE) {
            c = get(i*STRANDS_PER_STRIP + j, k);
          } else {
            //c = get(i, k + j*PIX_PER_STRAND);
            c = get(j + STRANDS_PER_STRIP * (curDivider-1), (SNAKE_MODE ? (k >= PIX_PER_STRAND / 2 ? (PIX_PER_STRAND - k)*2 - 1 : k*2) : k) + i * PIX_PER_STRAND / curDivider);
          }
          s.setPixel(c, k + (STRANDS_PER_STRIP/STRIP_DIVIDER - 1 - j)*PIX_PER_STRAND);
          
        }
      }
      */
    }
  } else if (curPlugin != null) {
    
    if (USE_OPC) {
      i2o.sendImg(curPlugin.c);
    } else {
           
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




