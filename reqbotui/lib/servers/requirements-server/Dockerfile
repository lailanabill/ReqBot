FROM ollama/ollama:latest

ENV TZ=Africa/Cairo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV PYTHONUNBUFFERED=1
WORKDIR /app
RUN apt update && apt install -y ffmpeg python3 python3-pip 
RUN pip install --upgrade pip setuptools typing-extensions packaging numpy
RUN pip install ollama

COPY requirements.txt .

RUN pip install --upgrade pip setuptools typing-extensions packaging numpy
RUN pip install --upgrade keras keras-preprocessing torch spacy
RUN pip install ollama
RUN pip install --upgrade pip setuptools
RUN pip install numpy==1.24.4
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


COPY . .
RUN chmod +x /app/start.sh
EXPOSE 8080

ENTRYPOINT []
CMD ["/app/start.sh"]