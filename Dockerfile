# base image to build
FROM python:3.7 as build-env

WORKDIR /app
COPY app/requirements.txt /app/requirements.txt
RUN pip install -r /requirements.txt 

FROM gcr.io/distroless/python3

ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_ENV=development

COPY --from=build-env /usr/local/lib/python3.7/site-packages /usr/local/lib/python3.7/site-packages
COPY --from=build-env /usr/local/bin/gunicorn /home/worker/gunicorn

COPY app/ /home/worker
COPY app/templates /home/worker/app

WORKDIR /app
# This default value facilitates local development.
ENV PORT 8080
ENV GUNICORN_CMD_ARGS="--workers 2 --threads 2 -b 0.0.0.0:8080 --chdir /home/worker"
CMD ["gunicorn",  "app:app"]


# # Distroless Dockerfile for running in production
# FROM python:alpine3.7 AS build-env

# COPY app/requirements.txt requirements.txt
# RUN pip install --no-cache-dir -r requirements.txt

# FROM gcr.io/distroless/python3
# COPY --from=build-env /usr/local/lib/python3.7/site-packages /usr/local/lib/python3.7/site-packages
# COPY --from=build-env /usr/local/bin/gunicorn /home/worker/gunicorn
# ENV PATH="/home/worker:${PATH}"
# COPY app/ /home/worker
# COPY app/templates /home/worker/app

# WORKDIR /home/worker
# ENV PYTHONPATH=/usr/local/lib/python3.7/site-packages
# # Service must listen to $PORT environment variable.
# # This default value facilitates local development.
# ENV PORT 8080
# ENV GUNICORN_CMD_ARGS="--workers 2 --threads 2 -b 0.0.0.0:8080 --chdir /home/worker"
# # Run the web service on container startup.
# #CMD exec gunicorn app:app --workers 2 --threads 2 -b 0.0.0.0:8080 --reload
# CMD ["gunicorn",  "app:app"]

# to build and run this Dockerfile:
# docker build -t covidweb . && docker run --rm -p 8080:8080 -e PORT=8080 covidweb









# FROM python:3.7-slim

# RUN pip install Flask==1.0
# COPY *.py .

# ENV FLASK_DEBUG=1
# ENV FLASK_APP=app.py
# CMD ["python", "-m", "flask", "run"]


# FROM python:3.7-slim

# RUN mkdir /app
# WORKDIR /app
# ADD . /app/
# RUN pip install -r requirements.txt

# ENV FLASK_DEBUG=1
# ENV FLASK_APP=app.py

# EXPOSE 8080
# CMD ["python", "-m", "flask", "run"]

# EXPOSE 8080
# CMD ["python", "/app/app.py"]



# FROM python:3.7.3-stretch
# # this is required for hot reload
# ENV FLASK_DEBUG=1
# ENV FLASK_APP hello.py

# COPY app/main.py /app/hello.py
# COPY requirements.txt .
# RUN pip install -r app/requirements.txt
# WORKDIR /app

# ENTRYPOINT ["flask"]
# CMD ["run", "--host=0.0.0.0"]