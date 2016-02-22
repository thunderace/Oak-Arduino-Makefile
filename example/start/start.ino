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
  digitalWrite(1, HIGH);   // turn the LED on (HIGH is the voltage level)
  temperature++;
  delay(2000);               // wait for a second
  digitalWrite(1, LOW);    // turn the LED off by making the voltage LOW
  delay(2000);  
}
