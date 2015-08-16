class MidiBursts extends EquanPlugin {

  public MidiBursts(int wd, int ht, int dp) {
    super(wd, ht, dp);

    c.colorMode(HSB, 1);
  }

  float noiseOffset = 0;
  float NOISE_INCR = 0.03;

  int lastNote = 0;
  int lastNoteTime = 0;
  float burstVelocity = 0.0003;

  float fw = (float)w;
  float fd = (float)d;
  float fh = (float)h;

  synchronized void draw() {
    //float hue = noise(noiseOffset/10, noiseOffset, 100);
    float hue = 0;

    // XXX: For now, just choose a random note if there's no last note. This will need to record actual midi events later!
    if (lastNoteTime == 0) {
      lastNote = 35;
      lastNoteTime = millis();
    }

    // get time since lastNote
    int currentTime = millis() - 5000;
    int timeSinceLastNote = currentTime - lastNoteTime;


    // convert note to pixel position
    float x = (lastNote / fd) / (fw - 1);
    float y = (fh / 2) / (fh - 1);
    float z = (lastNote % fd) / (fd - 1);

    // convert time since last note to a radius
    float radius = timeSinceLastNote * burstVelocity;
    float innerRadius = radius - 0.1;

    println(x, y, z, radius);

    for (float i = 0; i < w; i++) {
      for (float j = 0; j < d; j++) {
        for (float k = 0; k < h; k++) {
          float dist = sqrt(pow(i/(w-1) - x, 2) + pow(j/(d-1) - y, 2) + pow(k/(h-1) - z, 2));
          if (dist < radius && dist > innerRadius) {
            c.stroke(hue, 1, 1);
            c.point(i, j*h + k);
          }
          else {
            c.stroke(0, 0, 0);
            c.point(i, j*h + k);
          }
        }
      }
    }
    noiseOffset += NOISE_INCR;
  }
}
