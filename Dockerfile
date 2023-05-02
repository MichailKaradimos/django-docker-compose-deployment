# Based on Python 3.9 alpine image which is a lightweight base image for running Python apps.
FROM python:3.9-alpine3.13

# Set PYTHONUNBUFFERED to 1 so that Python outputs are sent straight to the container logs.
ENV PYTHONUNBUFFERED 1

# Copies the requirements.txt file to the image.
COPY ./requirements.txt /requirements.txt
# The same for the app
COPY ./app /app

# COPY ./scripts /scripts

# Sets /app as our working directory when running commands from the Docker image.
WORKDIR /app

EXPOSE 8000

# This command creates a new virtual environment, upgrades pip, installs the required Python packages, 
# and creates a new user for the application to run under.
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    # This installs the PostgreSQL client package and updates the package index.
    apk add --update --no-cache postgresql-client && \
    # 
    apk add --update --no-cache --virtual .tmp-deps \
    # all dependencies needed to install the driver using pip.
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /requirements.txt && \
    # This removes the temporary dependencies installed in step 2. 
    # This is done to reduce the image size by removing unnecessary packages and to improve security by removing packages that are no longer needed.
    apk del .tmp-deps && \
    adduser --disabled-password --no-create-home app && \
    mkdir -p /vol/web/static && \
    mkdir -p /vol/web/media && \
    chown -R app:app /vol && \
    chmod -R 755 /vol
   


# This line sets the PATH environment variable to include the directory /py/bin, which is where the Python virtual environment and its packages are installed
ENV PATH="/py/bin:$PATH"

USER app


# This line specifies the default command to run when the Docker container is started
# CMD ["run.sh"]