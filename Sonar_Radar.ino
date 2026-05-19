#include <Servo.h>

// Ultrasonic Sensor Pins
#define trigPin 8
#define echoPin 9

// Servo Pin
#define servoPin 12

// Buzzer Pin
#define buzzerPin 7

Servo myservo;

long duration;
int distance;

// Function to calculate distance
int calculateDistance() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);

  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);

  digitalWrite(trigPin, LOW);

  duration = pulseIn(echoPin, HIGH);

  distance = duration * 0.034 / 2;

  return distance;
}

void setup() {
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);

  pinMode(buzzerPin, OUTPUT);

  myservo.attach(servoPin);

  Serial.begin(9600);
}

void loop() {

  // Sweep from 15° to 165°
  for (int i = 15; i <= 165; i++) {

    myservo.write(i);
    delay(15);

    distance = calculateDistance();

    // Send data to Processing radar display
    Serial.print(i);
    Serial.print(",");
    Serial.print(distance);
    Serial.print(".");

    // ----- BUZZER CONTROL -----
    if (distance > 0 && distance <= 20) {

      // Faster beeps when object is very close
      int beepDelay = map(distance, 1, 20, 50, 300);

      tone(buzzerPin, 1000); // 1kHz tone
      delay(beepDelay);

      noTone(buzzerPin);
      delay(beepDelay);

    } else {
      noTone(buzzerPin);
    }
  }

  // Sweep back from 165° to 15°
  for (int i = 165; i >= 15; i--) {

    myservo.write(i);
    delay(15);

    distance = calculateDistance();

    Serial.print(i);
    Serial.print(",");
    Serial.print(distance);
    Serial.print(".");

    // ----- BUZZER CONTROL -----
    if (distance > 0 && distance <= 20) {

      int beepDelay = map(distance, 1, 20, 50, 300);

      tone(buzzerPin, 1000);
      delay(beepDelay);

      noTone(buzzerPin);
      delay(beepDelay);

    } else {
      noTone(buzzerPin);
    }
  }
}