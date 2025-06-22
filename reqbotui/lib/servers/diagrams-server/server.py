
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse


from lama import ClassDiagramDriver, ContextDiagramDriver, DbDiagramDriver, SequenceDiagramDriver, UseCasDiagramDriver


app = FastAPI()



app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["POST","GET"],
    allow_headers=["*"],
)

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