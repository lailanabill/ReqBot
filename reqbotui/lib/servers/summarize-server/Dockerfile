# FROM python:3.9
# # Set working directory
# WORKDIR /app

# # Copy your files
# COPY . /app


# RUN pip install --upgrade pip
# RUN pip install fastapi uvicorn ollama


# # Use Ollama base image
# FROM ollama/ollama:latest

# # Set working directory
# WORKDIR /app

# # # Copy your files
# COPY --from=builder /usr/local/lib/python3.9 /usr/local/lib/python3.9
# COPY --from=builder /usr/local/bin /usr/local/bin
# COPY . /app


# # Pull your LLaMA model
# RUN ollama pull llama3.2:3b

# # Expose port
# EXPOSE 8080

# # Run FastAPI
# CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8080"]



# FROM ollama/ollama:latest

# WORKDIR /app

# # Install Python + dependencies
# RUN apt-get update && apt-get install -y python3 python3-pip

# COPY requirements.txt .
# RUN pip3 install --no-cache-dir -r requirements.txt

# COPY . .

# RUN chmod +x /app/start.sh

# EXPOSE 8080

# CMD ["/app/start.sh"]


FROM ollama/ollama:latest

# Set working directory
WORKDIR /app

# Install Python and pip
RUN apt-get update && apt-get install -y python3 python3-pip

# Install FastAPI and Uvicorn
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy app code
COPY . .

# Make the start script executable
RUN chmod +x /app/start.sh

EXPOSE 8080

# Reset Ollama's ENTRYPOINT so we can run our own startup
ENTRYPOINT []
CMD ["/app/start.sh"]

