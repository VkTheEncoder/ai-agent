# Dockerfile
FROM python:3.10-slim

# set a non-root user (optional but recommended)
RUN useradd --create-home appuser
WORKDIR /home/appuser/app
USER appuser

# copy and install python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# copy app code
COPY . .

# expose the port FastAPI will run on
EXPOSE 8000

# start the app with uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
