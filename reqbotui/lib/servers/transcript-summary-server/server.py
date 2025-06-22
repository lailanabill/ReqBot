from fastapi import FastAPI, UploadFile, File, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import replicate
from dotenv import load_dotenv
import os
import subprocess
from typing import Optional, List, Dict, Any
from whisperx import load_align_model, align
from whisperx.diarize import DiarizationPipeline, assign_word_speakers
import torch
import gc
torch.backends.cuda.matmul.allow_tf32 = False
torch.backends.cudnn.allow_tf32 = False
TF_ENABLE_ONEDNN_OPTS=0

load_dotenv()

app = FastAPI()
model_name = 'large-v2'
device = "cpu"
hf_token = os.getenv("HF_TOKEN")
compute_type = "int8" 
batch_size = 8


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
        audio_file_replicate=open(audio_file, "rb")
        print(audio_file)
        _real_torch_load = torch.load
        def patched_load(*args, **kwargs):
            kwargs['weights_only'] = False  # force it to False!
            return _real_torch_load(*args, **kwargs)
        torch.load = patched_load  # 💥
        ## replicate integration
        input={
        
        "file": audio_file_replicate,
        "prompt": "LLama, AI, Meta.",
        "file_url": "",
        "language": "en",
        "translate": False,
        "group_segments": True
    }
        output = replicate.run(
    "thomasmol/whisper-diarization:1495a9cddc83b2203b0d8d3516e38b80fd1572ebc4bc5700ac1da56a9b3ed886",
    input=input,
)
        clean_gpu_memory()
        segments = output["segments"]
        model_a, metadata = load_align_model(language_code='en', device=device)
        result_aligned = align(segments, model_a, metadata, audio_file, device)
        clean_gpu_memory();del model_a, metadata
        diarization_pipeline = DiarizationPipeline(use_auth_token=hf_token,device=device)
        diarization_result = diarization_pipeline(audio_file)
        clean_gpu_memory();del diarization_pipeline
        temp= assign_word_speakers(diarization_result, result_aligned)
        result_segments = temp['segments']
        MeetMins: List[Dict[str, Any]] = []
        for result_segment in result_segments:
            if "speaker" in result_segment and "text" in result_segment:
                MeetMins.append({
                    "text": result_segment["text"],
                    "speaker": result_segment["speaker"],
                })
            else:
                print("⚠️ Missing keys in result_segment:", result_segment)
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

@app.post("/summarize/")
async def summarize_meeting(request: Request):
    clean_gpu_memory()
    try:
        data = await request.json()
        meeting_text = data.get("text", "")
        if not meeting_text:
            return JSONResponse(content={"error": "No meeting text provided"}, status_code=400)

        prompt = (
            
            f""""
            You are an expert technical software analyst, meeting assistant, and summarizer.
Your task is to generate a detailed, context-aware summary of the following software development meeting.
The summary must:
- Preserve speaker roles and their specific contributions (use names and roles clearly).
- Include all key decisions made, problems raised, solutions proposed, technical updates, and assigned actions.
- Maintain the logical flow of the meeting.
- Group related topics by theme (e.g., Task Management, Notifications, UX, Performance, Sprint Planning).
- Include backend, frontend, QA, UX, and project management updates, including technical improvements such as refactoring, modularization, and error handling.
- Highlight both hard and soft aspects: implementation details, design standards (e.g., UI/UX modals), documentation plans, Jira updates, and sprint goals or deadlines.
- Avoid summarizing away details that may be useful for downstream software requirement extraction.
Style Guidelines:
- Use bullet points or nested lists grouped by topic for clarity.
- Keep the summary factual — do not rephrase into requirement-style or interpretations.
- Do not omit important context such as technical constraints, timing (e.g., deadlines), component interactions, or rationale for decisions.
- Write only the summary, no introductory or closing text.
- Do not group into sections.
Meeting Transcript:
{meeting_text}
            """
        )
        response = subprocess.run(
            ["ollama", "run", "llama3", "temperature ", "0.7" ,"keep-alive","0"],
            input=prompt.encode(),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        output = response.stdout.decode()
        clean_gpu_memory()
        return JSONResponse(content={
            "summary": output,
        })
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)
    


import os
import uvicorn
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port) 