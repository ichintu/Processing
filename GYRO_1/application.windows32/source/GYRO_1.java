import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class GYRO_1 extends PApplet {

/**
 * Displays values coming from an ITG3200 gyro connected to Arduino
*/



Serial myPort;  // Create object from Serial class

int temp = 0;
int x = 0;
int y = 0; 
int z = 0; 

int lf = 10; // 10 is '\n' in ASCII
byte[] inBuffer = new byte[50];

PFont font;


public void setup() 
{
  size(600, 600);
  println(Serial.list());
  myPort = new Serial(this, "COM7", 9600);  
  
  // The font must be located in the sketch's 
  // "data" directory to load successfully
  font = loadFont("CourierNew36.vlw"); 
}


public void draw() {
  if(myPort.available() > 0) {
    if (myPort.readBytesUntil(lf, inBuffer) > 0) {
      String inputString = new String(inBuffer);
      String [] inputStringArr = split(inputString, ',');
      
      temp = PApplet.parseInt(inputStringArr[0]);
      x = PApplet.parseInt(inputStringArr[1]);
      y = PApplet.parseInt(inputStringArr[2]);
      z = PApplet.parseInt(inputStringArr[3]);
    }
  }
  
  background(0xff000000);
  
  int R = 0;
  int G = 255;
  int B = 0;
  int greencolor = color(R, G, B);
  fill(greencolor);
  
  float x_ds = (PApplet.parseFloat(x) / 14.375f); // converts to degrees/sec
  float hx = x_ds * 250 / 2000; //compute rectange higth
  rect(50, 250, 50, hx * 3);
  
  float y_ds = (PApplet.parseFloat(y) / 14.375f);
  float hy = y_ds * 250 / 2000;
  rect(150, 250, 50, hy * 3);
  
  float z_ds = (PApplet.parseFloat(z) / 14.375f);
  float hz = z_ds * 250 / 2000;
  rect(250, 250, 50, hz * 3);
  
  textFont(font);
  float temp_decoded = 35.0f + ((float) (temp + 13200)) / 280;
  text("temp:\n" + temp_decoded + " C", 350, 250);
  text("raw: " + x + " " + y + " " + z + "\n\u00c2\u00b0/s: " + x_ds + " " + y_ds + "\n" + z_ds/* + " " + temp+ xmin + " " + ymin + " " + zminhx + " " + hy + " " + hz */, 20, 500); 
  
}



  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "GYRO_1" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
