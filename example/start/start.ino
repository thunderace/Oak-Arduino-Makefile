#include <Arduino.h>
#include "myLib.h"

int temperature = 1;
void setup() {                
  // initialize the digital pin as an output.
  pinMode(1, OUTPUT); //LED on Oak
  Particle.variable("temperature", temperature);
}

// the loop routine runs over and over again forever:
void loop() {
  if (temperature > 250) {
    temperature = 0;
  }
  temperature += 1;
  delay(1000);  
}
