from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import whisper
from transformers import pipeline

# summarizer = pipeline("summarization",model="facebook/bart-large-cnn")  
model = whisper.load_model("large")


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["POST","GET"],
    allow_headers=["*"],
)


@app.post("/whisper/")
async def transcribe_audio(file: UploadFile = File(...)):
    try:
    
        temp_file_path = f"temp_{file.filename}"
        with open(temp_file_path, "wb") as temp_file:
            temp_file.write(await file.read())
        
        
        result = model.transcribe(
            temp_file_path, 
            task="translate",  
            fp16=False  
        )
        
    
        os.remove(temp_file_path)
        # ARTICLE=result["text"]
        # length=int(len(ARTICLE)*0.25)
        # fnl = summarizer(ARTICLE, max_length=length, min_length=5, do_sample=False)
        return JSONResponse(content={
            "transcription": result["text"]
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