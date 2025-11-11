# Runpod Template Example

This is a clean template repository demonstrating how to create a Runpod template by extending a base image.

## Structure

- `Dockerfile` - Extends the Runpod PyTorch base image using pip (default)
- `Dockerfile.uv` - Alternative Dockerfile using uv for faster package installation
- `requirements.txt` - Python package dependencies (for pip)
- `main.py` - Example application entry point
- `.dockerignore` - Files to exclude from Docker build context

## Base Image

This template extends `runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404` which includes:
- PyTorch 2.8.0
- CUDA 12.8.1
- Ubuntu 24.04

## Installation Methods

This template supports two package installation methods:

### Option 1: Using pip (default)

The `Dockerfile` uses `pip` by default. Add your dependencies to `requirements.txt` and build:

```bash
docker build -t my-template .
```

### Option 2: Using uv

To use `uv` for faster package installation, use `Dockerfile.uv`:

```bash
docker build -f Dockerfile.uv -t my-template .
```

Make sure your dependencies are listed in `requirements.txt` (uv can read requirements.txt files).

## Usage

1. Customize `requirements.txt` with your Python dependencies
2. Add your application code
3. Build the Docker image:
   ```bash
   # Using pip (default)
   docker build -t my-template .
   
   # Or using uv
   docker build -f Dockerfile.uv -t my-template .
   ```
4. Test locally:
   ```bash
   docker run --rm my-template
   ```
5. Push to a container registry for use with Runpod

## Customization

- Modify the `FROM` line in the Dockerfile to use other Runpod base images
- Add system dependencies in the `apt-get install` section
- Update `requirements.txt` with your Python packages
- Replace `main.py` with your application entry point

