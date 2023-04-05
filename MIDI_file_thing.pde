import javax.sound.midi.*;
import interfascia.*;
import java.io.*;

GUIController c;
IFButton b1, b2, ib1, ib2, ib3, ib4, ib5;
IFLabel l;

// Define some constants
final int CHANNEL = 1;
final int NOTE_ON = 0x90;
final int NOTE_OFF = 0x90;
Sequence seq; //there can be more
PImage img;
int imgx;
int imgy;
float scalefact = 0.3;
//True if a mouse button has just been pressed while no other button was.
boolean firstMousePress = false;

int startX, endX, mouseYValue; // for the line of pixels to be sonified
int x1, x2, y;
String imgname = "mondrian.png";

//midi related things
MidiDevice.Info[] infos;
Sequencer sequencer;
Synthesizer synthesizer;
Instrument[] instruments;
int instrumentIndex = 0;
boolean isPlaying = false;

void setup() {
  println("the thing has begun");
  size (1000, 500); //canvas size
  //fullScreen();
  background(255); //background color
  // Load the image and get its pixel data
  img = loadImage(imgname);
  imgx = img.width;
  imgy = img.height;
  image(img, 0, 0);
  
  line(startX, mouseYValue, endX, mouseYValue);
  //button stuff
  c = new GUIController (this);
  b1 = new IFButton ("Generate", width -100, 40, 60, 20);
  b2 = new IFButton ("Play", width - 100, 80, 60, 20);
  ib1 = new IFButton ("Mondrian", width/2 + 30, 40, 70, 20);
  ib2 = new IFButton ("Starry Night", width/2 + 30, 70, 70, 20);
  ib3 = new IFButton ("Nature", width/2 + 30, 100, 70, 20);
  ib4 = new IFButton ("Buildings", width/2 + 30, 130, 70, 20);
  ib5 = new IFButton ("Meme", width/2 + 30, 160, 70, 20);
  
  b1.addActionListener(this);
  b2.addActionListener(this);
  ib1.addActionListener(this);
  ib2.addActionListener(this);
  ib3.addActionListener(this);
  ib4.addActionListener(this);
  ib5.addActionListener(this);
  c.add (b1);
  c.add (b2);
  c.add (ib1);
  c.add (ib2);
  c.add (ib3);
  c.add (ib4);
  c.add (ib5);
}

void draw(){
  if (mousePressed) {
    endX = mouseX;
    stroke(0);
    line(startX, mouseYValue, endX, mouseYValue);
  }
  if (!mousePressed){
    
  }
  
}
void mousePressed(){
  startX = mouseX;
  endX = mouseX;
  mouseYValue = mouseY;
  
}
void mouseReleased() {
  // extract the selected pixels
  x1 = min(startX, endX);
  x2 = max(startX, endX);
  y = mouseYValue;
  
  for (int x = x1; x <= x2; x++) {
    color pixel = img.get(x, y);
    // do something with the pixel value (e.g., display it on the screen)
    fill(204, 102, 0); //fills line with orange
    //fill(pixel);
    noStroke();
    rect(x, y, 1, 1);
  }
}

void actionPerformed (GUIEvent e) {
  if (e.getSource() == b1) { //generate
    createMIDIseq(x1, x2, y);
  } else if (e.getSource() == b2) { //play
    playMIDIseq();
  } else {
      if (e.getSource() == ib1) {
      imgname = "mondrian.png";
    } else if (e.getSource() == ib2) {
      imgname = "starrynight.png";
    } else if (e.getSource() == ib3) {
      imgname = "nature.png";
    } else if (e.getSource() == ib4) {
      imgname = "buildings.png";
    } else if (e.getSource() == ib5) {
      imgname = "meme.png";
    }
    img = loadImage(imgname);
    image(img, 0, 0);
  }
}


void createMIDIseq(int xbegin, int xend, int liney){
  img.loadPixels();
    // Create a new MIDI sequence
  try {
    seq = new Sequence(Sequence.PPQ, 5);
    println("new midi sequence generated");
  }
  catch (Exception ex) {
    ex.printStackTrace();
  }

  // Create a new MIDI track
  Track track = seq.createTrack();

   // Set the initial time stamp to 0
  int time = 0;
  // Iterate through the pixels of the image and generate MIDI notes based on their values
  for (int i = xbegin+liney * img.width; i < xend + liney * img.width; i++) {
    println(i);
    int pixelColor = img.pixels[i];
    int brightnessValue = int(red(pixelColor));
    int noteValue = int(map(brightnessValue, 0, 255, 0, 127));
    int velocity = 127;

    // Add a note on event to the MIDI track
    ShortMessage noteOn = new ShortMessage();
    //noteOn.setMessage(NOTE_ON, CHANNEL, noteValue, velocity);
    try {
      noteOn.setMessage(NOTE_ON, CHANNEL, noteValue, velocity);
      //xxx.setMessage(command, channel, note, velocity);
      //println("2");
    }
    catch (InvalidMidiDataException ex) {
      ex.printStackTrace();
    }
    MidiEvent noteOnEvent = new MidiEvent(noteOn, time);
    track.add(noteOnEvent);

    // Add a note off event to the MIDI track
    ShortMessage noteOff = new ShortMessage();
    //noteOff.setMessage(NOTE_OFF, CHANNEL, noteValue, velocity);
    try {
      noteOff.setMessage(NOTE_OFF, CHANNEL, noteValue, velocity);
      //println(3);
    }
    catch (InvalidMidiDataException ex) {
      ex.printStackTrace();
    }

    MidiEvent noteOffEvent = new MidiEvent(noteOff, time + 1);
    track.add(noteOffEvent);
    time++;
  }
  //try{
  //  sequencer.setSequence(seq);
  //  sequencer.setTempoInBPM(220);
  //} catch(InvalidMidiDataException ex){
  //  ex.printStackTrace();
  //}
  // Save the MIDI sequence as a standard MIDI file
  try {
    File outputFile = new File("/Users/yunxingao/Documents/stuff for school/Viz Wall Competition/MIDI_file_thing/output.mid");
    MidiSystem.write(seq, 1, outputFile);
    println("MIDI file saved successfully!");
  }
  catch (IOException ex) {
    println("Error saving MIDI file: " + ex.getMessage());
  }
  
}

void playMIDIseq(){
  // Open the default sequencer and synthesizer
  println("play begin");
  try {
    sequencer = MidiSystem.getSequencer();
    sequencer.open();
    synthesizer = MidiSystem.getSynthesizer();
    synthesizer.open();
  } catch (MidiUnavailableException ex) {
    ex.printStackTrace();
  }
  println("2");
  // Load the MIDI file
  try {
      File midiFile = new File("/Users/yunxingao/Documents/stuff for school/Viz Wall Competition/MIDI_file_thing/output.mid");
      InputStream is = new FileInputStream(midiFile);
      Sequence sequence = MidiSystem.getSequence(is);
      sequencer.setSequence(sequence);
      //sequencer.start();
      println("3");
    } catch (Exception ex) {
      ex.printStackTrace();
      println("4");
    }
  
  int instrumentIndex = 0;
  Instrument[] instruments = synthesizer.getDefaultSoundbank().getInstruments();
  Instrument instrument = instruments[instrumentIndex];
  synthesizer.loadInstrument(instrument);
  println("almost playing");
  sequencer.start();
  
  //try {
  //  //Thread.sleep(1000); // Wait for 1 second
  //  sequencer.start();
  //  //Thread.sleep(10000); // Wait for 10 seconds
  //  sequencer.stop();
  //} catch (InterruptedException ex) {
  //  ex.printStackTrace();
  //}
  println("play end");
}
