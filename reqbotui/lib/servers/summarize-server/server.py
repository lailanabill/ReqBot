


# https://ollama-sum-st-1016128810332.us-central1.run.app/summarize/ link to server 


from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import subprocess

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


app = FastAPI()


@app.post("/summarize/")
async def summarize_meeting(request: Request):
    try:
        data = await request.json()
        meeting_text = data.get("text", "")

        if not meeting_text:
            return JSONResponse(content={"error": "No meeting text provided"}, status_code=400)

        prompt = (
            "summarize the following software meeting :\n\n" + meeting_text
        )

        response = subprocess.run(
            ["ollama", "run", "llama3"],
            input=prompt.encode(),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )

        output = response.stdout.decode()

        return JSONResponse(content={"summary": output})

    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)



import os
import uvicorn
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port) 



