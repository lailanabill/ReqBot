from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import whisper
from transformers import pipeline
from dotenv import load_dotenv
load_dotenv()

import os
import subprocess
from typing import Optional, List, Dict, Any
import time
# import psutil
# import GPUtil
# from pytube import YouTube
import matplotlib.pyplot as plt
import whisperx
import whisper
from whisperx import load_align_model, align
from whisperx.diarize import DiarizationPipeline, assign_word_speakers
import torch
import gc
torch.backends.cuda.matmul.allow_tf32 = False
torch.backends.cudnn.allow_tf32 = False
model_name = 'large-v2'
device = "cuda"
hf_token = os.getenv("HF_TOKEN")
compute_type = "float16"  # "int8_float16" or "int8"
batch_size = 8







# summarizer = pipeline("summarization",model="facebook/bart-large-cnn")  
# model = whisper.load_model("large")


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["POST","GET"],
    allow_headers=["*"],
)
def clean_gpu_memory():
    torch.cuda.empty_cache()
    gc.collect()


clean_gpu_memory()

@app.post("/whisper/")
async def transcribe_audio(file: UploadFile = File(...)):
    try:
        audio_file = f"temp_{file.filename}"
        with open(audio_file, "wb") as temp_file:
            temp_file.write(await file.read())
        _real_torch_load = torch.load
        def patched_load(*args, **kwargs):
            kwargs['weights_only'] = False  # force it to False!
            return _real_torch_load(*args, **kwargs)
        torch.load = patched_load  # 💥
        model = whisperx.load_model(model_name, device ,compute_type=compute_type)
        result = model.transcribe(audio_file,batch_size=batch_size, task="translate")
        clean_gpu_memory();del model
        segments = result["segments"]
        model_a, metadata = load_align_model(language_code='en', device=device)
        result_aligned = align(segments, model_a, metadata, audio_file, device)
        clean_gpu_memory();del model_a, metadata
        diarization_pipeline = DiarizationPipeline(use_auth_token=hf_token,device=device)
        diarization_result = diarization_pipeline(audio_file)
        clean_gpu_memory();del diarization_pipeline
        temp= assign_word_speakers(diarization_result, result_aligned)
        result_segments = temp['segments'],
        # word_seg = temp['word_segments']
        MeetMins: List[Dict[str, Any]] = []
        for result_segment in result_segments[0]:
            MeetMins.append(
                {
                    # "start": result_segment["start"],
                    # "end": result_segment["end"],
                    "text": result_segment["text"],
                    "speaker": result_segment["speaker"],
                }
            )




        return JSONResponse(content={
            "transcription": MeetMins
            # "running":"large",   
            # "length":"4500"
        })
    
    except Exception as e:
        return JSONResponse(
            content={"error": str(e)}, 
            status_code=500
        )


# @app.get("/")
# async def read_root():
#     return {"Hello": "World"}   

import os
import uvicorn
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port) 