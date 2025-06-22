#!/bin/sh

# Start Ollama server
ollama serve &

# Wait for it to become ready
sleep 10


ollama pull llama3.2:3b


# Start FastAPI server
uvicorn server:app --host 0.0.0.0 --port 8080
