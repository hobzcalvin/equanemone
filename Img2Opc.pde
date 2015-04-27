import processing.core.*;
import processing.net.*;


public class Img2Opc /*extends PApplet implements PConstants*/ {
  PApplet parent;
  int dispWidth;
  int dispHeight;
  PImage resizedFrame;
  int srcx, srcy, srcw, srch;
  byte[] opcData;
  Client client;
  byte[] gamma;
  
  final static int HEADER_SIZE = 4;

  public Img2Opc(PApplet parent, String host, int port, int w, int h) {
    this.parent = parent;
    dispWidth = w;
    dispHeight = h;

    gamma = new byte[256];
    for (int i = 0; i < 256; i++) {
      if (true) {
        gamma[i] = (byte)(Math.pow((float)(i) / 255.0, 2.5) * 255.0 + 0.5);
      } else {
        gamma[i] = (byte)(i);
      }
    }

    resizedFrame = new PImage(dispWidth, dispHeight, RGB);

    int numBytes = dispWidth * dispHeight * 3;
    opcData = new byte[4 + numBytes];
    // Channel: 0
    opcData[0] = 0;
    // Command: 0
    opcData[1] = 0;
    // numBytes high and low
    opcData[2] = (byte)((numBytes >> 8) & 0xFF);
    opcData[3] = (byte)(numBytes & 0xFF);

    client = new Client(parent, host, port);
    // The server will hang up after a short period of inactivity.
    // Send a blank image and hope sendImg() is called soon.
    sendImg(new PImage(dispWidth, dispHeight));
  }

  public PImage sendImg(PImage m) {
    m.loadPixels();
    for (int x = 0; x < dispWidth; x++) {
      for (int y = 0; y < dispHeight; y++) {
        int c = m.pixels[x + (dispHeight - y - 1) * dispWidth];
        int pixelPos = HEADER_SIZE + 3 * ((dispWidth - x - 1) * dispHeight + y);
        opcData[pixelPos + 0] = gamma[(byte)(c >> 16 & 0xFF) & 0xFF];
        opcData[pixelPos + 1] = gamma[(byte)(c >> 8  & 0xFF) & 0xFF];
        opcData[pixelPos + 2] = gamma[(byte)(c >> 0  & 0xFF) & 0xFF];
      }
    }
    
    if (client != null) {
      if (client.output != null) {
        try {
          client.output.write(opcData);
          client.output.flush();
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
    }

    return resizedFrame;
  }
}
