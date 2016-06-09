int oldStepIndex = 0;

int getSampledValue(Cursor p_cursor, int p_definition) {

  int step = (p_cursor._screenMax - p_cursor._screenMin)/(p_definition-1);
  if(step < 1){
    step = 1;
  }
  int StepIndex = int(p_cursor._screenValue - p_cursor._screenMin)/step; //  division entiere, on perd le reste de la division
  int newValue = p_cursor._screenMin + StepIndex*step; // on revient dans l'espace "screen cursor"
  /* 
  println("screenMin = " + p_cursor._screenMin + 
          ", screenMax = " + p_cursor._screenMax + 
          ", step = " + step + 
          ", old value = " + p_cursor._screenValue +
          ", new value = " + newValue);
  */
  return newValue;
}