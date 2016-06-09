class Timer {
 
  int savedTime; // When Timer started
  int totalTime; // How long Timer should last (ms)
  
  Timer(int tempTotalTime) {
    totalTime = tempTotalTime;
  }
  
  Timer() {
    totalTime = 0;
  }
  
  // Starting the timer
  void start() {
    // When the timer starts it stores the current time in milliseconds.
    savedTime = millis(); 
  }
  
  int get() {
    int passedTime = millis() - savedTime;
    return passedTime;
  }
  
  // stopping the time
  int getAndStop() {
    int passedTime = millis() - savedTime;
    return passedTime;
  }
  
  // The function isFinished() returns true if 5,000 ms have passed. 
  // The work of the timer is farmed out to this method.
  boolean isFinished() { 
    // Check how much time has passed
    int passedTime = millis()- savedTime;
    if (passedTime >= totalTime) {
      return true;
    } else {
      return false;
    }
   }
 
  int remainingTime() {
    return totalTime - (millis() - savedTime);
  }
 
 }
