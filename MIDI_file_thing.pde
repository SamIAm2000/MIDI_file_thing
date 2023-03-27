import javax.sound.midi.*;
import java.io.FileWriter;   // Import the FileWriter class
import java.io.IOException;  // Import the IOException class to handle errors

// Define some constants
final int CHANNEL = 0;
final int NOTE_ON = 0x90;
final int NOTE_OFF = 0x80;
Sequence seq;

void setup() {
  println("the thing has begun");
  // Load the image and get its pixel data
  PImage img = loadImage("drawing.png");
  img.loadPixels();

  // Create a new MIDI sequence
  try {
    seq = new Sequence(Sequence.PPQ, 10);
    println("1");
  }
  catch (Exception ex) {
    ex.printStackTrace();
  }

  // Create a new MIDI track
  Track track = seq.createTrack();

  // Iterate through the pixels of the image and generate MIDI notes based on their values
  for (int i = 0; i < img.pixels.length; i++) {
    int pixelColor = img.pixels[i];
    int brightnessValue = int(red(pixelColor));
    int noteValue = int(map(brightnessValue, 0, 255, 0, 127));
    int velocity = 127;

    // Add a note on event to the MIDI track
    ShortMessage noteOn = new ShortMessage();
    //noteOn.setMessage(NOTE_ON, CHANNEL, noteValue, velocity);
    try {
      noteOn.setMessage(NOTE_ON, CHANNEL, noteValue, velocity);
      //println("2");
    }
    catch (InvalidMidiDataException ex) {
      ex.printStackTrace();
    }
    MidiEvent noteOnEvent = new MidiEvent(noteOn, i);
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

    MidiEvent noteOffEvent = new MidiEvent(noteOff, i + 1);
    track.add(noteOffEvent);
  }

  // Save the MIDI sequence as a standard MIDI file
  try {
    File outputFile = new File("/Users/yunxingao/Documents/stuff for school/Viz Wall Competition/MIDI_file_thing/output.mid");
    MidiSystem.write(seq, 1, outputFile);
    println("MIDI file saved successfully!");
  }
  catch (IOException ex) {
    println("Error saving MIDI file: " + ex.getMessage());
  }

  // Exit the sketch
  exit();
}
