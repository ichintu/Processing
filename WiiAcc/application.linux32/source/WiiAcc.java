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

public class WiiAcc extends PApplet {



Serial comm;
String inString;
int lf=10;

int xAxis, yAxis, zAxis, zButton, cButton;

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
  
  float x = map(xAxis, 70, 182, 0, 180);
  float y = map(yAxis, 65, 173, 0, 180);
  float z = map(zAxis, 90, 210, 0, 180);
  
  text("z: " + z, 10, 10);
  text("x: " + x, 10, 20);
  text("y: " + y, 10, 30);
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
  rotateZ(radians(z));
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
    //println(raw);
    String rawX = raw[0];
    String rawY = raw[1];
    String rawZ = raw[2];
    String rawzB = raw[3];
    String rawcB = raw[4];
    String[] list = split(rawX, ':'); println(list);
    xAxis = PApplet.parseInt(list[1]); 
    list = split(rawY, ':'); println(list);
    yAxis = PApplet.parseInt(list[1]); 
    list = split(rawZ, ':'); println(list);
    zAxis = PApplet.parseInt(list[1]);
    list = split(rawzB, ':'); println(list);
    zButton = PApplet.parseInt(list[1]);
    list = split(rawcB, ':'); println(list);
    cButton = PApplet.parseInt(list[1]); 
  } 
  catch (Exception e) {
    println("Exception caught");
  }
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "WiiAcc" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
