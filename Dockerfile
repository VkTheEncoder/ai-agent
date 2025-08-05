# 1. Base image
FROM python:3.10-slim

# 2. Install Python deps as root
WORKDIR /app
COPY requirements.txt .
RUN pip install --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt

# 3. Copy your code (still as root)
COPY . .

# 4. Remove the checked-in, read-only Chroma DB so it can be re-created at runtime
RUN rm -rf chroma_learning_db

# 5. Now create a non-root user, fix ownership, and switch
RUN useradd --create-home appuser \
 && chown -R appuser:appuser /app
USER appuser
WORKDIR /app

# 6. Expose port (Render will override via $PORT)
EXPOSE 8000

# 7. Start Uvicorn binding to Render’s $PORT
CMD ["sh","-c","uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}"]
