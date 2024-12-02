import tkinter as tk  # tkinter and message box for UI
from tkinter import messagebox, filedialog  # display message dialogs and file dialog for file selection
import sounddevice as sd  # recording audio
from scipy.io.wavfile import write  # save recorded audio data as a .wav file
import numpy as np  # process audio data
import threading  # Allows recording to run in a separate thread, so the GUI remains responsive
import speech_recognition as sr  # Used for converting audio to text using Google’s speech recognition API

class VoiceRecorder:
    def __init__(self, root):
        self.root = root
        self.root.title("Voice Recorder")
        
        # settings
        self.fs = 44100  # frequency
        self.output_filename = "output.wav"  # File name for the saved audio
        self.audio_frames = []  # List to store chunks of recorded audio data
        self.recording = False  # Boolean flag to track whether recording is ongoing
        self.stream = None  # Variable to store the audio input stream

        self.label = tk.Label(root, text="Simple Voice Recorder")
        self.label.pack(pady=20)
        
        # Button to start recording
        self.record_button = tk.Button(root, text="Start Recording", command=self.start_recording)
        self.record_button.pack(pady=10)
        
        # Button to stop recording
        self.stop_button = tk.Button(root, text="Stop Recording", command=self.stop_recording, state="disabled")
        self.stop_button.pack(pady=10)
        
        # Button to upload and transcribe an audio file
        self.upload_button = tk.Button(root, text="Upload .wav Audio", command=self.upload_audio)
        self.upload_button.pack(pady=10)
      
        # Text box for displaying the transcribed text
        self.text_box = tk.Text(root, height=10, width=50)
        self.text_box.pack(pady=20)
        self.text_box.insert(tk.END, "Speech will be converted to text here...")

    def callback(self, indata, frames, time, status):
        """Callback function to store audio chunks."""
        self.audio_frames.append(indata.copy())

    def start_recording(self):
        if not self.recording:
            self.recording = True
            self.audio_frames = []
            self.record_button.config(state="disabled")
            self.stop_button.config(state="normal")
            self.record_thread = threading.Thread(target=self.record)
            self.record_thread.start()

    def record(self):
        try:
            self.stream = sd.InputStream(samplerate=self.fs, channels=1, callback=self.callback)
            with self.stream:
                while self.recording:
                    pass  # keep recording
        except Exception as e:
            messagebox.showerror("Error", f"Recording error: {str(e)}")

    def stop_recording(self):
        if self.recording:
            self.recording = False
            if self.stream is not None:
                self.stream.stop()  # Stop the recording stream
                self.stream = None
            messagebox.showinfo("Stopped", "Recording stopped.")
            self.stop_button.config(state="disabled")
            self.record_button.config(state="normal")
            if self.audio_frames:
                audio_data = np.concatenate(self.audio_frames)
                if audio_data.dtype != np.int16:
                    audio_data = np.int16(audio_data * 32767)
                write(self.output_filename, self.fs, audio_data)
                messagebox.showinfo("Saved", f"Audio saved as {self.output_filename}")
                self.convert_speech_to_text(self.output_filename)

    def convert_speech_to_text(self, audio_path):
        """Converts audio at the specified path to text and displays it."""
        r = sr.Recognizer()
        try:
            with sr.AudioFile(audio_path) as source:
                audio_data = r.record(source)
                text = r.recognize_google(audio_data)
                self.text_box.delete(1.0, tk.END)
                self.text_box.insert(tk.END, text)
                messagebox.showinfo("Transcription", "Speech-to-text conversion completed.")
        except Exception as e:
            messagebox.showerror("Error", f"Speech-to-text conversion failed: {str(e)}")

    def upload_audio(self):
        """Opens a file dialog to select a .wav file and converts it to text."""
        file_path = filedialog.askopenfilename(
            title="Select a .wav file",
            filetypes=(("WAV files", "*.wav"), ("All files", "*.*"))
        )
        if file_path:
            self.convert_speech_to_text(file_path)  # Convert the selected file to text

if __name__ == "__main__":
    root = tk.Tk()
    app = VoiceRecorder(root)
    root.mainloop()
