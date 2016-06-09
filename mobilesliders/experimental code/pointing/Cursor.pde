class Cursor extends Measure {
  
  Size _sizeOfRef;
  
  float _sensorHeight; // in cm (sensor space)
  int _screenHeight; // in px (screen space)
  
  float _relativeHeight; // height relative the slider height
  
  int _margin; // in px (screen space)
  color _color;
  
  Cursor(Size p_size, color p_color, int p_margin){
    
    super();
    
    _sizeOfRef = p_size;
    
    updateSensorValue(0., true);
    updateSensorHeight(_sizeOfRef._sensorMax/_sizeOfRef._sensorValue, true);
    
    this.updateSensorMinValue(0);
    this.updateSensorMaxValue(_sizeOfRef._sensorValue);
    
    _color = p_color;
    _margin = p_margin;
  }
  
  void updateSensorValue(float p_value, boolean p_isFirst){
    _sensorValue = p_value;
    if (p_isFirst) {
      updateScreenValue((int)map(_sensorValue, _sensorMin, _sensorMax,_screenMin, _screenMax), false);
    }
  }
  void updateScreenValue(int p_value, boolean p_isFirst){
    _screenValue = p_value;
    if (p_isFirst) {
      updateSensorValue((float)map(_screenValue, _screenMin, _screenMax, _sensorMin, _sensorMax), false);
    }
  }
  void updateScreenValue(int p_value){
    _screenValue = p_value;
  }
  void updateSensorHeight(float p_width, boolean p_isFirst){
    _sensorHeight = p_width;
    if (p_isFirst) {
      updateScreenHeight((int)map(_sensorHeight, 0, _sizeOfRef._sensorValue, 0, _sizeOfRef._screenValue), false);
    }
  }
  void updateScreenHeight(int p_width, boolean p_isFirst){
    _screenHeight = p_width;
    if (p_isFirst) {
      updateSensorHeight((float)map(_screenHeight, 0, _sizeOfRef._screenValue, 0, _sizeOfRef._sensorValue), false);
    }
  }
}
