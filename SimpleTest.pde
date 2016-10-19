class SimpleTest extends EquanPlugin {

  int SPEED = 1000;
  long nextMove;
  int curColor;

  public SimpleTest(int wd, int ht, int dp) {
    super(wd, ht, dp);
    c.colorMode(RGB, 255);
    nextMove = millis() + SPEED;
    curColor = 0;
  }
  
  
  synchronized void draw() {
    if (millis() >= nextMove) {
      curColor = (curColor + 1) % 4;

      if (curColor == 0) {
        doit(0, 0, 0);
      } else if (curColor == 1) {
        doit(255, 0, 0);
      } else if (curColor == 2) {
        doit(0, 255, 0);
      } else {
        doit(0, 0, 255);
      }
      
      nextMove = millis() + SPEED;
    }
  }
  void doit(int r, int g, int b) {
    c.background(r, g, b);
  }  
}


