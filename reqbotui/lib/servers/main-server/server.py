from fastapi import FastAPI, UploadFile, File, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import replicate
# import whisper
# from transformers import pipeline
from dotenv import load_dotenv



# import sys
import os

# Go up one level to reach project_root
# project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
# sys.path.append(project_root)
# from lama.SequenceDiagram import SequenceDiagramDriver
# from lama.classdiagram import ClassDiagramDriver
# from lama.contextdiagram import ContextDiagramDriver
# from lama.databaseschema import DbDiagramDriver
# from lama.usecasediagram import UseCasDiagramDriver

from lama import ClassDiagramDriver, ContextDiagramDriver, DbDiagramDriver, SequenceDiagramDriver, UseCasDiagramDriver


load_dotenv()





import os
import subprocess
from typing import Optional, List, Dict, Any
# import time
# import psutil
# import GPUtil
# from pytube import YouTube
import matplotlib.pyplot as plt
# import whisperx
# import whisper
from whisperx import load_align_model, align
from whisperx.diarize import DiarizationPipeline, assign_word_speakers
import torch
import gc
torch.backends.cuda.matmul.allow_tf32 = False
torch.backends.cudnn.allow_tf32 = False



model_name = 'large-v2'
# device = "cuda"
device = "cpu"
hf_token = os.getenv("HF_TOKEN")
# hf_token = os.getenv("HF_TOKEN")
# compute_type = "float16"  # "int8_float16" or "int8"
compute_type = "int8"  # "int8_float16" or "int8"
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




        # model = whisperx.load_model(model_name, device ,compute_type=compute_type)
        # result = model.transcribe(audio_file,batch_size=batch_size, task="translate")
        # os.remove(audio_file)
        clean_gpu_memory()
        # clean_gpu_memory();del model
        segments = output["segments"]
        model_a, metadata = load_align_model(language_code='en', device=device)
        result_aligned = align(segments, model_a, metadata, audio_file, device)
        clean_gpu_memory();del model_a, metadata
        diarization_pipeline = DiarizationPipeline(use_auth_token=hf_token,device=device)
        diarization_result = diarization_pipeline(audio_file)
        clean_gpu_memory();del diarization_pipeline
        temp= assign_word_speakers(diarization_result, result_aligned)
        result_segments = temp['segments']
        # word_seg = temp['word_segments']
        MeetMins: List[Dict[str, Any]] = []
        # print("result_segments",result_segments[0])
        # print("result_segments",result_segments)
        # for result_segment in result_segments:
        #     MeetMins.append(
        #         {
        #             # "start": result_segment["start"],
        #             # "end": result_segment["end"],
        #             "text": result_segment["text"],
        #             "speaker": result_segment["speaker"],
        #         }
        #     )
        for result_segment in result_segments:
            if "speaker" in result_segment and "text" in result_segment:
                MeetMins.append({
                    "text": result_segment["text"],
                    "speaker": result_segment["speaker"],
                })
            else:
                print("⚠️ Missing keys in result_segment:", result_segment)

            
        



        # del model , model_a , metadata , diarization_pipeline
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
    
@app.post("/reqsneww/")
async def extract_requirements(request: Request):

    try:
        data = await request.json()
        meeting_sum = data.get("summ", "")
        meeting_text = data.get("orig", "")
        if not meeting_text:
            return JSONResponse(content={"error": "No meeting text provided"}, status_code=400)
        prompt = (
                # "extract from the following software meeting the functional and non functional requirements. :\n\n" + meeting_text
                f""""
                You are a senior software requirements analyst.

                You will be given a meeting transcription related to a software project. Your task is to extract all the requirements that are discussed either explicitly or implicitly during the meeting.
                Functional Requirements describe what the system should do — features, behaviors, actions, APIs, user interactions.

                Non-Functional Requirements describe how the system should perform — performance, reliability, scalability, usability, security, maintainability, etc.

                You may infer requirements that are implied by the conversation, not just the ones directly stated.

                Use clear, concise phrasing.
                Output Format:
                Functional Requirements:
                
                F1) "..."

                F2)"..."

                Non-Functional Requirements:
                NF1) "..."

                NF2)"..."
                
                Additional Instructions:
                
                you will be provided with both the original meeting transcription and meeting transcription summary you need extract the requirements while considering the summary as well as the original transcription.    

                Rephrase into requirement-style or interpretations.

                Only output requirements — do not include speaker names or summaries.

                If a requirement covers both functional and non-functional aspects, list it in both sections.
                
                Meeting Transcript: {meeting_text}
                Meeting Summary: {meeting_sum}
    """
            )

        response = subprocess.run(
            ["ollama", "run", "llama3", "temperature", "0", "top_p", "1", "top_k", "1", "seed","42","keep-alive","0"],
            input=prompt.encode(),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True,
        )
        output = response.stdout.decode()
        clean_gpu_memory()
        return JSONResponse(content={
            "reqs":output
        })
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

@app.post("/diagrams/")
async def generate_diagram(request: Request ):
    data = await request.json()
    transcript= data.get("transcript", "")
    pid = data.get("pid", 0)
    ClassDiagramDriver(transcript,pid)
    ContextDiagramDriver(transcript,pid)
    DbDiagramDriver(transcript,pid)
    SequenceDiagramDriver(transcript,pid)
    UseCasDiagramDriver(transcript,pid)
    return JSONResponse(content={
        "message":"Diagrams generated successfully",
        "pid":pid
    })



import os
import uvicorn
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port) 