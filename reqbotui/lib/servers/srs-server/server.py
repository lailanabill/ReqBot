
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

import numpy as np
import subprocess


app = FastAPI()



app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["POST","GET"],
    allow_headers=["*"],
)






@app.post("/srs/")
async def generate_srs(request: Request):
    data = await request.json()
    transcript = data.get("transcript", "")
    summary = data.get("summary", "")
    requirements = data.get("requirements", "")
    pid = data.get("pid", 0)
    

    prompt = f"""
You are a software requirements expert. Given the following:
Transcript: {transcript}
Summary: {summary}
Requirements: {requirements}

Write the following SRS sections in clear, professional language:
- Purpose
- Scope
- Background
- Conclusion

Return as JSON with keys: purpose, scope, background, conclusion.
"""

    
    try:
        response = subprocess.run(
            ["ollama", "run", "llama3"],
            input=prompt.encode(),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True,
        )
        output = response.stdout.decode()
        import json, re
        match = re.search(r"\{.*\}", output, re.DOTALL)
        if match:
            srs_sections = json.loads(match.group(0))
        else:
            
            srs_sections = {
                "purpose": output,
                "scope": "",
                "background": "",
                "conclusion": ""
            }
        return JSONResponse(content=srs_sections)
    except Exception as e:
        return JSONResponse(content={
            "purpose": "",
            "scope": "",
            "background": "",
            "conclusion": "",
            "error": str(e)
        }, status_code=500)



import os
import uvicorn
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port) 