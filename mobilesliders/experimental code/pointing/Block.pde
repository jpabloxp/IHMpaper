class Block {
  
  int _duration;
  
  int _difficultyChangeInterval; // between 0 and _duration elementary pointing tasks
  boolean _difficultyChanged;

  int _targetIndex;
  boolean _targetValidated;
  boolean _keyPressed;
  int _keyPressIndex;
  Timer _targetTimer;

  Block(int p_duration, int p_difficultyChangeInterval) {
    _duration = p_duration;
    _targetIndex = _duration; // to be decremented until 0.
    _targetValidated = false;
    _keyPressed = false;
    _keyPressIndex = 0;
    _targetTimer = new Timer(); // next dart off in between 2 and 4 seconds
   
    _difficultyChangeInterval = p_difficultyChangeInterval;
    _difficultyChanged = false; 
  }

}