FROM python:slim-bookworm

# Install required packages
RUN apt update && apt install -y \
    gcc \
    g++ \
    make \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Create app directory and copy project files
WORKDIR /app
COPY . /app/

# Build the SILK decoder
RUN cd ./silk && make && make decoder

ENTRYPOINT ["python","/app/converter.py"]
