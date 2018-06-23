import controlP5.*;
ControlP5 cp5;
Accordion accordion;

PShader sh;
PShader shCol;
PVector[] currentPos = new PVector[4];
PVector[] desiredPos = new PVector[4];
float[] currentColors = new float[12];
float[] desiredColors = new float[12];
PShape[] entd = new PShape[4];
boolean toggle = false;
boolean isRecording = false;
float rectSize = 400;
float entdSize = 15;
float returnRate = 0.1;
int randomizeInterval = 100;
int resultNum = 0;
PGraphics pg;
float offsetX = 10;
float offsetY = 10;
color textColor;
void setup() {
  size(1000, 1000, P2D);
  pg = createGraphics(width, height, P3D);
  noSmooth();
  frameRate(60);
  sh = loadShader("frag.glsl", "vert.glsl");
  //PFont p = createFont("Arial", 10); 
  //ControlFont font = new ControlFont(p);
  randomizeColor();
  for (int i = 0; i < 4; i++) {
    currentPos[i] = new PVector(width/2, height/2);
  }
  randomizePos();  

  entd[0] = loadShape("N.svg");
  entd[1] = loadShape("E.svg");
  entd[2] = loadShape("T.svg");
  entd[3] = loadShape("D.svg");



  gui();
}

void gui() {
  cp5 = new ControlP5(this);

  Group g1 = cp5.addGroup("myGroup1")
    .setPosition(50, 50)
    .setWidth(300)
    .setBackgroundHeight(510)
    .setBackgroundColor(color(0, 50))
    ;
  cp5.addSlider("speed")
    .setPosition(30, 20)
    .setSize(200, 20)
    .setRange(0.010, 0.050)
    .setValue(0.001)
    .moveTo(g1)
    ;
  cp5.addSlider("setRectSize")
    .setPosition(30, 50)
    .setSize(200, 20)
    .setRange(0, width/2-1)
    .setValue(200)
    .moveTo(g1)
    ;
  cp5.addSlider("setInterval")
    .setPosition(30, 80)
    .setSize(200, 20)
    .setRange(10, 500)
    .setValue(100)
    .moveTo(g1)
    ;
  cp5.addSlider("returnRate")
    .setPosition(30, 110)
    .setSize(200, 20)
    .setRange(0.01, 1.0)
    .setValue(0.1)
    .moveTo(g1)
    ;
  cp5.addSlider("backgroundR")
    .setPosition(30, 170)
    .setSize(200, 20)
    .setRange(0.0, 255.0)
    .setValue(0.0)
    .moveTo(g1)
    ;  
  cp5.addSlider("backgroundG")
    .setPosition(30, 200)
    .setSize(200, 20)
    .setRange(0.0, 255.0)
    .setValue(0.0)
    .moveTo(g1)
    ;  
  cp5.addSlider("backgroundB")
    .setPosition(30, 230)
    .setSize(200, 20)
    .setRange(0.0, 255.0)
    .setValue(0.0)
    .moveTo(g1)
    ;

  cp5.addToggle("textColorToggle")
    .setPosition(30, 290)
    .setSize(50, 50)
    .moveTo(g1)
    .setValue(true)
    ;

  cp5.addSlider("setTextSize")
    .setPosition(30, 360)
    .setSize(200, 20)
    .setRange(0.0, 50.0)
    .setValue(15.0)
    .moveTo(g1)
    ;


  cp5.addToggle("record")
    .setPosition(30, 420)
    .setSize(50, 50)
    .moveTo(g1)
    .setValue(false)
    ;
  textColor = color(255);
}

void draw() {
  color backgroundColor = color(
    cp5.getController("backgroundR").getValue(), 
    cp5.getController("backgroundG").getValue(), 
    cp5.getController("backgroundB").getValue()
    );

  background(backgroundColor);
  if (frameCount % randomizeInterval == 0) {
    if (toggle) {
      randomizePos();
      randomizeColor();
      toggle = !toggle;
    } else {
      resetPos();
      toggle = !toggle;
    }
  }

  for (int i = 0; i < 4; i++) {
    currentPos[i].add(PVector.sub(desiredPos[i], currentPos[i]).mult(returnRate));
  }
  for (int i = 0; i < desiredColors.length; i++) {
    currentColors[i] += (desiredColors[i]-currentColors[i])*returnRate;
  }
  sh.set("vertColor", currentColors, 3);

  float[] positionInput = new float[8];
  positionInput[0] = currentPos[0].x;
  positionInput[1] = currentPos[0].y;
  positionInput[2] = currentPos[1].x;
  positionInput[3] = currentPos[1].y;
  positionInput[4] = currentPos[2].x;
  positionInput[5] = currentPos[2].y;
  positionInput[6] = currentPos[3].x;
  positionInput[7] = currentPos[3].y;

  sh.set("speed", cp5.getController("speed").getValue());
  sh.set("frameCount", float(frameCount));
  sh.set("v", positionInput, 2);
  //println(sqrt(calSize(currentPos)));  
  sh.set("resolution", float(width), float(height));
  sh.set("size", sqrt(calSize(currentPos)));

  pg.beginDraw();
  centerize(currentPos);
  pg.clear();
  pg.noStroke();
  pg.shader(sh);
  pg.beginShape();

  float radiousMax = 10.0;
  float radiousMult = 0.03;

  PVector v0to1 = PVector.sub(currentPos[1], currentPos[0]);
  PVector v0to2 = PVector.sub(currentPos[2], currentPos[0]);
  float v0to1Mag = v0to1.mag();
  float v0to2Mag = v0to2.mag();
  v0to1.normalize().mult(min(v0to1Mag*radiousMult, radiousMax));
  v0to2.normalize().mult(min(v0to2Mag*radiousMult, radiousMax));

  PVector v2to0 = PVector.sub(currentPos[0], currentPos[2]);
  PVector v2to3 = PVector.sub(currentPos[3], currentPos[2]);
  float v2to0Mag = v2to0.mag();
  float v2to3Mag = v2to3.mag();
  v2to0.normalize().mult(min(v2to0Mag*radiousMult, radiousMax));
  v2to3.normalize().mult(min(v2to3Mag*radiousMult, radiousMax));

  PVector v3to2 = PVector.sub(currentPos[2], currentPos[3]);
  PVector v3to1 = PVector.sub(currentPos[1], currentPos[3]);
  float v3to2Mag = v3to2.mag();
  float v3to1Mag = v3to1.mag();
  v3to2.normalize().mult(min(v3to2Mag*radiousMult, radiousMax));
  v3to1.normalize().mult(min(v3to1Mag*radiousMult, radiousMax));

  PVector v1to0 = PVector.sub(currentPos[0], currentPos[1]);
  PVector v1to3 = PVector.sub(currentPos[3], currentPos[1]);
  float v1to0Mag = v1to0.mag();
  float v1to3Mag = v1to3.mag();
  v1to0.normalize().mult(min(v1to0Mag*radiousMult, radiousMax));
  v1to3.normalize().mult(min(v1to3Mag*radiousMult, radiousMax));

  //pg.fill(255, 0, 0);
  pg.vertex(currentPos[1].x+v1to3.x, currentPos[1].y+v1to3.y, 0);
  pg.bezierVertex(currentPos[1].x+v1to3.x, currentPos[1].y+v1to3.y, currentPos[1].x, currentPos[1].y, currentPos[1].x+v1to0.x, currentPos[1].y+v1to0.y);
  pg.vertex(currentPos[1].x+v1to0.x, currentPos[1].y+v1to0.y, 0);
  //pg.fill(0, 255, 0);
  pg.vertex(currentPos[0].x+v0to1.x, currentPos[0].y+v0to1.y, 0);
  pg.bezierVertex(currentPos[0].x+v0to1.x, currentPos[0].y+v0to1.y, currentPos[0].x, currentPos[0].y, currentPos[0].x+v0to2.x, currentPos[0].y+v0to2.y);
  pg.vertex(currentPos[0].x+v0to2.x, currentPos[0].y+v0to2.y, 0);
  //pg.fill(255, 0, 0);
  pg.vertex(currentPos[2].x+v2to0.x, currentPos[2].y+v2to0.y, 0);
  pg.bezierVertex(currentPos[2].x+v2to0.x, currentPos[2].y+v2to0.y, currentPos[2].x, currentPos[2].y, currentPos[2].x+v2to3.x, currentPos[2].y+v2to3.y);
  pg.vertex(currentPos[2].x+v2to3.x, currentPos[2].y+v2to3.y, 0);
  //pg.fill(0, 0, 255);
  pg.vertex(currentPos[3].x+v3to2.x, currentPos[3].y+v3to2.y, 0);
  pg.bezierVertex(currentPos[3].x+v3to2.x, currentPos[3].y+v3to2.y, currentPos[3].x, currentPos[3].y, currentPos[3].x+v3to1.x, currentPos[3].y+v3to1.y);
  pg.vertex(currentPos[3].x+v3to1.x, currentPos[3].y+v3to1.y, 0);
  pg.endShape(CLOSE);
  pg.resetShader();
  pg.shapeMode(CENTER);

  for (int i = 0; i < entd.length; i++) {
    entd[i].setFill(textColor);
    entd[i].setStroke(color(0, 0));
  }

  pg.shape(entd[0], currentPos[1].x+offsetX, currentPos[1].y-offsetY, entdSize, entdSize);
  pg.shape(entd[1], currentPos[0].x-offsetX, currentPos[0].y-offsetY, entdSize, entdSize);
  pg.shape(entd[2], currentPos[2].x-offsetX, currentPos[2].y+offsetY, entdSize, entdSize);
  pg.shape(entd[3], currentPos[3].x+offsetX, currentPos[3].y+offsetY, entdSize, entdSize);
  pg.endDraw();
  image(pg, 0, 0);
  if (isRecording) {
    saveFrame(System.getProperty("user.home") + "/Desktop/result"+resultNum+"/ENTD_####.png");
  }
  textAlign(RIGHT);
  textSize(20);
  if (isRecording) {
    text("now recording...", width-30, 30);
    text("the file will be saved on your desktop", width-30, 60);
  }
}

void textColorToggle(boolean t) {
  if (t) {
    textColor = color(255);
  } else {
    textColor = color(0);
  }
}

void setRectSize(float _rectSize) {
  rectSize = abs(_rectSize-width/2);
}

void setTextSize(float textSize) {
  offsetX = 2*textSize/3;
  offsetY = 2*textSize/3;
  entdSize = textSize;
}

void setInterval(int _randomizeInterval) {
  randomizeInterval = _randomizeInterval;
  toggle = false;
}

void record(boolean _record) {
  if (isRecording) {
    resultNum++;
  }
  isRecording = _record;
  println(isRecording);
}


void randomizePos() {
  //left up
  desiredPos[0] = new PVector(random(rectSize, width/2), random(rectSize, height/2), 0);
  // right up
  desiredPos[1] = new PVector(random(width/2, width-rectSize), random(rectSize, height/2), 0);
  // left down
  desiredPos[2] = new PVector(random(rectSize, width/2), random(height/2, height-rectSize), 0);
  // right down
  desiredPos[3] = new PVector(random(width/2, width-rectSize), random(height/2, height-rectSize), 0);

  while (checkIfConcave(desiredPos)) {
    randomizePos();
  }
}

void resetPos() {
  //left up
  desiredPos[0] = new PVector(width/2, height/2, 0);
  // right up
  desiredPos[1] = new PVector(width/2, height/2, 0);
  // left down
  desiredPos[2] = new PVector(width/2, height/2, 0);
  // right down
  desiredPos[3] = new PVector(width/2, height/2, 0);
}


boolean checkIfConcave(PVector[] inputVector) {
  //left up
  PVector leftDown = PVector.sub(inputVector[2], inputVector[0]);
  PVector upRight = PVector.sub(inputVector[1], inputVector[0]);
  if (leftDown.cross(upRight).z > 0) {
    return true;
  }
  //right up
  PVector upLeft = PVector.sub(inputVector[0], inputVector[1]);
  PVector rightDown = PVector.sub(inputVector[3], inputVector[1]);
  if (upLeft.cross(rightDown).z > 0) {
    return true;
  }
  //left down
  PVector leftUp = PVector.sub(inputVector[0], inputVector[2]);
  PVector downRight = PVector.sub(inputVector[3], inputVector[2]);
  if (leftUp.cross(downRight).z < 0) {
    return true;
  }
  //right down
  PVector downLeft = PVector.sub(inputVector[2], inputVector[3]);
  PVector rightUp = PVector.sub(inputVector[1], inputVector[3]);
  if (downLeft.cross(rightUp).z < 0) {
    return true;
  }
  return false;
}

void randomizeColor() {
  for (int i = 0; i < desiredColors.length; i++) {
    desiredColors[i] = random(0.0, 1.0);
  }
}

void centerize(PVector[] inputVector) {
  float maxValueX = 0;
  for (int i = 0; i < inputVector.length; i++) {
    if (inputVector[i].x > maxValueX) {
      maxValueX = inputVector[i].x;
    }
  }

  float minValueX = 100000;
  for (int i = 0; i < inputVector.length; i++) {
    if (inputVector[i].x < minValueX) {
      minValueX = inputVector[i].x;
    }
  }

  float maxValueY = 0;
  for (int i = 0; i < inputVector.length; i++) {
    if (inputVector[i].y > maxValueY) {
      maxValueY = inputVector[i].y;
    }
  }

  float minValueY = 100000;
  for (int i = 0; i < inputVector.length; i++) {
    if (inputVector[i].y < minValueY) {
      minValueY = inputVector[i].y;
    }
  }


  float centerX = minValueX + (maxValueX - minValueX)/2;
  centerX = centerX - width/2; 
  float centerY = minValueY + (maxValueY - minValueY)/2;
  centerY = centerY - height/2; 
  sh.set("translate", -centerX, -centerY);
  pg.translate(-centerX, -centerY, 0);
}


float calSize(PVector[] inputVector) {
  float a1 = sqrt(sq(inputVector[0].x-inputVector[1].x)+sq(inputVector[0].y-inputVector[1].y));
  float b1 = sqrt(sq(inputVector[1].x-inputVector[2].x)+sq(inputVector[1].y-inputVector[2].y));
  float c1 = sqrt(sq(inputVector[2].x-inputVector[0].x)+sq(inputVector[2].y-inputVector[0].y));
  float s1 = (a1+b1+c1)/2;
  float S1 = sqrt(s1*(s1-a1)*(s1-b1)*(s1-c1));
  float a2 = sqrt(sq(inputVector[3].x-inputVector[1].x)+sq(inputVector[3].y-inputVector[1].y));
  float b2 = sqrt(sq(inputVector[1].x-inputVector[2].x)+sq(inputVector[1].y-inputVector[2].y));
  float c2 = sqrt(sq(inputVector[2].x-inputVector[3].x)+sq(inputVector[2].y-inputVector[3].y));
  float s2 = (a2+b2+c2)/2;
  float S2 = sqrt(s2*(s2-a2)*(s2-b2)*(s2-c2));  
  return S1+S2;
}
