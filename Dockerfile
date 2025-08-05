FROM python:3.10-slim

# 1) install deps as root
COPY requirements.txt /tmp/
RUN pip install --upgrade pip \
 && pip install --no-cache-dir -r /tmp/requirements.txt

# 2) Create & switch into your app directory
RUN useradd --create-home appuser
WORKDIR /home/appuser/app
USER appuser

# 3) Copy your application code _into_ that directory
COPY --chown=appuser:appuser . .

# 4) (optional) Clean or re-create chroma DB so it's writable
RUN rm -rf chroma_learning_db

# 5) Expose & start
EXPOSE 8000
CMD ["sh","-c","uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}"]
