# Use Runpod PyTorch base image
FROM runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Set the working directory
WORKDIR /app

# Install system dependencies if needed
RUN apt-get update --yes && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file
COPY requirements.txt /app/

# Install Python dependencies with pip
# For uv alternative, see Dockerfile.uv
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Pre-download and cache the model in the image
# Using DistilBERT for sentiment classification - small and efficient
ENV HF_HOME=/app/models
ENV HF_HUB_ENABLE_HF_TRANSFER=0

# OPTION A: Download via transformers pipeline (automatic)
RUN python -c "from transformers import pipeline; pipeline('sentiment-analysis', model='distilbert-base-uncased-finetuned-sst-2-english')"

# OPTION B: Download via wget (alternative - useful for custom/hosted models)
# To use wget instead, uncomment below and disable OPTION A above
# All files needed: config.json, model.safetensors, tokenizer_config.json, vocab.txt
# RUN mkdir -p /app/models/distilbert-model && \
#     cd /app/models/distilbert-model && \
#     wget -q https://huggingface.co/distilbert-base-uncased-finetuned-sst-2-english/resolve/main/config.json && \
#     wget -q https://huggingface.co/distilbert-base-uncased-finetuned-sst-2-english/resolve/main/model.safetensors && \
#     wget -q https://huggingface.co/distilbert-base-uncased-finetuned-sst-2-english/resolve/main/tokenizer_config.json && \
#     wget -q https://huggingface.co/distilbert-base-uncased-finetuned-sst-2-english/resolve/main/vocab.txt

# Copy application files
COPY . /app

# ============================================================================
# OPTION 1: Keep everything from base image (Jupyter, SSH, entrypoint) - DEFAULT
# ============================================================================
# The base image already provides everything:
# - Entrypoint: /opt/nvidia/nvidia_entrypoint.sh (handles CUDA setup)
# - Default CMD: /start.sh (starts Jupyter/SSH automatically based on template settings)
# - Jupyter Notebook (starts if startJupyter=true in template)
# - SSH access (starts if startSsh=true in template)
#
# Just don't override CMD - the base image handles everything!
# CMD is not set, so base image default (/start.sh) is used

# ============================================================================
# OPTION 2: Override CMD but keep entrypoint and services
# ============================================================================
# If you want to run your own command but still have Jupyter/SSH start:
# - Keep the entrypoint (CUDA setup still happens automatically)
# - Use the provided run.sh script which starts /start.sh in background,
#   then runs your application commands
#
# Edit run.sh to customize what runs after services start, then uncomment:
# COPY run.sh /app/run.sh
# RUN chmod +x /app/run.sh
# CMD ["/app/run.sh"]
#
# The run.sh script:
# 1. Starts /start.sh in background (starts Jupyter/SSH)
# 2. Waits for services to initialize
# 3. Runs your application commands
# 4. Waits for background processes

# ============================================================================
# OPTION 3: Override everything - no Jupyter, no SSH, just your app
# ============================================================================
# If you don't want any base image services, override both entrypoint and CMD:
#
# ENTRYPOINT []  # Clear entrypoint
# CMD ["python", "/app/main.py"]

