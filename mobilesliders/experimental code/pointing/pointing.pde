// problem seems fixed when bug in sensing and size is zero => data is corrupted
// TODO decide how to handle size and sensing definition. Do we want to compare size with constant definition?
// TODO add training: Each series was preceded by 10 randomly-chosen tasks using the same con- dition to train the participants.
// TODO potential bug when actual is larger than target when computing the error (upper interchanged with lower). If it is the case, to be corrected in R script for analysis for tracking tasks too!!

import processing.serial.*;
import java.util.Date;

Serial myPort;

int mini = 500;        // value read from the pot
int maxi = 500;        // value read from the pot
int current_cursor = 0;
int valdraw;
int rdm = 0;
int serieIndex = 1;
int graspIndex = 0;
int countOvershoot = 0;
int contador = 0;
int numRepetitions = 33;

int cdG = 2;

//For CDgain=1
int sliderSize = 430;
int upperBound = 535;
int lowerBound = 893;
int cursorPos = 505;
int targetPos = 495;
int topSlider = 505;
int distanceFitts = 354;
int widthFitts = 22;
int upperGap = 20;
int lowerGap = 10;
/*
//For CDgain=2
int sliderSize = 860;
int upperBound = 362;
int lowerBound = 1100;
int cursorPos = 290;
int targetPos = 269;
int topSlider = 290;
int distanceFitts = 709;
int widthFitts = 44;
int upperGap = 50;
int lowerGap = 30;
*/
float previousTime = 0.0;
float averageTime = 0.0;
float showaverageTime = 0.0;

boolean blockrdm = false;
boolean overshoot = false;

long enterTime;
long movementTime;

String outFilename = "";
String outFilename2 = "";
String datos = "";
String velocidad = "";
String position = "";
ArrayList <String> config;

DateFormat stamp;

VolcarDatos escribir;

//Input input;

int[][] tasksXP_ID2 = {
  {10, 3, 1}, // first fake ID of block: 1ere cible, qui est juste pour se placer au milieu du slider
  {30,  10,  1}, // 21
  {30,  10,  1}, // 20
  {60,  20,  -1}, // 19
  {60,  20,  1}, // 18
  {30,  10,  -1}, // 17 
  {30,  10,  -1}, // 16
  {60,  20,  1}, // 15 
  {60,  20,  -1}, // 14
  {60,  20,  1}, // 13
  {60,  20,  -1}, // 12
  {30,  10,  1}, // 11 
  {30,  10,  1}, // 10
  {60,  20,  -1}, // 9
  {30,  10,  1}, // 8
  {30,  10,  1}, // 7
  {60,  20,  -1}, // 6 
  {60,  20,  1}, // 5
  {30,  10,  -1}, // 4
  {30,  10,  -1}, // 3
  {60,  20,  1},  // 2 
  {10, 3, -1}};// TODO this one does not appear in the logs!! 

int[][] tasksXP_ID3 = {
  {10, 3, 1}, // first fake ID of block: 1ere cible, qui est juste pour se placer au milieu du slider
  {60,  9,  1},
{30,  4,  -1},
{30,  4,  -1},
{60,  9,  1},
{60,  9,  -1},
{60,  9,  1},
{30,  4,  -1},
{30,  4,  -1},
{60,  9,  1},
{30,  4,  -1},
{30,  4,  -1},
{60,  9,  1},
{30,  4,  -1},
{30,  4,  -1},
{60,  9,  1},
{60,  9,  -1},
{30,  4,  1},
{30,  4,  1},
{60,  9,  -1},
{60,  9,  1}, 
  {10, 3, -1}};// TODO this one does not appear in the logs!! 

int[][] tasksXP_ID4 = {
  {10, 3, 1}, // first fake ID of block: 1ere cible, qui est juste pour se placer au milieu du slider
  {30,  2,  1},
{30,  2,  1},
{60,  4,  -1},
{60,  4,  1},
{60,  4,  -1},
{60,  4,  1},
{60,  4,  -1},
{30,  2,  1},
{30,  2,  1},
{30,  2,  -1},
{30,  2,  -1},
{30,  2,  1},
{30,  2,  1},
{60,  4,  -1},
{60,  4,  1},
{60,  4,  -1},
{60,  4,  1},
{30,  2,  -1},
{30,  2,  -1},
{60,  4,  1}, 
  {10, 3, -1}}; // TODO this one does not appear in the logs!! 

int[][] tasksXP_ID5 = {
  {10, 3, 1}, // first fake ID of block: 1ere cible, qui est juste pour se placer au milieu du slider
  {60,  2,  1},
{30,  1,  -1},
{30,  1,  -1},
{60,  2,  1},
{60,  2,  -1},
{60,  2,  1},
{60,  2,  -1},
{30,  1,  1},
{30,  1,  1},
{30,  1,  -1},
{30,  1,  -1},
{60,  2,  1},
{60,  2,  -1},
{30,  1,  1},
{30,  1,  1},
{60,  2,  -1},
{60,  2,  1},
{60,  2,  -1},
{30,  1,  1},
{30,  1,  1}, 
  {10, 3, -1}};// TODO this one does not appear in the logs!! 

int[][][] tasksXP = {tasksXP_ID2, tasksXP_ID3, tasksXP_ID4, tasksXP_ID5};
int[][][] tasksTraining = {{{30,10,0}, {60,20,0}}, // ID = 2
                          {{30,4,0}, {60,9,0}}, // ID = 3
                          {{30,2,0}, {60,4,0}}, // ID = 4
                          {{30,1,0}, {60,2,0}}}; // ID = 5

////////////////////////////////
// FACTORS OF BLOCK ////////////
////////////////////////////////
int frequencyOfChange = 1; // in number of target selections: every 1, ..., X targets. blockDuration*totalNbBlocks means it never changes
int deviceCondition = 1; // 0 is resizable slider, 1 is non resizable slider (max size), 2 is two combined sliders, 3 resizable thumb
String subjectsName = "Julie";
int subjectsAge = 24; 
boolean isMale = false;
int ID = 5;
boolean isTraining = false;
int[][] tasks = tasksXP[ID - 2];

// 4 levels of difficulty
int difficulty = 18;
int blockDuration = numRepetitions; // Numero de tareas por bloque - number of pointing tasks/targets in the block + 2 (one fake in the beginning and one not seen at the end)
       
int definition = 3000; // fixed definition of 21 sensels per cm over all sizes (and actual cursor's widths) // larger than slider means step of 1px

Block block;
int totalNbBlocks = 4; //Numero de bloques
int blockIndex;

boolean isPaused = true;

// dependant variables
int[][] errors;
int nbErrors = 0;
int pointingTime; // poiting time for each target to be logged

//Timer startTimer;

// in case it is a fixed slider condition
int SliderSize = 4; //either 2cm, 4cm, 8cm
////////////////////////////////
////////////////////////////////


Slider slider;

Cursor targetCursor;
Cursor actualCursor;
Size targetSize;
Size actualSize;
Error cursorError;
Error sizeError;

PFont f;

/*boolean sketchFullScreen() {
  return true;
}*/

void setup() {

  println(Serial.list());  // List all the available serial ports:
  stamp = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");
  println(stamp.format(new Date()));
  //exit();
  myPort = new Serial(this, "/dev/tty.usbmodem1421", 9600 );
  /////////////// 
  delay(1000);
  
  f = createFont("Arial", 16, true);
  
  /*config = new ArrayList<String>();
  config.add("small-vertical");
  config.add("small-tilted");
  config.add("large-vertical");
  config.add("large-tilted");*/
  
  config = new ArrayList<String>();

  if(cdG == 1){
    config.add("large-vertical");
    config.add("large-vertical");
    config.add("large-vertical");
    
    sliderSize = 430;
    upperBound = 535;
    lowerBound = 893;
    cursorPos = 505;
    targetPos = 495;
    topSlider = 505;
    distanceFitts = 354;
    widthFitts = 22;
    upperGap = 20;
    lowerGap = 10;  
  }
  else if(cdG == 2){
    config.add("verylarge-vertical");
    config.add("verylarge-vertical");
    config.add("verylarge-vertical");
    
    sliderSize = 860;
    upperBound = 362;
    lowerBound = 1100;
    cursorPos = 290;
    targetPos = 269;
    topSlider = 290;
    distanceFitts = 709;
    widthFitts = 44;
    upperGap = 50;
    lowerGap = 30;  
  }
  
  escribir = new VolcarDatos();
  outFilename = subjectsName+"_series_"+(serieIndex + 1)+"_"+stamp.format(new Date())+".txt";
  outFilename2 = subjectsName+"_series_"+(serieIndex + 1)+"_speed_"+stamp.format(new Date())+".txt";
  datos = "Name;Sex;Age;Length/Orientation;Grasp;Repetition;Position;Overshoot;MovementTime - "+stamp.format(new Date());
  velocidad = "Name;Sex;Age;Length/Orientation;Grasp;Repetition;Movement;Position;MovementTime - "+stamp.format(new Date());
  escribir.appendTextToFile(outFilename, datos);
  escribir.appendTextToFile(outFilename2, velocidad);

  if (isTraining){
    blockDuration = 200;
  }
  errors = new int[totalNbBlocks][blockDuration];
  
  blockIndex = 0;
  block = new Block(blockDuration, frequencyOfChange);

  //setup_DumpDataInFile(factors);

  size(displayWidth, displayHeight);
  smooth();

  // grey software slider displayed on the screen
  int y_margin = 10;
  int x_margin = 50;
  int x_targetMargin = 20;
  float h = (displayHeight-2*y_margin)/20.; // one centimer of physical slider is displayed as h pixels on the display
  slider = new Slider(2*displayWidth/3, displayHeight/2, // center point of the slider
  round(SliderSize*h), 1, // height width
  color(180, 180, 180), 
  x_margin+x_targetMargin);

  // target size
  targetSize = new Size(difficulty, 20, color(0, 180, 0));
  // actual size
  actualSize = new Size(2, 400, color(180, 180, 180));
  // size error
  sizeError = new Error(targetSize, actualSize, color(180, 0, 0), 100);
  // target cursor
  targetCursor = new Cursor(targetSize, color(0, 180, 0), x_margin+x_targetMargin);
  targetCursor.updateScreenMinValue(0);
  targetCursor.updateScreenMaxValue(slider._maxHeight);
  targetCursor.updateSensorMinValue(0);
  targetCursor.updateSensorMaxValue(targetSize._sensorValue);
  // actual cursor
  actualCursor = new Cursor(actualSize, color(255, 255, 255), x_margin);
  actualCursor.updateScreenMinValue(0);
  actualCursor.updateScreenMaxValue(slider._maxHeight);
  actualCursor.updateSensorMinValue(0);
  actualCursor.updateSensorMaxValue(actualSize._sensorValue);
  actualCursor.updateSensorValue(1., true);
  // cursor error
  cursorError = new Error(targetCursor, actualCursor, color(180, 50, 0), 100);

  // DEBUG
  moveTargetCursor();

  frameRate(0.15*slider._height); // Target speed of 0.15 units (slider’s total range) per second = 0.15*actualSize._value per seconds = number of frame per seconds
  rectMode(CENTER); 

  // dump data
  /*String s = "TIMESTAMP, SUBJECT, AGE, SEX, DEVICE, BLOCK_INDEX, DIFFICULTY, DIFFICULTY_CHANGE_INTERVAL," +
    "SLIDER_HEIGHT, " + 
    "TARGET_CURSOR_SENSOR_VALUE," + 
    "TARGET_CURSOR_SCREEN_VALUE," +
    "TARGET_CURSOR_SENSOR_HEIGHT," +
    "TARGET_CURSOR_SCREEN_HEIGHT," +
    "TARGET_CURSOR_SENSOR_LOWERBOUND," +
    "TARGET_CURSOR_SCREEN_LOWERBOUND," +
    "TARGET_CURSOR_SENSOR_UPPERBOUND," +
    "TARGET_CURSOR_SCREEN_UPPERBOUND," +
    "ACTUAL_CURSOR_SENSOR_VALUE," + 
    "ACTUAL_CURSOR_SCREEN_VALUE," +
    "ACTUAL_CURSOR_SENSOR_HEIGHT," + 
    "ACTUAL_CURSOR_SCREEN_HEIGHT," +
    "ACTUAL_CURSOR_SENSOR_LOWERBOUND," +
    "ACTUAL_CURSOR_SCREEN_LOWERBOUND," +
    "ACTUAL_CURSOR_SENSOR_UPPERBOUND," +
    "ACTUAL_CURSOR_SCREEN_UPPERBOUND," +
    "CURSOR_ERROR_CENTER_TO_CENTER_SCREEN_VALUE," + // sensor value has no meaning for the error (max of target and cursor can be different, hence there sensor space is possibly not comparable) 
  "CURSOR_ERROR," +
    "TARGET_SIZE_SENSOR_VALUE," +
    "TARGET_SIZE_SCREEN_VALUE," +
    "ACTUAL_SIZE_SENSOR_VALUE," +
    "ACTUAL_SIZE_SCREEN_VALUE," +
    "SIZE_ERROR_SENSOR_VALUE," +
    "SIZE_ERROR_SCREEN_VALUE," +
    "TARGET_INDEX," +
    "TARGET_VALIDATED," +
    "POINTING_TIME," +
    "DIFFICULTY_CHANGED," +
    "DEVICE_PB";*/
  //writeHeader(s);

  //input = new Input();
  //input.start();
  
  isPaused = true;
}

void moveTargetCursor() {
  // update values to draw the next target

  if (!isTraining) { // if real XP, then pre-defined random serie
    
    //retrieve new index
    int i = blockIndex*blockDuration + round(map(block._targetIndex, blockDuration, 0, 0, blockDuration));
    
    //targetCursor._relativeValue = 20;
    //targetCursor._relativeHeight = (slider._loc_y - slider._height/2) + 50;
    //targetCursor._relativeHeight = (slider._loc_y - slider._height/2) + 250;
    
    //update relative value
    //targetCursor._relativeValue = targetCursor._relativeValue + tasks[i][2] * tasks[i][0]/96.;
    //targetCursor._relativeHeight = tasks[i][1]/96.;
  
  } else { // if training, then real random serie
    // while the target does not move
    float oldValue = targetCursor._relativeValue;
    targetCursor._relativeValue = 0;
    while(targetCursor._relativeValue <= 0 || targetCursor._relativeValue >= 1){
      // chose randomly between two distances
      int i = round(random(0,1.1));
      println(i);
      boolean isForward;
      float s = random(-1, 1);
      if (s < 0) {
        isForward = true;      
      } else {
        isForward = false;
      }
      println(isForward);
      if (isForward) {
        targetCursor._relativeValue = oldValue + tasks[i][0]/96.;
        targetCursor._relativeHeight = tasks[i][1]/96.;
      } else {
        targetCursor._relativeValue = oldValue - tasks[i][0]/96.;
        targetCursor._relativeHeight = tasks[i][1]/96.;
      }
      println(targetCursor._relativeValue);
    }
  }
    
  // target position (px) = (previous position en pixels + (taille senseur(en pixel)/2 ) * distance  * sens
  //targetCursor.updateScreenValue(round(targetCursor._relativeValue * slider._height), true);
  
  //targetCursor.updateScreenValue(20, true);
  
// DEBUG targetCursor.updateScreenValue(round(targetCursor._screenValue + actualSize._screenValue*tasks[i][0]/2.*tasks[i][2]), true);
// DEBUG targetCursor._relativeValue = (1.0*targetCursor._screenValue)/(1.0*slider._height);
  
  // before slider._height/tasks[i][0]
  //targetCursor.updateScreenHeight(round(targetCursor._relativeHeight * slider._height), true);
  if (isPaused) {
    targetCursor.updateScreenValue(upperGap, true);
    position = "U";
  }
  else{
    println("current_cursor "+current_cursor);
    println("MAX "+((slider._loc_y - slider._height/2) + actualSize._screenValue));
    if((current_cursor + distanceFitts) > actualSize._screenValue){
      if(upperBound > ((topSlider + current_cursor) - distanceFitts)) targetCursor.updateScreenValue(upperGap, true);
      else targetCursor.updateScreenValue((current_cursor - distanceFitts), true);
      println("ARRIBA");
      position = "U";
    }
    else{
      if(((topSlider + current_cursor) + distanceFitts) > lowerBound) targetCursor.updateScreenValue((sliderSize - widthFitts - lowerGap), true);
      else targetCursor.updateScreenValue((current_cursor + distanceFitts), true);
      println("ABAJO");
      position = "D";
    }
    
    println("targetCursor "+targetCursor._screenValue);
    
    overshoot = false;
    countOvershoot = 0;
    
    movementTime = System.currentTimeMillis();
    println("movementTime "+movementTime);
  }


  //targetCursor.updateSensorHeight(targetCursor._sizeOfRef._sensorMax/targetCursor._sizeOfRef._sensorValue, true);
  // la conversion de coordonees va maintenant se faire entre:     
  //targetCursor.updateSensorMinValue(0);
  //targetCursor.updateSensorMaxValue(targetSize._sensorValue);
  // et : 
  //targetCursor.updateScreenMinValue(0 + targetCursor._screenHeight/2);
  //targetCursor.updateScreenMaxValue(slider._maxHeight - targetCursor._screenHeight/2);
}

void keyPressed() {
  if (isPaused) {
    isPaused = false;
    //println("PAUSA");
    movementTime = System.currentTimeMillis();
    println("movementTime "+movementTime);
    if(averageTime != 0) averageTime = averageTime/16;
    showaverageTime = averageTime;
  } 
  else {
    
    int e = computeCursorError();
    
    if (e == 0) {
      pointingTime = block._targetTimer.getAndStop();
      block._targetValidated = true;
      if (block._targetIndex != 0) {
        errors[blockIndex][blockDuration - (block._targetIndex)] = e;
      }
    }
    else {
      block._keyPressed = true;
      ++block._keyPressIndex;
      pointingTime = block._targetTimer.get();
    }
  }
  /*try{    
    Thread.sleep(100);
  }
  catch(Exception e){}*/
}

void pollSliderInput() {
  float oldSize = slider._height;
  double size = mouseX;
  //double size = input.getSliderSize();
  double location = mouseY*slider._height/displayHeight;
  //double location = input.getCursorLocation();
  
  actualSize._screenValue = sliderSize; //on Thunderbolt display (20cm)
  //actualSize._screenValue = 433; //on Mac display (10cm)
  //actualSize._screenValue = 331; //on Mac display (7,55cm)
  //actualSize._screenValue = 606; //on Mac display (14cm)
  //actualSize._screenValue = 130; //on Mac display (3cm)
  //actualSize._screenValue = 255; //on big display (5cm)

  // SLIDER SIZE
  if (size > 0) {
    actualSize.updateSensorValue((float)(size/10.), true); // conversion from mm to cm => /10.
  }
 
  // actual cursor and target Cursor sensor max value
  actualCursor.updateSensorMaxValue(actualSize._sensorValue);

  targetCursor.updateScreenMinValue(0 + targetCursor._screenHeight/2);
  targetCursor.updateScreenMaxValue(slider._maxHeight - targetCursor._screenHeight/2);
  
  slider._height = round(actualSize._screenValue);
  slider._maxHeight = round(actualSize._screenValue);

//CAMBIA TAMANO DE TARGET AREA
  // TODO update targetCursor Height and Location
  //if(oldSize == 0){oldSize = 0.001;}
  //targetCursor.updateScreenValue(round(targetCursor._screenValue * slider._height / oldSize), true);
  //println("pollSliderInput> " + targetCursor._relativeValue);
  

  //targetCursor.updateScreenHeight(16, true); // on Mac display (4mm)
  //targetCursor.updateScreenHeight(31, true); // on Mac display (7mm)
  targetCursor.updateScreenHeight(widthFitts, true); // on Mac display (10mm)
  
  // actual cursor height
  // if we fix the actual cursor height (e.g. when evaluating the impact of slider's size, with fixed definition
  // TODO here fix size of cursor
  actualCursor.updateScreenHeight(1, true);
  // or:
  // actualCursor.updateSensorHeight(actualSize._sensorMax/(200/10.), true); 

  //println(actualCursor._sensorHeight + " " + actualCursor._screenHeight);
  // if we use the actual size to adapt the actual cursor height
  //actualCursor.updateSensorHeight(actualSize._sensorMax/actualSize._sensorValue, true); // plus la taille du slider est grande, plus la taille du curseur est petite

    if (actualCursor._screenHeight < actualSize._screenMin) {
    actualCursor.updateScreenHeight(actualSize._screenMin, true);
  } 
  else if (actualCursor._screenHeight > actualSize._screenMax) { 
    actualCursor.updateScreenHeight(actualSize._screenMax, true);
  }

    valdraw = GetSliderInput();
    //valdraw = 28;
    //valdraw = 128;
      //println("codigo "+valdraw);
    if((valdraw < 900) && (valdraw >= 0)){
    //if(valdraw < 900){
    
      //println("valor slider "+valdraw);
      
      current_cursor = valdraw;
      
      actualCursor.updateScreenValue(valdraw);
      
    }
  // CURSOR LOCATION
  //actualCursor.updateSensorValue((float)location/10., true);

  if (actualCursor._sensorValue > actualCursor._sensorMax) {
    actualCursor.updateSensorValue(actualCursor._sensorMax, true);
  } 
  else if (actualCursor._sensorValue < actualCursor._sensorMin) {
    actualCursor.updateSensorValue(actualCursor._sensorMin, true);
  }

  // actual cursor screen min and max value, so that the cursor does not go beyond slider's bounds
  actualCursor.updateScreenMinValue(slider._loc_y - slider._height/2);
  actualCursor.updateScreenMaxValue(slider._loc_y + slider._height/2);
  
  //Check validation time
  //println("targetCursor._screenValue "+(278+targetCursor._screenValue));
  //println("actualCursor._screenValue "+(285+actualCursor._screenValue));
  if (!isPaused){
    if(((cursorPos+actualCursor._screenValue) >= (targetPos+targetCursor._screenValue)) && ((cursorPos+actualCursor._screenValue) <= ((targetPos+targetCursor._screenValue) + widthFitts))){
      //println("DENTRO de target");
      overshoot = true;
      if(enterTime == 0) enterTime = System.currentTimeMillis();
      else{
        if((System.currentTimeMillis() - enterTime) > 1000){
          
          //println("SI");
          int e = computeCursorError();
          
          pointingTime = block._targetTimer.getAndStop();
          block._targetValidated = true;
          if (block._targetIndex != 0) {
            errors[blockIndex][blockDuration - (block._targetIndex)] = e;
          }
          
          if(block._targetIndex < numRepetitions){
            datos = "";
            if(graspIndex == 0) datos = subjectsName+";"+(isMale ? "Male" : "Female")+";"+subjectsAge+";"+config.get(rdm)+";1H;"+(numRepetitions - block._targetIndex)+";"+position+";"+countOvershoot+";"+(((System.currentTimeMillis() - movementTime) - 1000)/1000.0);
            else if(graspIndex == 1) datos = subjectsName+";"+(isMale ? "Male" : "Female")+";"+subjectsAge+";"+config.get(rdm)+";2H;"+(numRepetitions - block._targetIndex)+";"+position+";"+countOvershoot+";"+(((System.currentTimeMillis() - movementTime) - 1000)/1000.0);
            escribir.appendTextToFile(outFilename, datos);
            datos = "";
            previousTime = (float)(((System.currentTimeMillis() - movementTime) - 1000)/1000.0);
            println("previousTime "+(((System.currentTimeMillis() - movementTime) - 1000)/1000.0));
            averageTime = previousTime + averageTime;
          }
          else println("Primera repeticion no cuenta block._targetIndex = "+block._targetIndex);
        }
        //else println("NO");
      }
    }
    else{
    
      enterTime = 0; 
      if(overshoot){
        
        countOvershoot++;
        overshoot = false; 
      }
    } 
  }
  
}


int GetSliderInput() {

  //delay(10);
  
  String val;     // Data received from the serial port
  int val_int = 0;

  if (myPort.available() > 0) {

    val = myPort.readStringUntil('\n'); // read it and store it in val
    
        //println("VALOR "+val);
    
    if(val != null){
      
      val = trim(val);
  
      if((val.length() > 1) && (val.charAt(val.length() - 1) == '#')){
        
        String[] list = split(val, '#'); 
        val = list[0];
        
        //println("SLIDER "+val);
        
        /*if (int(val) > maxi){
            appendTextToFile(outFilename, val);
            maxi = int(val);
        }
        else if (int(val) < mini){
            appendTextToFile(outFilename, val);
            mini = int(val);
        }*/
        
        //println("valor "+val);
  
        /*if ((config.get(rdm)).equals("small-vertical") == true) {
          val_int = int(map(int(val), 0, 1024, 606, 0)); //SMALL SLIDER
        }
        else if ((config.get(rdm)).equals("small-tilted") == true) {
          val_int = int(map(int(val), 0, 1024, 606, 0)); //SMALL SLIDER
        }
        else
        if ((config.get(rdm)).equals("large-vertical") == true) {
          val_int = int(map(int(val), 276, 1024, 606, 0)); //VERTICAL LARGE SLIDER
        }
        else if ((config.get(rdm)).equals("large-tilted") == true) {
          val_int = int(map(int(val), 276, 1024, 0, 606)); //TILTED LARGE SLIDER 
        }*/
        if ((config.get(rdm)).equals("large-vertical") == true) {
          val_int = int(map(int(val), 0, 1024, 430, 0)); //VERTICAL LARGE SLIDER
        }
        else if ((config.get(rdm)).equals("verylarge-vertical") == true) {
          val_int = int(map(int(val), 0, 1024, 860, 0)); //VERTICAL VERY LARGE SLIDER
        }

      }
      else val_int = 911;
    }
    else val_int = 911;
  }
  else val_int = 911;
  
  return val_int;
}

void draw() {

  // poll the latest user input 
  pollSliderInput();

  if (isPaused) { 
    drawBeforeBlock();
  } 
  else {
    
    /*valdraw = GetSliderInput();
    if((valdraw < 900) && (valdraw > 0)){
    //if(valdraw < 900){
    
      println("valor slider "+valdraw);
      
      current_cursor = 575 + valdraw;
      
    }*/

    background(0);
    pushMatrix();
    drawSlider();

    // SIZE 
    // error : compute error (0 or negative = device is even smaller than asked)
    sizeError.updateSensorValue(actualSize._sensorValue - targetSize._sensorValue, true); 
    if (deviceCondition !=1) {
      // COMMENTED TO LET THE SUBJECT FREE TO CHOOSE HER/BEST SIZE
      //drawTargetSize(targetSize);
      //drawError(targetSize, actualSize);
      //drawActualSize(actualSize);
    }

    // CURSOR
    // draw cursor et error

    //startTimer = new Timer(int(random(2000, 5000)));
    //startTimer.start();
    //if (!startTimer.isFinished()){ 
    //drawStartLocation();
    //} else {
        drawError(targetCursor, actualCursor);
        drawCursor(targetCursor); 
    //}
        drawCursor(actualCursor); 

    popMatrix();

    // Display XP data for subject
    textFont(f, 16); // specify font to be used
    textAlign(LEFT);
    fill(255); // specify font color 
    text("Series " + (serieIndex+1) + "/2", 10, 30);
    text("Block " + (blockIndex+1) + "/" + totalNbBlocks, 10, 60);
    text((block._targetIndex) + " targets left", 10, 90);  // display
    text("previousTime "+previousTime, 10, 1300);  // display
    text("averageTime "+showaverageTime, 10, 1330);  // display
    //text("Difficulty = " + difficulty, 10, 90);  // display

    // DEBUG
    text("Current configuration: " + config.get(rdm) + " slider", displayWidth - 300, 30);  // display
    if(graspIndex == 0) text("Current grasp: One-handed", displayWidth - 300, 60);  // display
    else if(graspIndex == 1) text("Current grasp: Two-handed", displayWidth - 300, 60);  // display
    //text("User cursor Sensor Location: " + round(actualCursor._sensorValue) + " / " + actualSize._sensorValue, displayWidth - 300, 30);  // display
    //text("User cursor Screen Location: " + actualCursor._screenValue + " / " + slider._height, displayWidth - 300, 60);  // display
    //text("Target cursor Sensor Location: " + round(targetCursor._sensorValue) + " / " + targetSize._sensorValue, displayWidth - 300, 90);  // display
    //text("Target cursor Screen Location: " + targetCursor._screenValue + " / " + slider._height, displayWidth - 300, 120);  // display

    if(block._targetIndex < numRepetitions){
      velocidad = subjectsName+";"+(isMale ? "Male" : "Female")+";"+subjectsAge+";"+config.get(rdm)+";1H;"+(numRepetitions - block._targetIndex)+";"+position+";"+current_cursor+";"+((System.currentTimeMillis() - movementTime)/1000.0);
      escribir.appendTextToFile(outFilename2, velocidad);
      velocidad = "";
    }

   
    
    if (block._keyPressed) {
      block._keyPressed = false;
    }
    
    if (block._targetValidated) {
      block._targetValidated = false;
      block._keyPressIndex = 0;
      moveTargetCursor();
      --block._targetIndex;
      block._targetTimer.start();
    }

    if (block._difficultyChanged) {
      block._difficultyChanged = false;
    }

    if (block._targetIndex == 0) { // end of block

      if (blockIndex == totalNbBlocks-1) { // last block, exit program, now change technique or stop

        // calculer le nb d'erreur total
        if(blockIndex >= 1){
          for (int i = 0; i < errors[blockIndex-1].length; ++i) {
            if (errors[blockIndex-1][i] != 0) {
              ++nbErrors;
            }
          }
        }
        
        drawEnd();
        frameRate(0.1); // "freeze" the display for a few seconds
        exit();
          
        /*if(((graspIndex == 0) && (serieIndex == 0)) || ((graspIndex == 1) && (serieIndex == 1))){
          println("Cambio de Grasp "+graspIndex);
          //println("block._targetIndex "+block._targetIndex);
          //println("blockIndex "+blockIndex);
          //println("totalNbBlocks "+totalNbBlocks);
          //println("blockDuration "+blockDuration);
          //println("frequencyOfChange "+frequencyOfChange);
          //exit();
          if (graspIndex == 0) graspIndex++;
          else if (graspIndex == 1) graspIndex--;
          block._targetIndex = 4;
          
          // First we change to next block
          blockIndex = 0;
          block = new Block(blockDuration, frequencyOfChange);  
          moveTargetCursor();
          isPaused = true;
          
          blockrdm = false;
          config.clear();
          config.add("small-vertical");
          config.add("small-tilted");
          config.add("large-vertical");
          config.add("large-tilted");
  
          // and we compute error for previous block
          if (blockIndex != 0) {
            // we use blockIndex -1 as we are now in the next block
            // calculer le nb d'erreur total
            for (int i = 0; i < errors[blockIndex-1].length; ++i) {
              if (errors[blockIndex-1][i] != 0) {
                ++nbErrors;
              }
            }
          }
        }
        else if(((graspIndex == 1) && (serieIndex == 0)) || ((graspIndex == 0) && (serieIndex == 1))){
          drawEnd();
          frameRate(0.1); // "freeze" the display for a few seconds
          exit();
        }*/


      } 
      else {

        // First we change to next block
        ++blockIndex;
        block = new Block(blockDuration, frequencyOfChange);  
        moveTargetCursor();
        isPaused = true;
        
        blockrdm = false;
        config.remove(rdm);
        contador++;
        if (graspIndex == 0) graspIndex++;
        else if (graspIndex == 1) graspIndex--;

        // and we compute error for previous block
        if (blockIndex != 0) {
          // we use blockIndex -1 as we are now in the next block
          // calculer le nb d'erreur total
          for (int i = 0; i < errors[blockIndex-1].length; ++i) {
            if (errors[blockIndex-1][i] != 0) {
              ++nbErrors;
            }
          }
        }
      }
    }
  } // end else (if not paused)
}

void drawSlider() {
  
  noStroke();
  fill(slider._color);
  rectMode(CENTER);
  rect(slider._loc_x, slider._loc_y, slider._width, slider._height); // slider
  rect(slider._loc_x, 
  slider._loc_y - slider._height/2, 
  slider._width + targetCursor._margin*2, 
  1); // left bound
  rect(slider._loc_x, 
  slider._loc_y + slider._height/2, 
  slider._width + targetCursor._margin*2, 
  1); // right bound
}

void drawStartLocation() {
  stroke(200);
  strokeWeight(1); 
  noFill();
  rectMode(CENTER);
  rect(slider._loc_x, slider._loc_y, 200, 200);
  noStroke();
}

void drawCursor(Cursor p_cursor) {
  fill(p_cursor._color);
  rectMode(CENTER);
  rect(slider._loc_x, 
  (slider._loc_y-slider._height/2) + p_cursor._screenValue,
  //current_cursor,
  slider._width + p_cursor._margin*2, 
  p_cursor._screenHeight);
   rect(slider._loc_x -2, (targetPos+targetCursor._screenValue), 1, 1);
   rect(slider._loc_x, (cursorPos+actualCursor._screenValue), 1, 1);
   rect(slider._loc_x -2, upperBound, 1, 1);
   rect(slider._loc_x -2, lowerBound, 1, 1);
   rect(slider._loc_x, topSlider, 1, 1);
   //println("actualCursor._screenValue "+((slider._loc_y-slider._height/2)+actualCursor._screenValue));
   //println("targetCursor._screenValue "+((slider._loc_y-slider._height/2)+targetCursor._screenValue));
}

void drawError(Cursor p_targetCursor, Cursor p_actualCursor) {

  fill(cursorError._color);

  // draw error between target and actual cursor position
  if (p_actualCursor._screenValue < p_targetCursor._screenValue) { // actual cursor is above target cursor

    cursorError.updateScreenValue(p_targetCursor._screenValue - p_actualCursor._screenValue, true);

    rectMode(CENTER);
    rect(slider._loc_x, 
    (slider._loc_y-slider._height/2) + p_actualCursor._screenValue + abs(cursorError._screenValue)/2, 
    slider._width + cursorError._margin, 
    abs(cursorError._screenValue));
  } 
  else if (p_actualCursor._screenValue > p_targetCursor._screenValue) { // error is negative when actual cursor is on the below target cursor on the screen

    cursorError.updateScreenValue(p_targetCursor._screenValue - p_actualCursor._screenValue, true);

    rectMode(CENTER);
    rect(slider._loc_x, 
    (slider._loc_y-slider._height/2) + p_targetCursor._screenValue + abs(cursorError._screenValue)/2, 
    slider._width + cursorError._margin, 
    abs(cursorError._screenValue));
  } 
  else {
    cursorError.updateScreenValue(0, true);
  }
}

int computeCursorError() {

  int error;

  int targetCursorScreenLowerBound = int(targetCursor._screenValue - targetCursor._screenHeight/2.);
  int targetCursorScreenUpperBound = int(targetCursor._screenValue + targetCursor._screenHeight/2.);
  int actualCursorScreenLowerBound = int(actualCursor._screenValue - actualCursor._screenHeight/2.); 
  int actualCursorScreenUpperBound = int(actualCursor._screenValue + actualCursor._screenHeight/2.); 

  if (actualCursor._screenHeight <= targetCursor._screenHeight) { // actual cursor smaller than target cursor

    // 1 - actual cursor inside target cursor (aim of users)
    if (actualCursorScreenLowerBound >= targetCursorScreenLowerBound &
      actualCursorScreenUpperBound <= targetCursorScreenUpperBound) { 

      error = 0;
    }
    // 3 - partial overlap between the two
    else if (actualCursorScreenUpperBound >= targetCursorScreenLowerBound &
      actualCursorScreenLowerBound <= targetCursorScreenLowerBound) { // on the left hand side

      error  = targetCursorScreenLowerBound - actualCursorScreenLowerBound;
    } 
    else if (actualCursorScreenLowerBound <= targetCursorScreenUpperBound &
      actualCursorScreenUpperBound >= targetCursorScreenUpperBound) { // on the right hand side

      error = actualCursorScreenUpperBound - targetCursorScreenUpperBound;
    } 
    // 4 - no overlap between the two 
    else if (targetCursorScreenLowerBound > actualCursorScreenUpperBound) { // actual cursor a gauche, i.e. erreur positive

      error = targetCursorScreenLowerBound - actualCursorScreenLowerBound;
    } 
    else if (actualCursorScreenLowerBound > targetCursorScreenUpperBound) { // actual cursor a droite, i.e. erreur negative

      error = targetCursorScreenUpperBound - actualCursorScreenUpperBound;
    } 
    else {
      error = 2000;
    }
  } 
  else { // actual cursor larger than target cursor

    // 2 - target cursor inside actual cursor
    if (targetCursorScreenLowerBound >= actualCursorScreenLowerBound &
      targetCursorScreenUpperBound <= actualCursorScreenUpperBound) {

      // like fatfinger pb : the error is what is outside the target (potentially erroneous selections)
      error = 0;
      // error = targetCursorScreenLowerBound - actualCursorScreenLowerBound + actualCursorScreenUpperBound - targetCursorScreenUpperBound;
    }
    // 3 - partial overlap between the two
    else if (actualCursorScreenUpperBound >= targetCursorScreenLowerBound &
      actualCursorScreenLowerBound <= targetCursorScreenLowerBound) { // on the left hand side

      error = targetCursorScreenUpperBound - actualCursorScreenUpperBound;
      // error  = targetCursorScreenLowerBound - actualCursorScreenLowerBound + actualCursor._screenHeight - targetCursor._screenHeight;
    } 
    else if (actualCursorScreenLowerBound <= targetCursorScreenUpperBound &
      actualCursorScreenUpperBound >= targetCursorScreenUpperBound) { // on the right hand side

      error = targetCursorScreenLowerBound - actualCursorScreenLowerBound;
      // error = actualCursorScreenUpperBound - targetCursorScreenUpperBound + actualCursor._screenHeight - targetCursor._screenHeight;
    } 
    // 4 - no overlap between the two
    else if (targetCursorScreenLowerBound > actualCursorScreenUpperBound) { // actual cursor a gauche, i.e. erreur positive

      error = targetCursorScreenUpperBound - actualCursorScreenUpperBound;
      // error = targetCursorScreenLowerBound - actualCursorScreenLowerBound + actualCursor._screenHeight - targetCursor._screenHeight;
    } 
    else if (actualCursorScreenLowerBound > targetCursorScreenUpperBound) { // actual cursor a droite, i.e. erreur negative

      error = targetCursorScreenLowerBound - actualCursorScreenLowerBound;
      // error = actualCursorScreenUpperBound - targetCursorScreenUpperBound + actualCursor._screenHeight - targetCursor._screenHeight;
    }
    else {
      error = 2000;
    }
  }
  return error;
}

void drawError(Size p_targetSize, Size p_actualSize) {

  fill(sizeError._color);

  int x = displayWidth/3; // sizes are draw at the left third of the screen

  if (sizeError._sensorValue != 0) {

    // between target and actual sizes

    int y1 = displayHeight/2 - p_actualSize._screenValue/2; // size are drawn vertically centered at the middle of the screen
    int y1p = displayHeight/2 - p_targetSize._screenValue/2;
    int y2 = y1 + p_actualSize._screenValue;
    int y2p = displayHeight/2 + p_targetSize._screenValue/2;
    rect(x, (y1+y1p)/2, actualSize._width, sizeError._screenValue/2); 
    rect(x, (y2+y2p)/2, actualSize._width, sizeError._screenValue/2);
  }
}

void drawTargetSize(Size p_size) {
  fill(p_size._color);
  int y = displayHeight/2; // size are drawn vertically centered at the middle of the screen
  int x = displayWidth/3; // sizes are draw at the left third of the screen
  rect(x, y, p_size._width, p_size._screenValue);
}

void drawActualSize(Size p_size) {
  fill(p_size._color);
  int y1 = displayHeight/2 - p_size._screenValue/2; // size are drawn vertically centered at the middle of the screen
  int y2 = y1 + p_size._screenValue;
  int x = displayWidth/3; // sizes are draw at the left third of the screen
  rect(x, y1, p_size._width, 10);
  rect(x, y2, p_size._width, 10);
}

void drawEnd() {
    
  datos = "";
  datos = "Finish time - "+stamp.format(new Date());
  escribir.appendTextToFile(outFilename, datos);
  datos = "";
  
  String s = "";
  background(0);
  textFont(f, 100); // specify font to be used
  textAlign(CENTER);

  // diviser le nb d'error total par le nombre de trial *100 pour avoir l'error rate
  float rate = float(nbErrors)/(blockDuration*totalNbBlocks)*100.;
    
  // if above, write "please slow down your pointing" and if below "Please speed up your pointing"
  //s += "(Error rate was ";
  //s += round(rate);
  //s += "%)\n";

  text("This series is over!\n" + s, displayWidth/2, displayHeight/2);  // display
}

void drawBeforeBlock() {
  String s = "";
  background(0);
  textFont(f, 100); // specify font to be used
  textAlign(CENTER);

  if (blockIndex != 0) {
    // diviser le nb d'error total par le nombre de trial *100 pour avoir l'error rate
    float rate = float(nbErrors)/(blockDuration*totalNbBlocks)*100.;
    // if above, write "please slow down your pointing" and if below "Please speed up your pointing"
    if (rate>4.) {
      //s += "Please slow down! \n(Error rate is ";
      //s += round(rate);
      //s += "%)\n";
    } 
    else if (rate<4.) {
      //s += "Please speed up! \n(Error rate is ";
      //s += round(rate);
      //s += "%)\n";
    }
  }
  
  if(!blockrdm){
    println("tamano "+config.size());
    
    rdm = int(random(config.size())); 
    println("random "+rdm+" = "+config.get(rdm));
    
    blockrdm = true;
  }
  
  if(graspIndex == 0) text("with one hand", displayWidth/2, displayHeight/1.5);  // display
  else if(graspIndex == 1) text("with two hands", displayWidth/2, displayHeight/1.5);  // display
  text(s + "Use " + config.get(rdm) + " slider", displayWidth/2, displayHeight/2);  // display
}