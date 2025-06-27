FROM nvidia/cuda:12.8.1-runtime-ubuntu22.04

ARG RUNTIME=nvidia

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
ENV UVICORN_PORT=8118
# Set the Hugging Face home directory for better model caching
ENV HF_HOME=/app/hf_cache

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libsndfile1 \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a symlink for python3 to be python for convenience
RUN ln -s /usr/bin/python3 /usr/bin/python

# Set up working directory
WORKDIR /app

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Upgrade pip and install Python dependencies
RUN pip3 install pytorch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 pytorch-cuda=12.1 --extra-index-url https://download.pytorch.org/whl/cu121 && \
    pip3 install flash-attn==2.6.1 \
    pip3 install -r requirements.txt

RUN if [ "$RUNTIME" = "nvidia" ]; then \
    # pip3 install --no-cache-dir -r requirements-nvidia.txt; \
    fi
# Copy the rest of the application code
COPY . .


# Expose the port the application will run on
EXPOSE 8118

# Command to run the application
CMD ["python3", "app_chat.py"]