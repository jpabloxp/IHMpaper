class Error {
  
  Measure _target;
  Measure _actual;
  
  int _screenValue; // in px (screen space)
  float _sensorValue; // in cm (sensor space)
  
  color _color;
  int _margin; // in px (screen space)
  
  Error(Measure p_target, Measure p_actual, color p_color, int p_margin){
    _target = p_target;
    _actual = p_actual;
    
    updateSensorValue(0., true);
    
    _color = p_color;
    _margin = p_margin;
  }

  void updateSensorValue(float p_value, boolean p_isFirst){
    _sensorValue = p_value;
    if (p_isFirst){
      updateScreenValue((int)map(_sensorValue, 0, _target._sensorMax - _target._sensorMin, 0, _target._screenMax - _target._screenMin), false);
    }
  }
  void updateScreenValue(int p_value, boolean p_isFirst){
    _screenValue = p_value;
    if (p_isFirst){
      updateSensorValue((float)map(_screenValue, 0, _target._screenMax - _target._screenMin, 0, _target._sensorMax - _target._sensorMin), false);
    }
  }
}