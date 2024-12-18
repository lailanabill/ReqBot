from flask import Flask, request, jsonify
import subprocess
import os

app = Flask(__name__)

# Define the process_audio function
def process_audio(file_path: str, task: str = "transcribe", model: str = "medium") -> str:
    try:
        # Run the whisper command with the specified arguments
        result = subprocess.run(
            ["whisper", file_path, "--model", model, "--task", task],
            capture_output=True,
            text=True
        )
        # Check for errors
        if result.returncode != 0:
            raise Exception(f"Error in Whisper: {result.stderr}")

        return result.stdout
    except Exception as e:
        return f"An error occurred: {str(e)}"

@app.route('/transcribe', methods=['POST'])
def transcribe_audio():
    # Check if an audio file is provided
    if 'file' not in request.files:
        return jsonify({"error": "No file provided"}), 400

    audio_file = request.files['file']
    file_path = f"./{audio_file.filename}"
    audio_file.save(file_path)  # Save the uploaded file temporarily

    # Process the audio file using Whisper
    output = process_audio(file_path, task="transcribe", model="medium")
    
    # Clean up: Delete the file after processing
    os.remove(file_path)

    # Return the result as JSON
    return jsonify({"transcription": output})

if __name__ == '__main__':
    app.run(debug=True)
