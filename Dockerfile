FROM ubuntu:22.04

# 1) Install system deps (curl, Python, etc.)
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl ca-certificates python3 python3-pip \
 && rm -rf /var/lib/apt/lists/*

# 2) Install Ollama CLI (pick one of the two options below)

# Option A: official installer (recommended)
RUN curl -fsSL https://ollama.com/install.sh | sh

# Option B: direct asset download
# RUN curl -fsSL \
#     https://github.com/ollama/ollama/releases/download/v0.0.26/ollama-linux-amd64.tgz \
#   | tar xz -C /usr/local/bin

# 3) Pull your model so it's baked into the image
RUN ollama pull llama2

# 4) Python deps
WORKDIR /app
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt
COPY . .

# 5) Entrypoint: start Ollama + Uvicorn
RUN printf '#!/bin/sh\n\
ollama serve --listen 0.0.0.0:11434 &\n\
sleep 2\n\
exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}\n' \
 > /app/entrypoint.sh \
 && chmod +x /app/entrypoint.sh

EXPOSE 8000 11434
ENTRYPOINT ["/app/entrypoint.sh"]
