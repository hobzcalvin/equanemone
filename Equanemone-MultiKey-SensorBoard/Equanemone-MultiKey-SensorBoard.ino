/*
*/

#include <Keypad.h>
#include <usb_midi.h>

#define LEDPIN 13

#define ROWS 8
#define COLS 8

// Keypad library has a LIST_MAX of 10, but we want all the buttons!!!
#if LIST_MAX < ROWS*COLS
#error LIST_MAX must be >= ROWS*COLS; change it in libraries/Keypad/Keypad.h
#endif

byte rowPins[ROWS] = {3, 4, 5, 6, 7, 8, 9, 10}; //connect to the row pinouts of the kpd
byte colPins[COLS] = {15, 16, 17, 18, 19, 20, 21, 22}; //connect to the column pinouts of the kpd

Keypad* kpd;

void setup() {
  char keys[ROWS*COLS];
  for (int i = 0; i < ROWS*COLS; i++) {
    keys[i] = (char)i;
  }
  kpd = new Keypad(makeKeymap(keys), rowPins, colPins, ROWS, COLS);
  kpd->setDebounceTime(1);
  usbMIDI.begin();
  //Serial.begin(9600);
  pinMode(LEDPIN, OUTPUT);
}

/*unsigned long loopCount = 0;
unsigned long startTime = millis();
String msg = "";*/



void loop() {

  /*loopCount++;
  if ( (millis()-startTime)>1000 ) {
      //Serial.println(loopCount);
      startTime = millis();
      loopCount = 0;
  }*/

  // Fills kpd->key[ ] array with up to LIST_MAX active keys.
  // Returns true if there are ANY active keys.
  if (kpd->getKeys())
  {
    for (int i=0; i<LIST_MAX; i++)   // Scan the whole key list.
    {
      if ( kpd->key[i].stateChanged )   // Only find keys that have changed state.
      {
        switch (kpd->key[i].kstate) {  // Report active key state : IDLE, PRESSED, HOLD, or RELEASED
            case PRESSED:
                //msg = " PRESSED.";
                usbMIDI.sendNoteOn(kpd->key[i].kcode, 127, 0);
                digitalWrite(LEDPIN, HIGH);
                break;
            case RELEASED:
                //msg = " RELEASED.";
                usbMIDI.sendNoteOff(kpd->key[i].kcode, 127, 0);
                digitalWrite(LEDPIN, LOW);
                break;
            /*case HOLD:
                msg = " HOLD.";
                break;
            case IDLE:
                msg = " IDLE.";
                break;*/
        }
        /*Serial.print("Key ");
        Serial.print((byte)kpd->key[i].kchar);
        Serial.print("/");
        Serial.print(kpd->key[i].kcode);
        Serial.println(msg);*/
      }
    }

    // Make sure all new key presses are sent immediately.
    usbMIDI.send_now();
  }
  // There should be nothing to read, but something told us we should do this to discard incoming messages.
  while (usbMIDI.read()) {}
}  // End loop
