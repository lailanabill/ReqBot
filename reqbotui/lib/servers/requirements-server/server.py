import string
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

import pandas as pd
from dotenv import load_dotenv
import numpy as np
from markdownify import markdownify as md
from transformers import BertTokenizer, BertModel
import spacy
import tensorflow as tf
import os
import tensorflow as tf
import keras
import torch
# from keras.utils import pad_sequences
# from tensorflow.keras.preprocessing.sequence import pad_sequences
from keras_preprocessing.sequence import pad_sequences
#
# from tensorflow.keras.preprocessing.sequence import pad_sequences


from keras_preprocessing.text import tokenizer_from_json
# from tensorflow.keras.models import load_model
import re
import joblib
from collections import Counter
import subprocess
from typing import Optional, List, Dict, Any


load_dotenv()

app = FastAPI()
hf_token = os.getenv("HF_TOKEN")


tokenizer = BertTokenizer.from_pretrained("bert-base-uncased",token=hf_token)
model = BertModel.from_pretrained("bert-base-uncased",token=hf_token)

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

nlp = spacy.load("en_core_web_sm")

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



BASE_DIR = os.path.dirname(os.path.abspath(__file__))
tokenizer_path = os.path.join(BASE_DIR, "AImodels", "tokenizer.json")
with open(tokenizer_path, "r") as f:
    tokenizer_dl = tokenizer_from_json(f.read())


base_dir = os.path.dirname(__file__) 
rf_model = joblib.load(os.path.join(base_dir, 'AImodels', 'RandomForest.pkl'))
lstm_model = keras.models.load_model(os.path.join(base_dir, 'AImodels', 'ref_lstm.h5'))
seq_model = keras.models.load_model(os.path.join(base_dir, 'AImodels', 'seq.h5'))
gru_model = keras.models.load_model(os.path.join(base_dir, 'AImodels', 'gru.h5'))
bi_lstm_model = keras.models.load_model(os.path.join(base_dir, 'AImodels', 'bi_lstm.h5'))

lstm_model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
seq_model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
gru_model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
bi_lstm_model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])



app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["POST","GET"],
    allow_headers=["*"],
)



@app.post("/reqsneww/")
async def extract_requirements(request: Request):
    try:
        data = await request.json()
        meeting_sum = data.get("summ", "")
        meeting_text = data.get("orig", "")
        markdown_text = meeting_sum
        plain_text = md(markdown_text)
        plain_summ = split_into_sentences(remove_bullet_sentences(remove_prefix_before_colon(clean_markdown_to_sentences(plain_text))))
        if not meeting_text:
            return JSONResponse(content={"error": "No meeting text provided"}, status_code=400)
        prompt = (
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
        padded_seq =  pad_sequences(seq, padding='post', truncating='post', maxlen=25)
        dataset_copy['DL_Requirement'] = padded_seq.tolist()
        temp = []
        for i in range(len(dataset_copy['Requirement'])):
            ml_requirement_reshaped = dataset_copy['ML_Requirement'][i].reshape(1, -1)
            input_data = np.array(dataset_copy['DL_Requirement'][i]).reshape(1, -1)
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
        return JSONResponse(content={
            "reqs":requirements
        })
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)



import os
import uvicorn
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port) 