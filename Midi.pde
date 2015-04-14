import themidibus.*; //Import the library

/*
TO MAKE THIS WORK:
- Sketch > Import Library > Add Library > themidibus

To get a quick and simple MIDI source:
- download/install vmpk
- Audio Midi Setup > Midi window > IAC Driver > "Device is online" checked
- add a port in IAC Driver properties: "ProcessingPort"
- to hear the MIDI produced, maybe start up GarageBand too

I can play notes on vmpk, hear them in GarageBand, and see the plugin react 
to them in Processing. Neat!

*/
  MidiBus myBus; // The MidiBus
  
Midi theMidi;

class Midi extends EquanPlugin {
  
  
  public Midi(int wd, int ht, int dp) {
    super(wd, ht, dp);
    theMidi = this;
    
    MidiBus.list();
    myBus = new MidiBus(parent, "ProcessingPort", -1);
    
    c.colorMode(HSB, 1);
  }
  
  synchronized void draw() {
    
    

  }
  
  
  void noteOn(int channel, int pitch, int velocity) {
    // Receive a noteOn
    println();
    println("Note On:");
    println("--------");
    println("Channel:"+channel);
    println("Pitch:"+pitch);
    println("Velocity:"+velocity);
    
    c.stroke(random(1), 0.5, 1);
    
    c.point(pitch % w, pitch / w);
  }  

  void noteOff(int channel, int pitch, int velocity) {
    // Receive a noteOn
    println();
    println("Note On:");
    println("--------");
    println("Channel:"+channel);
    println("Pitch:"+pitch);
    println("Velocity:"+velocity);
    
    c.stroke(0);
    c.point(pitch % w, pitch / w);
  }  



}

void noteOn(int channel, int pitch, int velocity) {
  theMidi.noteOn(channel, pitch, velocity);
}
void noteOff(int channel, int pitch, int velocity) {
  theMidi.noteOff(channel, pitch, velocity);
}
