import processing.serial.*;

Serial myPort;
String testdata;
PFont f;


void setup()
{
  size(900, 400);
  smooth();
  background(0);
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[1], 115200);
  myPort.bufferUntil('\n');
  f=loadFont("Tahoma-18.vlw");
}

void draw()
{
  try {
    while (myPort.available () > 0) {
      testdata = myPort.readStringUntil('\n');

      if (testdata!=null) {
        testdata = trim(testdata);
        String[] coord = split(testdata, ',');
        int xi = Integer.parseInt(coord[1]);
        int yi = Integer.parseInt(coord[0]);
        //print(yi + "cm, " + xi + " Degrees ");     
        fill(0);
        rect(8, 10, 100, 40);
        textFont(f, 18);
        fill(255);
        text(xi+" "+(char)176, 10, 28); 
        text(yi+" cm", 10, 48); 
        xi = (int) map(xi, 180, 0, 0, width); //Width
        yi = (int) map(yi, 400, 0, 0, height); //Height
        //println(yi + "X, " + xi + "Y");

        fill(255);
        stroke(0, 255, 0);
        strokeWeight(2);
        line(450, 400, xi, yi);

        //stroke(127, 0, 0);
        //line(xi, 400, xi, yi);
        if (xi >= width) {
          xi = 0;
          background(255);
        }
        if (xi <=0) {
          xi = 0;
          background(0);
        }  
        else {
          xi++;
        }
      }
    }
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
}

