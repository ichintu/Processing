/**
 * Displays values coming from an MCP-3050 gyro connected to Arduino
 */

import processing.serial.*;

Serial myPort;  // Create object from Serial class

int temp = 0;
int x = 0;
int y = 0; 
int z = 0; 

int lf = 10; // 10 is '\n' in ASCII
byte[] inBuffer = new byte[50];

PFont font;


void setup() 
{
  size(600, 600);
  println(Serial.list());
  myPort = new Serial(this, "COM7", 9600);  

  // The font must be located in the sketch's 
  // "data" directory to load successfully
  font = loadFont("TimesNewRomanPS-BoldMT-36.vlw"); //CourierNew36
}


void draw() {
  if (myPort.available() > 0) {
    if (myPort.readBytesUntil(lf, inBuffer) > 0) {
      String inputString = new String(inBuffer);
      String [] inputStringArr = split(inputString, ',');

      temp = int(inputStringArr[0]);
      x = int(inputStringArr[1]);
      y = int(inputStringArr[2]);
      z = int(inputStringArr[3]);
    }
  }

  background(#000000);

  int R = 0;
  int G = 255;
  int B = 0;
  color greencolor = color(R, G, B);
  fill(greencolor);

  float x_ds = (float(x) / 14.375); // converts to degrees/sec
  float hx = x_ds * 250 / 2000; //compute rectange higth
  rect(50, 250, 50, hx * 3);

  R = 255;
  G = 0;
  B = 0;
  color redcolor = color(R, G, B);
  fill(redcolor);

  float y_ds = (float(y) / 14.375);
  float hy = y_ds * 250 / 2000;
  rect(150, 250, 50, hy * 3);

  R = 0;
  G = 0;
  B = 255;
  color bluecolor = color(R, G, B);
  fill(bluecolor);

  float z_ds = (float(z) / 14.375);
  float hz = z_ds * 250 / 2000;
  rect(250, 250, 50, hz * 3);

  R = 120;
  G = 125;
  B = 255;
  color textcolor = color(R, G, B);
  fill(textcolor);

  textFont(font);
  float temp_decoded = 35.0 + ((float) (temp + 13200)) / 280;
  text("temp:\n" + temp_decoded + " C", 350, 250);
  text("raw: " + x + " " + y + " " + z + "\nÂ°/s: " + x_ds + " " + y_ds + "\n" + z_ds/* + " " + temp+ xmin + " " + ymin + " " + zminhx + " " + hy + " " + hz */, 20, 500);
}

