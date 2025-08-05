# Dockerfile
FROM ubuntu:22.04

##### 1. Install system deps & Ollama CLI #####
RUN apt-get update \
 && apt-get install -y curl ca-certificates python3 python3-pip \
 && rm -rf /var/lib/apt/lists/*

# Download & install Ollama (adjust version as needed)
RUN curl -sSL \
    https://github.com/ollama/ollama/releases/download/v0.0.26/ollama_0.0.26_linux_amd64.tar.gz \
  | tar xz -C /usr/local/bin

# Pull the model you want (e.g. "llama2")
RUN ollama pull llama2

##### 2. Install your Python app #####
WORKDIR /app
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

##### 3. Entrypoint: start Ollama & Uvicorn #####
# Create a tiny startup script
RUN printf '#!/bin/sh\n\
set -e\n\
# 1) launch Ollama server in background\n\
ollama serve --listen 0.0.0.0:11434 &\n\
# 2) wait a moment for it to spin up\n\
sleep 2\n\
# 3) launch your FastAPI app\n\
exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}\n' \
> /app/entrypoint.sh \
 && chmod +x /app/entrypoint.sh

EXPOSE 8000 11434

ENTRYPOINT ["/app/entrypoint.sh"]
