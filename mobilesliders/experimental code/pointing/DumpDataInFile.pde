import java.text.*;
import java.util.Date;

class DumpDataInFile {
  
  DateFormat stamp;
  String dataFolder;
  PrintWriter output;
  
  
  DumpDataInFile(){}
      
  void appendTextToFile(String filename, String text){
    File f = new File(dataPath(filename));
    if(!f.exists()){
      createFile(f);
    }
    try {
      PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
      out.println(text);
      out.close();
    }catch (IOException e){
        e.printStackTrace();
    }
  }
  
  /**
   * Creates a new file including all subfolders
   */
  void createFile(File f){
    File parentDir = f.getParentFile();
    try{
      parentDir.mkdirs(); 
      f.createNewFile();
    }catch(Exception e){
      e.printStackTrace();
    }
  }   
  
  void setup_DumpDataInFile (String p_factors) {
    DateFormat dfm = new SimpleDateFormat("yyyyMMdd-HHmm");
  
    stamp = new SimpleDateFormat("yyyyMMdd-HHmmss");
    String fileName = stamp.format(new Date()) + "-" + p_factors + ".csv";
    output = createWriter("../../data_xp/" + fileName);
    
    stamp = new SimpleDateFormat("HH:mm:ss.SSS");
  }
  
  void dumpDataInFile(String temp) {
   if (output != null) {
    String message = stamp.format(new Date()) + temp;
    output.println(message);
    output.flush();
   }
  }
  
  void writeHeader(String temp) {
   if (output != null) {
    output.println(temp);
    output.flush();
   }
  }
}
