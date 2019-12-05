import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class prova_processing extends PApplet {





OscP5 oscP5;
NetAddress myRemoteLocation;

int circlePosX = -1;
int circlePosY = -1;
int circleWidth = 0;
int circleHeight = 0;



public void setup() {    //No conviarà al llarg de la perfor



oscP5 = new OscP5(this, 12000);
myRemoteLocation = new NetAddress("127.0.0.1", 12000);


}

public void draw() {    //Canvia a cada frame
background(0, 0, 0);
noFill();
stroke(255, 255, 255);
ellipse(circlePosX, circlePosY, circleWidth, circleHeight);

}

public void oscEvent(OscMessage theOscMessage) {
  println(theOscMessage);
  circlePosX = theOscMessage.get(0).intValue();
  circlePosY = theOscMessage.get(1).intValue();
  circleWidth = theOscMessage.get(2).intValue();
  circleHeight = theOscMessage.get(3).intValue();
  }
  public void settings() { 
size(640, 360); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "prova_processing" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
