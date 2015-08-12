

class Midi extends EquanPlugin {
  
  
  public Midi(int wd, int ht, int dp) {
    super(wd, ht, dp);
    
    c.colorMode(HSB, 1, 1, 1, 1);
    c.strokeWeight(1);
  }
  
  synchronized void draw() {
    

  }
  
  
  void noteOn(int channel, int pitch, int velocity, int tentacleX, int tentacleZ) {
    // Receive a noteOn
    /*println();
    println("Note On:");
    println("--------");
    println("Channel:"+channel);
    println("Pitch:"+pitch);
    println("Velocity:"+velocity);*/
    
    //println("TUBE", tentacleX, tentacleZ);
    
    c.stroke(random(1), (float)velocity / 128, 1, 1);
    
    //c.point(pitch % w, pitch / w);
    
    c.line(tentacleX, tentacleZ*h, tentacleX, tentacleZ*h + h -1);
  }  

  void noteOff(int channel, int pitch, int velocity, int tentacleX, int tentacleZ) {
    // Receive a noteOff
    /*println();
    println("Note Off:");
    println("--------");
    println("Channel:"+channel);
    println("Pitch:"+pitch);
    println("Velocity:"+velocity);*/
    
    c.stroke(0, 0, 0, 1);
    //c.line(tentacleX, tentacleZ*h, tentacleX, tentacleZ*h + h -1);
    //c.point(pitch % w, pitch / w);
  }  



}


