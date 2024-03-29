import javax.sound.midi.*;
import interfascia.*;
import java.io.*;
import java.util.Collection;
AMidiPlayer midiPlayer = new AMidiPlayer();

GUIController c;
IFButton b1, b2, b3, ib1, ib2, ib3, ib4, ib5, ibmethodR, ibmethodG, ibmethodB, ibmethodRGB;
IFLabel l;
PGraphics pg;

int anim = 0;
int clear = 0;
float i = 0;
int play = 0;
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
int sonMethod = 0; //default sonification by red values

void setup() {
  println("the thing has begun");
  //size (1000, 500); //canvas size
  fullScreen();
  background(255); //background color
  // Load the image and get its pixel data
  img = loadImage(imgname);
  imgx = img.width;
  imgy = img.height;
  image(img, 50, height/2-250);
  pg = createGraphics(width/2, height/2);
  
  line(startX, mouseYValue, endX, mouseYValue);
  //button stuff
  c = new GUIController (this);
  b1 = new IFButton ("Play", width/2 +300, height/2-250+40, 60, 20);
  b2 = new IFButton ("Clear", width/2 + 300, height/2-250+70, 60, 20);
  b3 = new IFButton ("Tog Anim", width/2 + 300, height/2-250+100, 60, 20);
  
  ib1 = new IFButton ("Mondrian", width/2 + 30, height/2-250+40, 70, 20);
  ib2 = new IFButton ("Starry Night", width/2 + 30, height/2-250+70, 70, 20);
  ib3 = new IFButton ("Nature", width/2 + 30, height/2-250+100, 70, 20);
  ib4 = new IFButton ("Buildings", width/2 + 30, height/2-250+130, 70, 20);
  ib5 = new IFButton ("Meme", width/2 + 30, height/2-250+160, 70, 20);
  
  ibmethodR = new IFButton ("Red", width/2 + 170, height/2-250+40, 70, 20);
  ibmethodG = new IFButton ("Green", width/2 + 170, height/2-250+70, 70, 20);
  ibmethodB = new IFButton ("Blue", width/2 + 170, height/2-250+100, 70, 20);
  ibmethodRGB = new IFButton ("Luminosity", width/2 + 170, height/2-250+130, 70, 20);
  
  b1.addActionListener(this);
  b2.addActionListener(this);
  b3.addActionListener(this);
  ib1.addActionListener(this);
  ib2.addActionListener(this);
  ib3.addActionListener(this);
  ib4.addActionListener(this);
  ib5.addActionListener(this);
  ibmethodR.addActionListener(this);
  ibmethodB.addActionListener(this);
  ibmethodG.addActionListener(this);
  ibmethodRGB.addActionListener(this);
  
  c.add (b1);
  c.add (b2);
  c.add (b3);
  c.add (ib1);
  c.add (ib2);
  c.add (ib3);
  c.add (ib4);
  c.add (ib5);
  c.add (ibmethodR);
  c.add (ibmethodB);
  c.add (ibmethodG);
  c.add (ibmethodRGB);
  
  fill(0);
  textSize(20);
  text("1. Select image from first column", width/2-100, 50);
  text("2. Select sonification parameter from second column", width/2-100, 70);
  text("3. Draw horizontal line over any area of the image", width/2-100, 90);
  text("4. Click play to hear sonification", width/2-100, 110);
  text("You can also choose to clear the animations with Clear, or toggle animations with Tog Anim", width/2-100, 130);
  
  fill(255, 0, 0); // for default red circle
}

void draw(){
  //image(img, 50, height/2-250);
  if (mousePressed) {
    endX = mouseX;
    stroke(0);
    line(startX, mouseYValue, endX, mouseYValue);
  }
  if (!mousePressed){
    
  }
  ellipse(width/2 + 190, height/2-250+10, 20, 20);
  
  if (anim %2 ==0){
    pg.beginDraw();
    for (Note n : midiPlayer.getNotes()) {
      //println(n.note);
      pg.rect(i, height/2- map(n.note, 0, 127, 0, height/2-100), random(20), random(20));
      //pg.rect(i, height/2- map(n.note, 0, 127, 0, height/2-100), 10, 10);
      i +=0.05;
    //fill(map(n.note % 12, 0, 11, 0, 255), 
    //  map(n.channel, 0, 15, 80, 255), 
    //  map(n.note, 0, 127, 100, 255) * random(0.9, 1.0));

    //pushMatrix();
    //float t = frameCount * 0.003;
    //scale(n.velocity * 0.05);
    //rotateX(n.channel + noise(n.note * 0.1, t));
    //rotateY(n.note * 0.06);
    //rotateZ(map(n.note % 12, 0, 12, 0, TWO_PI));
    //pushMatrix();
    //translate(0, n.velocity * 0.7, 0);
    //box(40.0 / n.living, n.velocity * 0.1 + random(10), 40.0 / n.living);
    //popMatrix();    
    //translate(0, 5000.0, 0);
    //box(0.2, 10000, 0.2);
    //popMatrix();
  }
  midiPlayer.update();
  }
  pg.endDraw();
  
  image(pg, width/2, height/2);
  
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
  //x1 = min(startX, endX)-50;
  //x2 = max(startX, endX)-50;
  //y = mouseYValue-(height/2-250);
  println(x1, x2, y);
  for (int x = x1; x <= x2; x++) {
    color pixel = img.get(x, y);
    // do something with the pixel value (e.g., display it on the screen)
    switch (sonMethod){
      case 0:
        fill(255, 0, 0);
        break;
      case 1:
        fill(0, 255, 0);
        break;
      case 2:
        fill(0, 0, 255);
        break;
      case 3:
        fill(255, 255, 255);
        break;
    }
    //fills line with color
    //fill(pixel);
    noStroke();
    rect(x, y, 1, 1);
  } 
  x1 = min(startX, endX)-50;
  x2 = max(startX, endX)-50;
  y = mouseYValue-(height/2-250);
}

void actionPerformed (GUIEvent e) {
  if (e.getSource() == b1) { //generate
    i = 0;
    switch(sonMethod){
      case 0:
        createMIDIseqRed(x1, x2, y);
        break;
      case 1:
        createMIDIseqGreen(x1, x2, y);
        break;
      case 2:
        createMIDIseqBlue(x1, x2, y);
        break;
      case 3:
        createMIDIseqRGB(x1, x2, y);
        break;
    }
    playMIDIseq();
  } else if (e.getSource() == b2) { 
    clear = 1;
    pg.beginDraw();
    pg.background(255);
    pg.endDraw();
    println("trying to clear");
  } else if (e.getSource() == b3) { 
     anim +=1;
  } else if (e.getSource() == ibmethodR){
     sonMethod = 0;
  } else if (e.getSource() == ibmethodG){
    sonMethod = 1;
  } else if (e.getSource() == ibmethodB){
    sonMethod = 2;
  } else if (e.getSource() == ibmethodRGB){
    sonMethod = 3;
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
    image(img, 50, height/2-250);
  }
}


void createMIDIseqRed(int xbegin, int xend, int liney){
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
    //println(i);
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
    File outputFile = new File(dataPath("output.mid"));
    //File outputFile = new File("/Users/yunxingao/Documents/stuff for school/Viz Wall Competition/MIDI_file_thing/output.mid");
    MidiSystem.write(seq, 1, outputFile);
    println("MIDI file saved successfully!");
  }
  catch (IOException ex) {
    println("Error saving MIDI file: " + ex.getMessage());
  }
  
}

void createMIDIseqGreen(int xbegin, int xend, int liney){
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
    //println(i);
    int pixelColor = img.pixels[i];
    int brightnessValue = int(green(pixelColor));
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
    File outputFile = new File(dataPath("output.mid"));
    //File outputFile = new File("/Users/yunxingao/Documents/stuff for school/Viz Wall Competition/MIDI_file_thing/output.mid");
    MidiSystem.write(seq, 1, outputFile);
    println("MIDI file saved successfully!");
  }
  catch (IOException ex) {
    println("Error saving MIDI file: " + ex.getMessage());
  }
  
}

void createMIDIseqBlue(int xbegin, int xend, int liney){
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
    //println(i);
    int pixelColor = img.pixels[i];
    int brightnessValue = int(blue(pixelColor));
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
    File outputFile = new File(dataPath("output.mid"));
    //File outputFile = new File("/Users/yunxingao/Documents/stuff for school/Viz Wall Competition/MIDI_file_thing/output.mid");
    MidiSystem.write(seq, 1, outputFile);
    println("MIDI file saved successfully!");
  }
  catch (IOException ex) {
    println("Error saving MIDI file: " + ex.getMessage());
  }
  
}

void createMIDIseqRGB(int xbegin, int xend, int liney){
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
    //println(i);
    int pixelColor = img.pixels[i];
    int brightnessValue = (int(blue(pixelColor))+int(red(pixelColor))+int(green(pixelColor)))/3;
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
    File outputFile = new File(dataPath("output.mid"));
    //File outputFile = new File("/Users/yunxingao/Documents/stuff for school/Viz Wall Competition/MIDI_file_thing/output.mid");
    MidiSystem.write(seq, 1, outputFile);
    println("MIDI file saved successfully!");
  }
  catch (IOException ex) {
    println("Error saving MIDI file: " + ex.getMessage());
  }
  
}

void playMIDIseq(){
  // Open the default sequencer and synthesizer
  play = 1;
  midiPlayer.load(dataPath("output.mid"));
  midiPlayer.start();
  
  //println("play begin");
  //try {
  //  sequencer = MidiSystem.getSequencer();
  //  sequencer.open();
  //  synthesizer = MidiSystem.getSynthesizer();
  //  synthesizer.open();
  //} catch (MidiUnavailableException ex) {
  //  ex.printStackTrace();
  //}
  //println("2");
  //// Load the MIDI file
  //try {
  //    File midiFile = new File("/Users/yunxingao/Documents/stuff for school/Viz Wall Competition/MIDI_file_thing/output.mid");
  //    //File midiFile = new File("output.mid");
  //    InputStream is = new FileInputStream(midiFile);
  //    Sequence sequence = MidiSystem.getSequence(is);
  //    sequencer.setSequence(sequence);
  //    //sequencer.start();
  //    println("3");
  //  } catch (Exception ex) {
  //    ex.printStackTrace();
  //    println("4");
  //  }
  
  //int instrumentIndex = 50;
  //Instrument[] instruments = synthesizer.getDefaultSoundbank().getInstruments();
  //Instrument instrument = instruments[instrumentIndex];
  ////println(instrument);
  //synthesizer.loadInstrument(instrument);
  //println("starting to play");
  
  //try{
  //  Synthesizer synth = MidiSystem.getSynthesizer();
  //  synth.open();
  //  MidiChannel channel = synth.getChannels()[0];
  //  channel.programChange(50); // Set instrument to piano
  //  sequencer.start();
  //} catch(Exception ex){
  //  ex.printStackTrace();
  //}
  //println("play end");
}
