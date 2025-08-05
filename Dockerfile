FROM ubuntu:22.04

# 1) Install system deps (curl, Python, etc.)
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl ca-certificates python3 python3-pip \
 && rm -rf /var/lib/apt/lists/*

# 2) Install Ollama CLI
RUN curl -fsSL https://ollama.com/install.sh | sh

# 3) Python deps
WORKDIR /app
COPY requirements.txt .
RUN pip3 install --upgrade pip \
 && pip3 install --no-cache-dir -r requirements.txt

# 4) Copy your code
COPY . .

# 5) Create an entrypoint that:
#    a) starts ollama serve
#    b) waits for it
#    c) pulls llama2 (idempotent if already cached)
#    d) then execs uvicorn
RUN printf '#!/bin/sh\n\
set -e\n\
echo "Starting Ollama…"\n\
ollama serve --listen 0.0.0.0:11434 &\n\
# wait for Ollama to be ready\n\
sleep 5\n\
echo "Pulling llama2 model (no-op if cached)…"\n\
ollama pull llama2 || true\n\
echo "Starting FastAPI…"\n\
exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}\n' \
 > /app/entrypoint.sh \
 && chmod +x /app/entrypoint.sh

# 6) Expose both ports
EXPOSE 8000 11434

# 7) Run the combined entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
