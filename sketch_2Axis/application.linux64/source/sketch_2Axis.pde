import processing.serial.*;
 
 Serial comm;
 String inString;
 int lf=10;
 
 int xAxis, yAxis, zButton, cButton;
 
 void setup()
 {
 size(600, 400, P3D);
 println(Serial.list());
 comm = new Serial(this, Serial.list()[1], 115200);
 comm.bufferUntil(lf);
 frameRate(24);
 }
 
 void draw()
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
 
 void serialEvent(Serial p)
 {
 inString = (comm.readString());
 parseData();
 }
 
 void parseData()
 {
 try {
 inString = trim(inString);
 String [] raw = split(inString, ',');
 String rawX = raw[0];
 String rawY = raw[1];
 String rawzB = raw[2];
 String rawcB = raw[3];
 String[] list = split(rawX, ':');
 xAxis = int(list[1]);
 list = split(rawY, ':');
 yAxis = int(list[1]);
 list = split(rawzB, ':');
 zButton = int(list[1]);
 list = split(rawcB, ':');
 cButton = int(list[1]);
 } 
 catch (Exception e) {
 println("Exception caught");
 }
 }
