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


@app.post("/summarize/")
async def summarize_meeting(request: Request):
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
            ["ollama", "run", "llama3", "temperature ", "0.7"],
            input=prompt.encode(),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        output = response.stdout.decode()
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
            ["ollama", "run", "llama3", "temperature", "0", "top_p", "1", "top_k", "1", "seed","42"],
            input=prompt.encode(),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True,
        )
        output = response.stdout.decode()
        return JSONResponse(content={
            "sum":output
        })
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)
    
# @app.post("/reqs/")
# async def extract_requirements(request: Request):

#     try:
#         data = await request.json()
#         meeting_text = data.get("text", "")

#         if not meeting_text:
#             return JSONResponse(content={"error": "No meeting text provided"}, status_code=400)
#         prompt = (
#                 # "extract from the following software meeting the functional and non functional requirements. :\n\n" + meeting_text
#                 f""""
#                 You are a senior software requirements analyst.

#                 You will be given a meeting transcription related to a software project. Your task is to extract all the requirements that are discussed either explicitly or implicitly during the meeting.
#                 Functional Requirements describe what the system should do — features, behaviors, actions, APIs, user interactions.

#                 Non-Functional Requirements describe how the system should perform — performance, reliability, scalability, usability, security, maintainability, etc.

#                 You may infer requirements that are implied by the conversation, not just the ones directly stated.

#                 Use clear, concise phrasing.
#                  Output Format:
#                 Functional Requirements:
#                 1) "..."

#                 2 )"..."

#                 Non-Functional Requirements:
#                 1) "..."

#                 2 )"..."

#                 Additional Instructions:

#                 Only output requirements — do not include speaker names or summaries.
#                 Rephrase into requirement-style or interpretations.
#                 If a requirement covers both functional and non-functional aspects, list it in both sections.
                
#                 Meeting Transcript: {meeting_text}
#     """
#             )

#         # response = ollama.chat(model="llama3", messages=[{"role": "user", "content": prompt} ], temperature=0)
#         # return response
#         response = subprocess.run(
#             ["ollama", "run", "llama3", "temperature", "0", "top_p", "1", "top_k", "1", "seed","42"],
#             input=prompt.encode(),
#             stdout=subprocess.PIPE,
#             stderr=subprocess.PIPE,
#             check=True,
#         )
#         output = response.stdout.decode()
#         return JSONResponse(content={
#             "requirements": output,
#         })
#     except Exception as e:
#         return JSONResponse(content={"error": str(e)}, status_code=500)
    






import os
import uvicorn
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 11435))
    uvicorn.run(app, host="0.0.0.0", port=port) 



