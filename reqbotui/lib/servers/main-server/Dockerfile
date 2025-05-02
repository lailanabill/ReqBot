# # Dockerfile
# FROM python:3.9.17-bookworm
# # Allow statements and log messages to immediately appear in the logs
# ENV PYTHONUNBUFFERED True
# # Copy local code to the container image.
# ENV APP_HOME /back-end
# WORKDIR $APP_HOME
# COPY . ./

# RUN pip install --no-cache-dir --upgrade pip
# RUN pip install --no-cache-dir -r requirements.txt

# # Run the web service on container startup. Here we use the gunicorn
# # webserver, with one worker process and 8 threads.
# # For environments with multiple CPU cores, increase the number of workers
# # to be equal to the cores available.
# # Timeout is set to 0 to disable the timeouts of the workers to allow Cloud Run to handle instance scaling.
# # CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app
# # CMD exec python -m uvicorn server:app --host 0.0.0.0 --port 8080 --workers 1 
# CMD python -m uvicorn server:app --host 0.0.0.0 --port 8080 --workers 1


# Use a Python base image
# FROM python:3.11

FROM ollama/ollama:latest

ENV TZ=Africa/Cairo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV PYTHONUNBUFFERED=1
WORKDIR /app
RUN apt update && apt install -y ffmpeg python3 python3-pip 
RUN pip install --upgrade pip setuptools typing-extensions packaging numpy
RUN pip install ollama

# && ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN chmod +x /app/start.sh
EXPOSE 8080

# CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8080"]
ENTRYPOINT []
CMD ["/app/start.sh"]