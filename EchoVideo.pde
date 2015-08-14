import processing.video.*;

import java.util.LinkedList;

class EchoVideo extends EquanPlugin {
  
  Movie mov;
  
  // Number of frames delayed between depth planes
  public static final int FRAME_DELAY = 15;
  // Fraction of movie that should be reserved from top and bottom for wiggle
  final float WIGGLE_SIZE = 0.15;
  // How fast wiggle dissipates. Lower number makes decay take longer.
  final float WIGGLE_DECAY = 1600.0;
  final int WIGGLE_DECAY_POWER = 8;
  // Speed of wiggle motion
  final float WIGGLE_SPEED = 0.015;
  LinkedList<PImage> frames;
  
  public EchoVideo(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    needsFadeIn = true;
    
    frames = new LinkedList<PImage>();
    
    String f = this.randomVideo();
    println("Loading", f);
    mov = new Movie(parent, f);// "2059820.mp4");
    mov.loop();
  }

  synchronized void draw() {
    PImage frame = mov.get();
    if (frame.width == 0 || frame.height == 0) {
      // This never happens on Mac, but trying to resize a 0x0 frame on Windows and Linux crashes.
      return;
    }
    
    /*
    for wiggle testing: a black line on white background on all frames.
    
    PGraphics graphics = createGraphics(frame.width, frame.height, JAVA2D);
    graphics.colorMode(RGB, 255);
    graphics.beginDraw();
    graphics.background(255, 255, 255);
    graphics.stroke(0, 0, 0);
    graphics.strokeWeight(20);
    graphics.line(0, graphics.height/2, graphics.width, graphics.height/2);
    graphics.endDraw();
    frame = graphics.get();*/
    
    
    long[][] touched = getMidiLastTouched();
    long millis = millis();
    int grabHeight = int((float)frame.height * (1.0 - 2.0*WIGGLE_SIZE));
    
    
    // Resize to width, but keep full height resolution for better wiggle
    frame.resize(w, frame.height);
    // Add new frame to the frame buffer
    frames.push(frame);
    
    // Display frames for each depth plane
    for (int i = 0; i < d; i++) {
      // Don't go off end of the list
      if (frames.size() > i*FRAME_DELAY) {
        if (i == d-1) {
          // "bottom" layer is the last to use this frame, so pop if off
          frame = frames.removeLast();
        } else {
          // Other layers use their current frame
          frame = frames.get(i*FRAME_DELAY);
        }
      } else {
        // We don't want frames to suddenly appear at successive layers,
        // so just use the latest frame if nothing else.
        frame = frames.getLast();
      }
      
      // Display the chosen frame, wiggling columns of recently-touched tentacles.      
      for (int j = 0; j < w; j++) {
        float msSinceTouch = millis - touched[j][i];
        
        // A fraction used to suppress the bounce over time.
        // Starts at cos(0)=1 and is limited to cos(pi/2)=0.
        // Because floating-point cosine doesn't work too great, go a little beyond pi/2 (negative) and clamp it above zero. Groan.
        float decay = max(cos(min(msSinceTouch/WIGGLE_DECAY, PI/2.0+0.0001)), 0);
        // This gives us the bounce, based on msSinceTouch
        // (Processing docs claim it's broken to call sin() outside the range [0, 2pi] but it seems okay here?)
        float sine = sin(msSinceTouch * WIGGLE_SPEED);
                     
        int grabY = int(
          // y-position to grab grabHeight from the frame is the frame's height,
          float(frame.height)
          // times the WIGGLE_SIZE fraction,
          * WIGGLE_SIZE
          // Times a value between 0 and 2 (based on sine) with decay
          * (1.0 + sine * decay)
        );
        
        c.image(frame.get(j, grabY, 1, grabHeight), j, i*h, 1, h);
      }
    }

    /*  OLD STYLE: no wiggle. would be faster.
    // Resize current frame to size of frames in the display
    frame.resize(w, h);
    
    // Draw the current frame on "top" layer
    c.image(frame, 0, 0);
    
    // Add the frame to the front of the linkedlist
    frames.push(frame);
    
    // On layers "below", use frames from the list
    for (int i = 1; i < d; i++) {
      // Don't go off end of the list
      if (frames.size() > i*FRAME_DELAY) {
        if (i == d-1) {
          // "bottom" layer is the last to use this frame, so pop if off
          frame = frames.removeLast();
        } else {
          // Other layers use their current frame
          frame = frames.get(i*FRAME_DELAY);
        }
      } else {
        // We don't want frames to suddenly appear at successive layers,
        // so just use the latest frame if nothing else.
        frame = frames.getLast();
      }
      c.image(frame, 0, i*h);
    }
    */

  }


  synchronized void finish() {
    mov.stop();
    mov = null;
  }
}
