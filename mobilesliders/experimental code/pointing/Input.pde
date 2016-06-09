import java.io.*;

class Input extends Thread {
  private double _coord1x, _coord1y, _coord1z, _coord2x, _coord2y, _coord2z; // temporary coordinates before we check the geometry to map them to the slider
  private double _sliderSize;
  private double _cursorLocation;

  final private double size_calib = 146.5;
  final private double cursor_calib_small = 67.;

  public Input() {
    _sliderSize = 0.;
    _cursorLocation = 0.;
  }

  private double getDistance(double x1, double y1, double z1, double x2, double y2, double z2) {
    return  java.lang.Math.sqrt((x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2) + (z1 - z2)*(z1 - z2));
  }

  private double getDistance(double x1, double y1, double x2, double y2) {
    return  java.lang.Math.sqrt(java.lang.Math.pow(x1 - x2, 2) + java.lang.Math.pow(y1 - y2, 2));
  }

  public double getSliderSize() { // in mm
    return _sliderSize;
  }

  public double getCursorLocation() { // in mm
    return _cursorLocation;
  }

  public void run() {
    try {
      OutputStream stdin = null;
      Process p = Runtime.getRuntime().exec("/Users/celinecoutrix/Projets/ScalableObject/XP/software/tracking/Optitrack.py");
      //Process p = Runtime.getRuntime().exec("/Users/celinecoutrix/Projets/ScalableObject/XP/software/Optitrack_simulation/application.macosx/Optitrack_simulation.app/Contents/MacOS/Optitrack_simulation");
      BufferedReader in = new BufferedReader(new InputStreamReader(p.getInputStream()));

      String line;
      while ( (line = in.readLine ()) != null) {
        String[] list = split(line, '\t');

        if (list.length < 4) {
          println("ill formated line from Optitrack reading");
        } 
        else {
          int id = parseInt(trim(list[0])); // removing additional white space if any, otherwise the id is not correctly converted to int
          double coord_x = Double.parseDouble(list[1]);
          double coord_y = Double.parseDouble(list[2]);
          //double coord_z = Double.parseDouble(list[3]);

          switch(id) {
          case 0: // marker #0

              // we check the geometry
            double d01 = getDistance(coord_x, coord_y, _coord1x, _coord1y);
            double d12 = getDistance(_coord1x, _coord1y, _coord2x, _coord2y);
            double d02 = getDistance(coord_x, coord_y, _coord2x, _coord2y);

            _sliderSize = java.lang.Math.abs(java.lang.Math.max(java.lang.Math.max(d01, d12), d02) - size_calib);

            if (d01 == _sliderSize + size_calib) {
              // greatest distance between 0 and 1, means 2 is the cursor
              if (coord_y >= _coord1y) { // low y means above, lower bound is above, so 1 is lower bound
                _cursorLocation = d02 - cursor_calib_small; // distance between 0 (lower bound) and 2
              } 
              else { // 0 is lower bound
                _cursorLocation = d12 - cursor_calib_small; // distance between 1 (lower bound) and 2
              }
            } 
            else if (d12 == _sliderSize + size_calib) {
              // greatest distance between 1 and 2
              if (_coord1y >= _coord2y) { // low y means above, lower bound is above, so 2 is lower bound
                _cursorLocation = d01 - cursor_calib_small;
              } 
              else { // 1 is lower bound
                _cursorLocation = d02 - cursor_calib_small;
              }
            } 
            else {
              // greatest distance between 0 and 2
              if (coord_y >= _coord2y) { // low y means above, lower bound is above, so 2 is lower bound
                _cursorLocation = d01 - cursor_calib_small;
              } 
              else {
                _cursorLocation = d12 - cursor_calib_small;
              }
            }

            break;

          case 1: // marker #1
            _coord1x = coord_x;
            _coord1y = coord_y;
            //_coord1z = coord_z;
            break;

          case 2: // marker #2
            _coord2x = coord_x;
            _coord2y = coord_y;
            //_coord2z = coord_z;
            break;

          default:
            //println("could not identify marker");  
            break;
          }
        }
      }
    } 
    catch (Exception err) {
      err.printStackTrace();
    }
  }
}