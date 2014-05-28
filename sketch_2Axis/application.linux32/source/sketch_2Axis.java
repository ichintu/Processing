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

public class sketch_2Axis extends PApplet {


 
 Serial comm;
 String inString;
 int lf=10;
 
 int xAxis, yAxis, zButton, cButton;
 
 public void setup()
 {
 size(600, 400, P3D);
 println(Serial.list());
 comm = new Serial(this, Serial.list()[1], 115200);
 comm.bufferUntil(lf);
 frameRate(24);
 }
 
 public void draw()
 {
 background(0, 0, 0);
 fill(0, 255, 0);
 float x = map(xAxis, 33, 224, 0, 180);
 float y = map(yAxis, 42, 234, 0, 180);
 text("x: " + x, 10, 20);
 text("y: " +y, 10, 30);
 text("ZB: " +zButton, 10, 40);
 text("CB: " +cButton, 10, 50);
 
 fill(246, 225, 65);
 if (zButton==1)
 fill(255, 0, 0);
 else
 fill(0, 0, 255);
 if (cButton==1)
 fill(255, 255, 255);
 lights();
 
 pushMatrix();
 translate( (width/2), (height/2));
 rotateY(radians(y));
 rotateX(radians(x));
 rotateZ(PI/4);
 box(200, 200, 200);
 popMatrix();
 }
 
 public void serialEvent(Serial p)
 {
 inString = (comm.readString());
 parseData();
 }
 
 public void parseData()
 {
 try {
 inString = trim(inString);
 String [] raw = split(inString, ',');
 String rawX = raw[0];
 String rawY = raw[1];
 String rawzB = raw[2];
 String rawcB = raw[3];
 String[] list = split(rawX, ':');
 xAxis = PApplet.parseInt(list[1]);
 list = split(rawY, ':');
 yAxis = PApplet.parseInt(list[1]);
 list = split(rawzB, ':');
 zButton = PApplet.parseInt(list[1]);
 list = split(rawcB, ':');
 cButton = PApplet.parseInt(list[1]);
 } 
 catch (Exception e) {
 println("Exception caught");
 }
 }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "sketch_2Axis" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
