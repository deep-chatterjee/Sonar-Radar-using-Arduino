import processing.serial.*; 
import java.awt.event.KeyEvent; 
import java.io.IOException;

Serial myPort; 

// Global Variables
String angle = "0";
String distance = "0";
String data = "";
String noObject = "";
float pixsDistance;
int iAngle = 0;
int iDistance = 0;

void setup() {
  size(1200, 700); // Dynamic layout handles sizing automatically
  smooth();
  
  // Connects directly to your Arduino on COM5 at 9600 baud rate
  myPort = new Serial(this, "COM5", 9600); 
  myPort.bufferUntil('.'); // Waits for the '.' character before triggering serialEvent
  
  println("Processing is listening to COM5...");
}

void draw() {
  // Simulating motion blur and slow fade of the moving radar line
  noStroke();
  fill(0, 12); // Semi-transparent black background creates the "radar trail"
  rect(0, 0, width, height - height * 0.065); 

  // Draw the Radar interface components
  drawRadar(); 
  drawLine();
  drawObject();
  drawText();
}

void serialEvent(Serial myPort) { 
  try {
    // Read string data from COM5 until the period (.)
    data = myPort.readStringUntil('.');
    if (data == null) return;
    
    // Clean up whitespace or newline characters
    data = trim(data);
    if (data.endsWith(".")) {
      data = data.substring(0, data.length() - 1);
    }

    // Split the data packet at the comma (e.g., "90,25")
    int splitIndex = data.indexOf(","); 
    if (splitIndex != -1) {
      angle = data.substring(0, splitIndex); 
      distance = data.substring(splitIndex + 1, data.length()); 
      
      // Safely convert the string values to numbers
      iAngle = int(trim(angle));
      iDistance = int(trim(distance));
    }
  } catch (Exception e) {
    // Keeps Processing running if a partial data packet is received
    println("Error parsing serial data: " + e.getMessage());
  }
}

void drawRadar() {
  pushMatrix();
  translate(width / 2, height - height * 0.074); 
  noFill();
  strokeWeight(2);
  stroke(98, 245, 31);
  
  // Concentric distance grid lines (arcs)
  arc(0, 0, (width - width * 0.0625), (width - width * 0.0625), PI, TWO_PI);
  arc(0, 0, (width - width * 0.27), (width - width * 0.27), PI, TWO_PI);
  arc(0, 0, (width - width * 0.479), (width - width * 0.479), PI, TWO_PI);
  arc(0, 0, (width - width * 0.687), (width - width * 0.687), PI, TWO_PI);
  
  // Angular grid line paths (0 to 180 degrees)
  line(-width / 2, 0, width / 2, 0);
  for (int angleDeg = 30; angleDeg <= 150; angleDeg += 30) {
    line(0, 0, (-width / 2) * cos(radians(angleDeg)), (-width / 2) * sin(radians(angleDeg)));
  }
  popMatrix();
}

void drawObject() {
  pushMatrix();
  translate(width / 2, height - height * 0.074); 
  strokeWeight(9);
  stroke(255, 10, 10); // Glowing Red color for objects in range
  
  // Translates physical distance (cm) into actual pixels on-screen
  pixsDistance = iDistance * ((height - height * 0.1666) * 0.025); 
  
  // Plot target red trace if object is closer than 40cm
  if (iDistance < 40) {
    float xPos = pixsDistance * cos(radians(iAngle));
    float yPos = -pixsDistance * sin(radians(iAngle));
    float xMax = (width - width * 0.505) * cos(radians(iAngle));
    float yMax = -(width - width * 0.505) * sin(radians(iAngle));
    line(xPos, yPos, xMax, yMax);
  }
  popMatrix();
}

void drawLine() {
  pushMatrix();
  strokeWeight(9);
  stroke(30, 250, 60); // Glowing Green Radar Sweeper Line
  translate(width / 2, height - height * 0.074); 
  line(0, 0, (height - height * 0.12) * cos(radians(iAngle)), -(height - height * 0.12) * sin(radians(iAngle))); 
  popMatrix();
}

void drawText() { 
  pushMatrix();
  noObject = (iDistance > 40) ? "Out of Range" : "In Range";
  
  // UI Bottom Information Ribbon
  fill(0);
  noStroke();
  rect(0, height - height * 0.0648, width, height);
  
  // Grid Range Labels
  fill(98, 245, 31);
  textSize(25);
  text("10cm", width - width * 0.3854, height - height * 0.0833);
  text("20cm", width - width * 0.281, height - height * 0.0833);
  text("30cm", width - width * 0.177, height - height * 0.0833);
  text("40cm", width - width * 0.0729, height - height * 0.0833);
  
  // Bottom Dashboard HUD data strings
  textSize(40);
  text("Radar System", width - width * 0.95, height - height * 0.0277);
  text("Angle: " + iAngle + "°", width - width * 0.55, height - height * 0.0277);
  
  if (iDistance < 40) {
    text("Distance: " + iDistance + " cm", width - width * 0.30, height - height * 0.0277);
  } else {
    text("Distance: --", width - width * 0.30, height - height * 0.0277);
  }
  
  // Text angle notations wrapped nicely in a short loop
  textSize(25);
  fill(98, 245, 60);
  
  int[] angles = {30, 60, 90, 120, 150};
  float[] xOffsets = {0.4994, 0.503, 0.507, 0.513, 0.5104};
  float[] yOffsets = {0.0907, 0.0888, 0.0833, 0.07129, 0.0574};
  int[] rotations = {-60, -30, 0, -30, -60};
  
  for (int k = 0; k < angles.length; k++) {
    pushMatrix();
    translate((width - width * xOffsets[k]) + width / 2 * cos(radians(angles[k])), (height - height * yOffsets[k]) - width / 2 * sin(radians(angles[k])));
    rotate(k >= 3 ? radians(rotations[k]) : -radians(rotations[k]));
    text(String.valueOf(angles[k]), 0, 0);
    popMatrix();
  }
  popMatrix();
}
