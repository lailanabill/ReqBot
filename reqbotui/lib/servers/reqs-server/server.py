from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel




app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["POST","GET"],
    allow_headers=["*"],
)


class InputText(BaseModel):
    inputString: str


@app.post("/reqs")
async def split_sentences(data: InputText):
    try:
        sentences = [s.strip() for s in data.inputString.split('.') if s.strip()]
        return JSONResponse(content={"sentences": sentences})
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)



import os
import uvicorn
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port) 