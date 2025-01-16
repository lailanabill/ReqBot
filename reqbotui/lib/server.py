from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import whisper
import os
from pydub import AudioSegment
from pydub.silence import split_on_silence
from fastapi.responses import JSONResponse
from pydantic import BaseModel

import subprocess


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["POST","GET"],
    allow_headers=["*"],
)

# Load the Whisper model
model = whisper.load_model("base")

@app.post("/whisper/")
async def transcribe_audio(file: UploadFile = File(...)):
    temp_file_path = f"temp_{file.filename}"
    with open(temp_file_path, "wb") as temp_file:
        print(temp_file_path)
        temp_file.write(await file.read())
    result = model.transcribe(temp_file_path)
    print('shits  ',result)
    os.remove(temp_file_path)
    # return {"transcription": result["text"]}
    return JSONResponse(content={"transcription": result["text"]})


