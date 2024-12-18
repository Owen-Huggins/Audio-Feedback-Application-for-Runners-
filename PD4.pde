import controlP5.*;
import beads.*;
import java.util.Arrays; 

import ddf.minim.*;
import processing.sound.*;


import guru.ttslib.*;

import processing.core.*;
import com.sun.speech.freetts.*; 
import com.sun.speech.freetts.Voice;

import com.sun.speech.freetts.FreeTTS;
import com.sun.speech.freetts.Voice;
import com.sun.speech.freetts.VoiceManager;

Voice voice; 
TTS tts;
Minim minim;

ControlP5 cp5;
Slider slider;

SoundFile stepSound, inhale;
 
int stepCount, heartRate, paceMinute, paceSecond, timerMinute, timerSecond; 
float footStrikePos, bodyAngle, pace;
PShape footStrikeArea;
color fore = color(255, 255, 255);
color back = color(0,0,0);
ControlP5  p5;

Gain masterGain;
Glide masterGainGlide;


Textfield timerMin;
Textfield timerSec;
Textfield paceMin;
Textfield paceSec;
LowPass lowPass;

Boolean out = false; 
int currentStep = 0; 


Button startEventStream;
Button pauseEventStream;
Button stopEventStream;



String eventDataJSON = "test1.json";





SinOsc sine; 

JSONObject json;
JSONArray jsonArr; 
Boolean start = false; 
 
void setup() {
  size(800, 800, P2D);
  System.setProperty("freetts.voices", "com.sun.speech.freetts.en.us.cmu_us_kal.KevinVoiceDirectory");

  voice = VoiceManager.getInstance().getVoice("kevin16");
    tts = new TTS();
    
  lowPass = new LowPass(this);

    
  
   

  minim = new Minim(this);

  

   
  //load audio samples
  stepSound = new SoundFile(this, "run.mp3"); 
  sine = new SinOsc(this);
  sine.play();

  

  cp5 = new ControlP5(this);
  ac = new AudioContext();
   masterGainGlide = new Glide(ac, .2, 200);  
   masterGain = new Gain(ac, 1, masterGainGlide);
  ac.out.addInput(masterGain);
 
 

 
 
   startEventStream = cp5.addButton("startEventStream")
    .setPosition(300,400)
    .setSize(150,20)
    .setLabel("Start Event Stream");
    
   
 
  startEventStream = cp5.addButton("stopEventStream")
    .setPosition(300,300)
    .setSize(150,20)
    .setLabel("Stop Event Stream");

 

  
   cp5.addMatrix("pressureGauge")
     .setPosition(0,600)
     .setSize(75,150)
     .setMode(ControlP5.SINGLE_COLUMN)
     .setGrid(3, 5);
    


     
  cp5.addSlider("stepCountSlider")
     .setPosition(300,700)
     .setSize(100,20)
     .setRange(1,4)
     .setValue(2)
     .setNumberOfTickMarks(4);  
     
  cp5.addSlider("bodyAngleSlider")  
     .setPosition(600,700)       
     .setSize(100,20)
     .setRange(-45,45)
     .setValue(0)
     .setNumberOfTickMarks(7);
     
     
     cp5.addSlider("heartRateSlider")
     .setPosition(300,100)       
     .setSize(100,20)
     .setRange(50,120)
     .setValue(90);
     
     
   
     
     cp5.addTextfield("Timer Minute")
     .setPosition(600, 100) 
     .setSize(50, 20)
     .setAutoClear(false);
     
      cp5.addTextfield("Timer Second")
      .setPosition(700, 100)
      .setSize(50, 20)
      .setAutoClear(false);
        
                
   cp5.addTextfield("Pace Minute")
     .setPosition(0, 100) 
     .setSize(50, 20)
     .setAutoClear(false);
     
    cp5.addTextfield("Pace Second")
    .setPosition(100, 100)
    .setSize(50, 20)
    .setAutoClear(false);
    
  

  textAlign(LEFT);
  
  ac.start(); 
}



void startEventStream() {
  start = true; 
  //loading the event stream, which also starts the timer serving events 
 
}



void stopEventStream() {
  //loading the event stream, which also starts the timer serving events
  start = false; 
  reset();
}




void draw() {
  background(back);
 stroke(fore);
  stepCount = int(cp5.getController("stepCountSlider").getValue());  
  bodyAngle =  cp5.getController("bodyAngleSlider").getValue();
  if (start == true) {
    
      jsonArr = loadJSONArray(eventDataJSON);
      println(jsonArr.size()); 
      for(int i = 0; i < jsonArr.size(); i++) {
         test(jsonArr.getJSONObject(i)); 
         
      }
       
  }
    
     float pos = bodyAngle / 45; 
     float amp = (abs(bodyAngle / 45) / 45); 
     sine.amp(max(0.001, amp)); 
     sine.pan(pos); 
     sine.play(); 
     lowPass.process(sine, 800);
  

  heartRate = int(cp5.getController("heartRateSlider").getValue());
  if (heartRate >= 100) {
    if (heartRate >=120) {
      if (stepCount > 2) {
          cp5.getController("stepCountSlider").setValue(2);
      }
    } if (stepCount > 3) {
          cp5.getController("stepCountSlider").setValue(3);
    }
  } else if (heartRate <= 70) { 
    if (heartRate <= 50) {
      if (stepCount < 4) {
              cp5.getController("stepCountSlider").setValue(4);
      }
    } if (stepCount < 3) {
          cp5.getController("stepCountSlider").setValue(3);
    }
  }

    

 
 
 paceMinute =  int(cp5.get(Textfield.class,"Pace Minute").getText());
 paceSecond =  int(cp5.get(Textfield.class,"Pace Second").getText());

  // Display timetext
  
  text("Time: " + (paceMinute) + ":" + (paceSecond), 20, 50);

  
 timerMinute =  int(cp5.get(Textfield.class,"Timer Minute").getText());
 timerSecond =  int(cp5.get(Textfield.class,"Timer Second").getText());
   text("Time: " + (timerMinute) + ":" + (timerSecond), 700, 50);
   if (paceMinute != 0 && paceSecond != 0 && timerMinute != 0 && timerSecond != 0) { 
        spacePan(paceMinute, paceSecond, timerMinute, timerSecond); 

   }
   



  int[][] cells = ( cp5.get(Matrix.class, "pressureGauge").getCells() );
  
   for(int i = 0; i < cells.length; i++) {
      int counter = 0; 
      
      for(int j = 0; j < cells[i].length; j++) {
        if (cells[i][j] != 0) {
           
          changePitch(counter, stepCount); 
           
           cp5.get(Matrix.class, "pressureGauge").clear();
        }
        counter++;
         
      }
    }

}


void changePitch(int num, int stepCount) {
    float pitch;  
    currentStep += 1;
    if (currentStep == stepCount) { 
      int freq; 
      if(num == 4) {
        freq = 25;  
      }
      else if(num == 3) {
        freq = 50;  
      }
      else if(num == 2) {
        freq = 100; // Middle frequency
      }
      else if(num == 1) {
       freq = 300;
      }
      else {
        freq = 450;  
      }
      
      tts.setPitch(freq); 
      if (out) { 
        tts.speak("exhale"); 
      }else {
        tts.speak("inhale"); 

      }
      out = !out; 
      currentStep = 0; 
      
      
    } else {
       if(num == 4) {
        pitch = 0.5; 
      } 
      else if(num == 3) {
        pitch = 0.75;
      }
      else if(num == 2) {
        pitch = 1.0; 
      }
      else if(num == 1) {
        pitch = 1.75;
      } 
      else {
        pitch = 2.5; // num == 4
      }
   
    
 
      stepSound.play(pitch);
     

  }
 
  
}


void spacePan(int paceMinute, int paceSecond, int timerMinute, int timerSecond) { 
  
  int paceTime = ((paceMinute * 60) + paceSecond); 
  int timerTime = ((timerMinute * 60) + timerSecond); 
  
  
  if (paceTime > timerTime) { 

    stepSound.amp(min(paceTime / timerTime, 1));
    
  } else {
      stepSound.amp(max( paceTime / timerTime, 0.1)); 

  }

} 





void reset() {
          cp5.getController("stepCountSlider").setValue(2);
        cp5.getController("heartRateSlider").setValue(90);
         cp5.get(Textfield.class,"Pace Minute").clear(); 
        cp5.get(Textfield.class,"Pace Second").clear(); 
        cp5.get(Textfield.class,"Timer Minute").clear(); 
        cp5.get(Textfield.class,"Timer Second").clear(); 
        cp5.getController("bodyAngleSlider").setValue(0);
         cp5.get(Matrix.class, "pressureGauge").clear();
}

void test(JSONObject json) {
   
        
       
        cp5.getController("stepCountSlider").setValue(json.getInt("stepCount"));
        cp5.getController("heartRateSlider").setValue(json.getInt("heartRate"));
          cp5.get(Textfield.class,"Pace Minute").setText(json.getString("paceMinute")); 
          cp5.get(Textfield.class,"Pace Second").setText(json.getString("paceSecond")); 
        cp5.get(Textfield.class,"Timer Minute").setText(json.getString("timerMinute")); 
          cp5.get(Textfield.class,"Timer Second").setText(json.getString("timerSecond")); 
        cp5.getController("bodyAngleSlider").setValue(json.getFloat("bodyAngle"));
         cp5.get(Matrix.class, "pressureGauge").set(1, json.getInt("pressureGauge"), true);
         
     
      start = false; 
}
