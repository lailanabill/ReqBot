import string
from fastapi import FastAPI, UploadFile, File, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import replicate
import pandas as pd
# import whisper
# from transformers import pipeline
from dotenv import load_dotenv
import numpy as np
import strip_markdown
from transformers import BertTokenizer, BertModel

from tensorflow.keras.preprocessing.sequence import pad_sequences

import re

import joblib
from tensorflow.keras.models import load_model
from collections import Counter

def clean_markdown_to_sentences(text):
    lines = text.splitlines()
    cleaned = []
    current_context = ""

    for line in lines:
        line = line.strip()
        if not line:
            continue

        # Remove markdown symbols
        line = re.sub(r"^(\*{1,2}|\+|-)", "", line).strip()
        line = re.sub(r"\*\*(.*?)\*\*", r"\1", line)  # remove bold

        # Capture section headers as context
        if not line.endswith(".") and not line.endswith(":") and line.lower() == line.title():
            current_context = line
            continue

        # Add colon to context-based lines if not present
        if line.endswith(":"):
            current_context = line[:-1]
            continue

        # If line starts with a capital letter and no context, treat as its own sentence
        if not current_context:
            cleaned.append(f"{line.strip('.')}.")
        else:
            # Use context to prefix the statement
            sentence = f"{current_context.strip()}: {line.strip('.')}"
            cleaned.append(sentence + ".")

    return "\n".join(cleaned)

    

def remove_prefix_before_colon(text):
    cleaned_lines = []
    for line in text.strip().splitlines():
        if ':' in line:
            cleaned_lines.append(line.split(':', 1)[1].strip())
        else:
            cleaned_lines.append(line.strip())
    return '\n'.join(cleaned_lines)


def remove_bullet_sentences(text):
    # Split the text by sentence-ending period (.) while keeping the period
    sentences = re.split(r'(?<=\.)\s+', text.strip())
    
    # Keep only sentences that don't start with the bullet symbol
    cleaned = [s for s in sentences if not s.strip().startswith('•')]
    
    return ' '.join(cleaned)


def split_into_sentences(text):
    # Split the text by period
    sentences = text.split('.')
    # Remove empty strings and strip whitespace
    return [sentence.strip() + '.' for sentence in sentences if sentence.strip()]

def extract_clean_requirements(text: str):
    # Match lines that start with F<number>) or NF<number>)
    pattern = r"^(F\d+|NF\d+)\)\s+(.*)$"

    result = []
    for line in text.splitlines():
        match = re.match(pattern, line.strip())
        if match:
            # Append only the requirement description (group 2)
            result.append(match.group(2))
    return result

def clean_df(df):
  #lower casing requirements
  df = df.map(lambda x: x.lower() if isinstance(x, str) else x)
  #removing special characters
  df = df.replace(to_replace=r'[^\w\s]', value='', regex=True)
  #removing digits
  df = df.replace(to_replace=r'\d', value='', regex=True)
  #removing punctuation
  string.punctuation
  xx= []
  for i in range(len(df['Requirement'])):
    temp =df['Requirement'][i]
    re_punc = re.compile('[%s]' % re.escape(string.punctuation))
    stripped = [re_punc.sub('', w) for w in temp.split()]
    stripped = ' '.join(stripped)
    xx.append(stripped)
  return df

def remove_non_english_characters(df,label):
  x=[]
  for i in range(len(df[label])):
    temp = df[label][i]
    non_english_chars = re.sub(r'[^a-zA-Z\s]', '', temp)
    x.append(non_english_chars)
  return x

import spacy
nlp = spacy.load("en_core_web_sm")
# doc = nlp(dataset_copy['Requirement'])

def context_stw_rmv(df,col):
  temp=[]


  stopwords = set(spacy.lang.en.stop_words.STOP_WORDS) - {"must", "mustn't", "must not", "should", "shouldn't", "should not","shall", "shalln't", "shall not", "can", "can't", "cannot", "never", "not","every", "each", "all", "any", "be" }

  for i in range(len(df[col])):
        doc = nlp(df[col][i])  # Ensure it's a string
        filtered_words = [
            token.text for token in doc
            if token.text.lower() not in stopwords or token.pos_ in {"NOUN", "VERB", "AUX", "MODAL"}
        ]
        temp.append(" ".join(filtered_words))
  return temp

def ml_token(df):
  x=[]
  for i in range(len(df['Requirement'])):
    tokens = tokenizer(df['Requirement'][i], return_tensors="pt")
    # tokens = {k: v.to('cuda') for k, v in tokens.items()}
    with torch.no_grad():
      embeddings = model(**tokens).last_hidden_state
    sentence_vector = torch.mean(embeddings, dim=1).cpu().numpy()
    x.append(sentence_vector)
  return x

def get_bert_embedding(df ):
  temp=[]
  for i in range(len(df['Requirement'])):
    sentence = df['Requirement'][i]
    tokens = tokenizer(sentence, return_tensors="pt", padding=True, truncation=True, max_length=128)
    # tokens = {k: v.to('cuda') for k, v in tokens.items()}
    with torch.no_grad():
        embeddings = model(**tokens).last_hidden_state
    sentence_vector = torch.mean(embeddings, dim=1).cpu().numpy()  # Convert to 1x768
    temp.append(sentence_vector.flatten())  # Convert shape (1, 768) → (768,)
  return temp


import pickle

with open("tokenizer.pkl", "rb") as f:
          tokenizer_dl = pickle.load(f)




base_dir = os.path.dirname(__file__) 


rf_model = joblib.load(os.path.join(base_dir, 'PredictionModels', 'RandomForest.pkl'))
lstm_model = load_model(os.path.join(base_dir, 'PredictionModels', 'ref_lstm.h5'))
seq_model = load_model(os.path.join(base_dir, 'PredictionModels', 'seq.h5'))
gru_model = load_model(os.path.join(base_dir, 'PredictionModels', 'gru.h5'))
bi_lstm_model = load_model(os.path.join(base_dir, 'PredictionModels', 'bi_lstm.h5'))


lstm_model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
seq_model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
gru_model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
bi_lstm_model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])



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

tokenizer = BertTokenizer.from_pretrained("bert-base-uncased",token=hf_token)
model = BertModel.from_pretrained("bert-base-uncased",token=hf_token)





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
    
@app.post("/reqsneww/")
async def extract_requirements(request: Request):

    try:
        data = await request.json()
        meeting_sum = data.get("summ", "")
        meeting_text = data.get("orig", "")
        markdown_text = meeting_sum
        plain_text = strip_markdown.strip_markdown(markdown_text)
        plain_summ = split_into_sentences(remove_bullet_sentences(remove_prefix_before_colon(clean_markdown_to_sentences(plain_text))))

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

                Return the output in plain text not markdown.
                
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
        llama_out = split_into_sentences(extract_clean_requirements(output))

        reqs = llama_out+plain_summ

        look_up = pd.DataFrame(reqs,columns=['Requirement'])
        dataset_copy = clean_df(look_up)
        dataset_copy['Requirement'] = remove_non_english_characters(dataset_copy,'Requirement')
        dataset_copy['Requirement'] = context_stw_rmv(dataset_copy,'Requirement')
        dataset_copy['ML_Requirement'] = ml_token(dataset_copy)
        dataset_copy['ML_Requirement'] = get_bert_embedding(dataset_copy)
        seq = tokenizer_dl.texts_to_sequences(dataset_copy['Requirement'])
        padded_seq =  pad_sequences(seq, padding='post', truncating='post', maxlen=99)
        dataset_copy['DL_Requirement'] = padded_seq.tolist()

        temp = []
        for i in range(len(dataset_copy['Requirement'])):
        # res_rf = (rf_model.predict(dataset_copy['ML_Requirement'][i])>0.5).astype('int32')
            ml_requirement_reshaped = dataset_copy['ML_Requirement'][i].reshape(1, -1)
            input_data = np.array(dataset_copy['DL_Requirement'][i]).reshape(1, -1)
            # ml_requirement_reshaped = dataset_copy['ML_Requirement'][i].reshape(1, -1)
            res_rf = (rf_model.predict(ml_requirement_reshaped)>0.5).astype('int32')[0]
            res_lstm = (lstm_model.predict(input_data)>0.5).astype('int32')[0][0]
            res_seq = (seq_model.predict(input_data)>0.5).astype('int32')[0][0]
            res_gru = (gru_model.predict(input_data)>0.5).astype('int32')[0][0]
            res_bi_lstm = (bi_lstm_model.predict(input_data)>0.5).astype('int32')[0][0]
            temp.append([res_rf,res_lstm,res_seq,res_gru,res_bi_lstm])


        final_result = []
        for i in range(len(temp)):
            v,c = Counter(temp[i]).most_common()[0]
            final_result.append(v)

        dataset_copy['Type_numirecal']=final_result
        dataset_copy['Type']=0
        for i in range(len(dataset_copy)):
            if dataset_copy['Type_numirecal'][i] == 0:
                dataset_copy['Type'][i]='Functioinal'
            else :
                dataset_copy['Type'][i]='Non Functioinal'
        requirements : List[Dict[str, Any]] = []
        for i in range(len(dataset_copy['Requirement'])):
            requirements.append({
                "Requirement": dataset_copy['Requirement'][i],
                "Type": dataset_copy['Type'][i],
            })

        clean_gpu_memory()
        return JSONResponse(content={
            "reqs":requirements
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