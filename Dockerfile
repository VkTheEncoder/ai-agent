FROM python:3.10-slim


# copy & install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt

# now that everything is bootstrapped, create and switch to a non-root user
RUN useradd --create-home appuser
WORKDIR /home/appuser/app
USER appuser

# copy your app code
COPY . .

# expose port (Render will override via $PORT)
EXPOSE 8000

RUN chmod -R a+rwX ./chroma_learning_db
# start uvicorn, binding to Render's port
CMD ["sh","-c","uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}"]
