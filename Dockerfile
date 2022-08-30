
# Use the official lightweight Python image.
# https://hub.docker.com/_/python
FROM python:3.10-slim

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

# Copy local code to the container image.
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY ./app ./

# Install production dependencies.
RUN pip install --no-cache-dir -r requirements.txt

# Run the web service on container startup. Here we use the gunicorn
# webserver, with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
# Timeout is set to 0 to disable the timeouts of the workers to allow Cloud Run to handle instance scaling.
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app





# # start by pulling the python image
# FROM python:3.8-alpine

# # copy the requirements file into the image
# COPY app/requirements.txt /app/requirements.txt

# # switch working directory
# WORKDIR /app

# # install the dependencies and packages in the requirements file
# RUN pip install -r requirements.txt

# # copy every content from the local file to the image
# COPY app/ /app

# # configure the container to run in an executed manner
# ENTRYPOINT [ "python" ]

# CMD ["app.py" ]