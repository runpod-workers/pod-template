# Project Context

## Overview

This is a Runpod template repository that demonstrates how to create containerized applications for Runpod's GPU cloud platform. The template extends Runpod's PyTorch base image and provides a clean starting point for building custom GPU-accelerated applications.

## Technology Stack

- **Base Image**: `runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404`
  - PyTorch 2.8.0
  - CUDA 12.8.1
  - Ubuntu 24.04
- **Language**: Python 3.10+
- **Containerization**: Docker
- **Package Management**: 
  - pip (default, via `Dockerfile`)
  - uv (alternative, via `Dockerfile.uv`)

## Project Structure

```
pod-template/
├── Dockerfile              # Default Dockerfile using pip
├── Dockerfile.uv          # Alternative Dockerfile using uv
├── main.py                # Application entry point
├── requirements.txt       # Python dependencies (pip)
├── pyproject.toml         # Project metadata (uv support)
├── .dockerignore          # Files excluded from Docker build
└── docs/                  # Documentation
    └── context.md         # This file
```

## Architecture

### High-Level Flow

1. **Base Image**: Extends Runpod's PyTorch base image with pre-installed CUDA and PyTorch
2. **Dependencies**: Installs Python packages from `requirements.txt`
3. **Application**: Copies application code into container
4. **Execution**: Runs `main.py` as the default command

### Docker Build Options

**Option 1: pip (default)**
- Uses `Dockerfile`
- Installs packages via `pip install -r requirements.txt`
- Standard Python package management

**Option 2: uv (alternative)**
- Uses `Dockerfile.uv`
- Installs packages via `uv pip install -r requirements.txt`
- Faster package resolution and installation

### Application Entry Point

The `main.py` file serves as the application entry point. It:
- Verifies Python and PyTorch versions
- Checks CUDA availability
- Provides a template for custom application logic

### Entrypoint and Service Management Options

The Dockerfiles demonstrate three approaches for handling the base image's entrypoint and services:

**Option 1: Keep everything from base image (DEFAULT)**
- Preserves all base image functionality (Jupyter, SSH, CUDA setup)
- Uses base image's entrypoint (`/opt/nvidia/nvidia_entrypoint.sh`)
- Uses `/start.sh` script which automatically starts Jupyter/SSH based on template settings
- Application runs after services start via `CMD ["/start.sh", "/app/run_app.sh"]`
- **Recommended**: Best for development and interactive use

**Option 2: Override entrypoint but keep services**
- Clears the entrypoint but manually calls `/start.sh` to start services
- Useful when you need custom entrypoint logic but still want Jupyter/SSH
- Services run in background, then application runs
- See commented code in Dockerfiles for implementation

**Option 3: Override everything**
- Clears both entrypoint and uses custom CMD
- No Jupyter, no SSH - just your application
- Minimal overhead, best for production serverless workloads
- See commented code in Dockerfiles for implementation

## Key Files

- **Dockerfile**: Primary container definition using pip
- **Dockerfile.uv**: Alternative container definition using uv for faster builds
- **requirements.txt**: Python package dependencies (used by both Dockerfiles)
- **main.py**: Application entry point executed when container runs
- **pyproject.toml**: Project metadata and dependency specification (for uv)
- **.dockerignore**: Excludes documentation, git files, and build artifacts from Docker context

## Development Workflow

1. **Add Dependencies**: Update `requirements.txt` with Python packages
2. **Write Application Code**: Modify `main.py` or add additional Python modules
3. **Build Container**: 
   - `docker build -t my-template .` (pip)
   - `docker build -f Dockerfile.uv -t my-template .` (uv)
4. **Test Locally**: `docker run --rm my-template`
5. **Deploy**: Push to container registry for Runpod use

## Important Notes for Contributors

- The base image includes PyTorch and CUDA - no need to install these separately
- Both Dockerfiles install the same dependencies from `requirements.txt`
- The `.dockerignore` excludes `docs/` and `*.md` files from Docker builds
- System dependencies can be added in the `apt-get install` section of Dockerfiles
- **Default behavior (Option 1)**: Uses `/start.sh` which starts Jupyter/SSH automatically when enabled in template
- To change entrypoint behavior, see the three options documented in the Dockerfiles
- `PYTHONUNBUFFERED=1` ensures Python output is immediately visible in logs
- The base image entrypoint (`/opt/nvidia/nvidia_entrypoint.sh`) handles CUDA initialization

## Pre-Baked Model

This template includes a pre-downloaded DistilBERT sentiment classification model baked into the Docker image:

- **Model**: `distilbert-base-uncased-finetuned-sst-2-english`
- **Task**: Sentiment analysis (POSITIVE/NEGATIVE classification)
- **Size**: ~268MB (small and efficient)
- **Input**: Plain text strings
- **Location**: Cached in `/app/models/` within the image
- **Usage**: Load with `pipeline('sentiment-analysis', model=...)` in Python

The model runs on GPU if available (via CUDA) or falls back to CPU. See `main.py` for example inference code.

### Model Download Methods

**Option A: Automatic (Transformers Pipeline)**
- Downloads via `transformers` library during build
- Model cached automatically in `HF_HOME` directory
- Requires network access during build
- See commented "OPTION A" in Dockerfile

**Option B: Manual (wget)**
- Download specific model files directly via `wget`
- Useful for custom/hosted models or when you need explicit control
- Set `HF_HOME` to point to downloaded directory
- See commented "OPTION B" in Dockerfile with example wget commands
- To use: Uncomment the RUN commands in Dockerfile and update `main.py` to load from local path

## Customization Points

- **Base Image**: Change `FROM` line to use other Runpod base images
- **System Packages**: Add to `apt-get install` section
- **Python Dependencies**: Update `requirements.txt`
- **Application Code**: Replace or extend `main.py`
- **Entry Point**: Modify `CMD` in Dockerfile
- **Model Selection**: Replace model ID in Dockerfile and main.py to use different Hugging Face models

