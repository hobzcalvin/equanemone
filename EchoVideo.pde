import processing.video.*;

import java.util.LinkedList;

class EchoVideo extends EquanPlugin {
  
  Movie mov;
  
  public static final int FRAME_DELAY = 15;
  LinkedList<PImage> frames;
  
  public EchoVideo(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    needsFadeIn = true;
    
    frames = new LinkedList<PImage>();
    
    mov = new Movie(parent, "loopingd.mp4");
    mov.loop();
  }

  synchronized void draw() {
    PImage frame = mov.get();
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
  }
}
