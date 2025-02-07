from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import whisper
import os
from fastapi.responses import JSONResponse

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["POST","GET"],
    allow_headers=["*"],
)

#mumken nekhtar medium aw large
model = whisper.load_model("large")

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
        
        
        return JSONResponse(content={
            "transcription": result["text"],
            "detected_language": result.get("language", "Unknown")
        })
    
    except Exception as e:
        # Handle any errors during transcription
        return JSONResponse(
            content={"error": str(e)}, 
            status_code=500
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8081, reload=True)