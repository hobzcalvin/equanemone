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
        c.background(0, 0, 0);
      } else if (curColor == 1) {
        c.background(255, 0, 0);
      } else if (curColor == 2) {
        c.background(0, 255, 0);
      } else {
        c.background(0, 0, 255);
      }
      
      nextMove = millis() + SPEED;
    }
  }
  
}
