class Measure { //  can be a cursor or a size

  // in px (screen space)
  int _screenValue;
  int _screenMin;
  int _screenMax;
  
  // in cm (sensor space)
  float _sensorValue;
  float _sensorMin;
  float _sensorMax; // for position cursor, _sensorMax is the size

  float _relativeValue;

  Measure(){
    _sensorValue = 10.;
    _screenValue = 100;
    
   _screenMin = 0;
   _screenMax = displayHeight;

   _sensorMin = 0;
   _sensorMax = 25; 
  }
  
  void updateSensorMaxValue(float p_sensorMax){
    _sensorMax = p_sensorMax; // for actual/target position cursor, _sensorMax is the size of the slider
  }

  void updateScreenMaxValue(int p_screenMax){
    _screenMax = p_screenMax; // for actual/target position cursor, _sensorMax is the size of the slider
  }

  void updateSensorMinValue(float p_sensorMin){
    _sensorMin = p_sensorMin; 
  }

  void updateScreenMinValue(int p_screenMin){
    _screenMin = p_screenMin;
  }

  Measure(int p_screenMin, int p_screenMax, float p_sensorMin, float p_sensorMax){
    _sensorValue = 10.;
    _screenValue = 100;
    _relativeValue = _screenValue/(_screenMax - _screenMin);
    
   _screenMin = p_screenMin;
   _screenMax = p_screenMax;

   _sensorMin = p_sensorMin;
   _sensorMax = p_sensorMin; 
  }
  
  
}