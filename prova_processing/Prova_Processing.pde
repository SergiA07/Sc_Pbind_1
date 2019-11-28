import oscP5.*;
import netP5.*;


OscP5 oscP5;
NetAddress myRemoteLocation;

int circlePosX = -1;
int circlePosY = -1;
int circleWidth = 0;
int circleHeight = 0;



void setup() {    //No conviarà al llarg de la perfor

size(640, 360);

oscP5 = new OscP5(this, 12000);
myRemoteLocation = new NetAddress("127.0.0.1", 12000);


}

void draw() {    //Canvia a cada frame
background(0, 0, 0);
noFill();
stroke(255, 255, 255);
ellipse(circlePosX, circlePosY, circleWidth, circleHeight);

}

void oscEvent(OscMessage theOscMessage) {
  println(theOscMessage);
  circlePosX = theOscMessage.get(0).intValue();
  circlePosY = theOscMessage.get(1).intValue();
  circleWidth = theOscMessage.get(2).intValue();
  circleHeight = theOscMessage.get(3).intValue();
  }
