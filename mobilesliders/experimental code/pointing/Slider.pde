class Slider {

  int _loc_x; // in px (screen space)
  int _loc_y;  // in px (screen space)
  int _maxHeight; // in px (screen space)
  int _width; // in px (screen space)
  int _height; // in px (screen space)
  int _margin; // in px (screen space)

  color _color;

  Slider(int p_x, int p_y, int p_maxHeight, int p_width, color p_color, int p_margin) {
    _loc_x = p_x;
    _loc_y = p_y; 
    _maxHeight = p_maxHeight; 
    _height = _maxHeight;
    _width = p_width;
    _margin = p_margin;
    _color = p_color;
  }
}