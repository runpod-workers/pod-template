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

# ============================================================================
# USE CASE 1: BAKE MODEL INTO IMAGE
# ============================================================================
# Pre-download and cache the model in the image
# Using DistilBERT for sentiment classification - small and efficient
ENV HF_HOME=/app/models
ENV HF_HUB_ENABLE_HF_TRANSFER=0

# MODEL BAKING OPTION 1: Automatic via transformers (DEFAULT)
# Pros: Simple, clean, automatic caching
# Cons: Requires network during build
RUN python -c "from transformers import pipeline; pipeline('sentiment-analysis', model='distilbert-base-uncased-finetuned-sst-2-english')"

# MODEL BAKING OPTION 2: Manual via wget (Alternative)
# Pros: Explicit control, works with custom/hosted models, offline-friendly
# Cons: Need to manually list all model files
# To use: Uncomment below and disable MODEL BAKING OPTION 1 above
# Required files: config.json, model.safetensors, tokenizer_config.json, vocab.txt
# RUN mkdir -p /app/models/distilbert-model && \
#     cd /app/models/distilbert-model && \
#     wget -q https://huggingface.co/distilbert-base-uncased-finetuned-sst-2-english/resolve/main/config.json && \
#     wget -q https://huggingface.co/distilbert-base-uncased-finetuned-sst-2-english/resolve/main/model.safetensors && \
#     wget -q https://huggingface.co/distilbert-base-uncased-finetuned-sst-2-english/resolve/main/tokenizer_config.json && \
#     wget -q https://huggingface.co/distilbert-base-uncased-finetuned-sst-2-english/resolve/main/vocab.txt

# Copy application files
COPY . /app

# ============================================================================
# USE CASE 2: SERVICE STARTUP & ENTRYPOINT
# ============================================================================
# Choose how the container starts and what services run

# STARTUP OPTION 1: Keep everything from base image (DEFAULT - Jupyter + SSH)
# Use this for: Interactive development, remote access, Jupyter notebook
# Behavior:
#   - Entrypoint: /opt/nvidia/nvidia_entrypoint.sh (CUDA setup)
#   - CMD: /start.sh (starts Jupyter/SSH based on template settings)
# Just don't override CMD - the base image handles everything!
# CMD is not set, so base image default (/start.sh) is used

# STARTUP OPTION 2: Run app after services (Jupyter + SSH + Custom app)
# Use this for: Keep services running + run your application in parallel
# Behavior:
#   - Entrypoint: /opt/nvidia/nvidia_entrypoint.sh (CUDA setup)
#   - CMD: Runs run.sh which starts /start.sh in background, then your app
# To use: Uncomment below
# COPY run.sh /app/run.sh
# RUN chmod +x /app/run.sh
# CMD ["/app/run.sh"]

# STARTUP OPTION 3: Application only (No Jupyter, no SSH)
# Use this for: Production serverless, minimal overhead, just your app
# Behavior:
#   - No Jupyter, no SSH, minimal services
#   - Direct app execution
# To use: Uncomment below
# ENTRYPOINT []
# CMD ["python", "/app/main.py"]

