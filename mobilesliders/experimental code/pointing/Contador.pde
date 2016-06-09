import java.io.*;

class Contador extends Thread {
  
  private int secs;

  public Contador(int secs) {
     this.secs = secs;
  }

  public void run() {
    
    long imp = System.currentTimeMillis();
    try {
      for (int i=0; i<secs; i++) {
        println("\tSleeping: " + (i+1) + " secs.");
        this.sleep(30);
        println(" Termino ");
      }
      
      println("Tiempo: "+((System.currentTimeMillis() - imp) ));
    }
    catch (InterruptedException e) {
      e.printStackTrace();
    }
  }
  
}