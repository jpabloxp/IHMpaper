class Size extends Measure {
 
  int _width; // in px (screen space)
  color _color;

  Size(int p_value, int p_width, color p_color) {
    super();

    updateSensorValue(p_value, true);
    _width = p_width;
    _color = p_color;    
  }

  void updateSensorValue(float p_value, boolean p_isFirst){
    _sensorValue = p_value;
    if (p_isFirst){
      updateScreenValue((int)map(_sensorValue, _sensorMin, _sensorMax, _screenMin, _screenMax), false);
    }
  }
  void updateScreenValue(int p_value, boolean p_isFirst){
    _screenValue = p_value;
    if(p_isFirst) {
      updateSensorValue((float)map(_screenValue, _screenMin, _screenMax, _sensorMin,_sensorMax), false);
    }
  }
}
