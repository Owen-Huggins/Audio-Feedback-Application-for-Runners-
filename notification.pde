enum NotificationType { badForm }

class Notification {
  
  int heartRate, paceMinute, paceSecond, timerMinute, timerSecond, stepCount, timestamp, pressureGauge;
  float bodyAngle;
  NotificationType type; // door, person_move, object_move, appliance_state_change, package_delivery, message

  
   public Notification(JSONObject json) {
    this.timestamp = json.getInt("timestamp");
    //time in milliseconds for playback from sketch start
    
    String typeString = json.getString("type");
    
    try {
      this.type = NotificationType.valueOf(typeString);
    }
    catch (IllegalArgumentException e) {
      throw new RuntimeException(typeString + " is not a valid value for enum NotificationType.");
    }
    
    
    this.heartRate = json.getInt("heartRate"); 
    this.paceMinute = json.getInt("paceMinute"); 
    this.paceSecond = json.getInt("paceSecond"); 
    this.timerMinute = json.getInt("timerMinute"); 
    this.timerSecond = json.getInt("timerSecond"); 
    this.stepCount = json.getInt("stepCount"); 
    this.pressureGauge = json.getInt("pressureGauge"); 
    this.bodyAngle = json.getFloat("bodyAngle"); 
    
   }
    
  
  
  public int getTimestamp() { return timestamp; }
  public NotificationType getType() { return type; }
 
  public int getHeartRate() { return heartRate; }
  public int getPaceMinute() { return paceMinute; }
  public int getPaceSecond() { return paceSecond; }
  public int getTimerMinute() { return timerMinute; }
  public int getTimerSecond() { return timerSecond; }
  public int getStepCount() { return stepCount; }
  public int getPressureGauge() { return pressureGauge; }
  public float getBodyAngle() { return bodyAngle; }
              
  
  public String toString() {
      String output = getType().toString() + ": ";
      output += "(heart rate: " + getHeartRate() + ") ";
      output += "(pace minute: " + getPaceMinute() + ") ";
      output += "(pace Second: " + getPaceSecond() + ") ";
      output += "(stepCount: " + getStepCount() + ") ";
      output += "(pressure gauge: " + getPressureGauge() + ") ";
      return output;
    }
}
