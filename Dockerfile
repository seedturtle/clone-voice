# Zeabur CPU-optimized Dockerfile for clone-voice
# 使用 CPU-only 版本，適合 Zeabur 無 GPU 環境
FROM python:3.10-slim

WORKDIR /app

# Install system dependencies (OpenGL, audio, git, etc.)
RUN apt-get update && apt-get install -y \
    build-essential \
    libgl1-mesa-glx \
    libsm6 \
    libxext6 \
    libglib2.0-0 \
    libxrender-dev \
    git \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Pre-install CPU-only PyTorch (prevents TTS from pulling CUDA version)
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir torch==2.3.1 --index-url https://download.pytorch.org/whl/cpu

# Install Python dependencies
COPY requirements.txt /app/requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . /app

# Override to CPU mode and auto-detect Zeabur port
ENV ENABLE_STS=1
ENV DEVICE=CPU
ENV PYTHONUNBUFFERED=1

EXPOSE 9988

VOLUME /app/tts
VOLUME /app/tts_cache

# Auto-detect Zeabur's $PORT or fallback to 9988
CMD ["sh", "-c", "WEB_ADDRESS=0.0.0.0:${PORT:-9988} python app.py"]
