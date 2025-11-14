# Runpod Template Example

This is a clean template repository demonstrating how to create a Runpod template by extending a base image.

## Structure

- `Dockerfile` - Extends the Runpod PyTorch base image using pip (default)
- `Dockerfile.uv` - Alternative Dockerfile using uv for faster package installation
- `requirements.txt` - Python package dependencies (for pip)
- `main.py` - Example application entry point
- `run.sh` - Optional script for running custom commands with base image services (Option 2)
- `.dockerignore` - Files to exclude from Docker build context
- `.github/workflows/dev.yml` - GitHub Actions workflow for automated builds

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
docker build --platform linux/amd64 -t my-template .
```

### Option 2: Using uv

To use `uv` for faster package installation, use `Dockerfile.uv`:

```bash
docker build --platform linux/amd64 -f Dockerfile.uv -t my-template .
```

Make sure your dependencies are listed in `requirements.txt` (uv can read requirements.txt files).

**Note**: The `--platform linux/amd64` flag is required when building on non-Linux systems (macOS, ARM, etc.).

## Entrypoint and Service Options

The Dockerfiles demonstrate three approaches for handling the base image's entrypoint and services:

### Option 1: Keep everything from base image (DEFAULT)

Preserves all base image functionality (Jupyter, SSH, CUDA setup). The base image's `/start.sh` script automatically starts Jupyter/SSH based on template settings. No CMD override needed - just use the default.

### Option 2: Override CMD but keep services

If you want to run your own command but still have Jupyter/SSH start:

1. Edit `run.sh` to customize what runs after services start
2. Uncomment the Option 2 lines in your Dockerfile:
   ```dockerfile
   COPY run.sh /app/run.sh
   RUN chmod +x /app/run.sh
   CMD ["/app/run.sh"]
   ```

The `run.sh` script starts `/start.sh` in background, waits for services, then runs your commands.

### Option 3: Override everything

No Jupyter, no SSH - just your application. Override both entrypoint and CMD:

```dockerfile
ENTRYPOINT []  # Clear entrypoint
CMD ["python", "/app/main.py"]
```

See the Dockerfiles for detailed comments on each option.

## Usage

1. Customize `requirements.txt` with your Python dependencies
2. Add your application code
3. Choose your entrypoint option (see above)
4. Build the Docker image:

   ```bash
   # Using pip (default)
   docker build --platform linux/amd64 -t my-template .

   # Or using uv
   docker build --platform linux/amd64 -f Dockerfile.uv -t my-template .
   ```

5. Test locally:
   ```bash
   docker run --rm --platform linux/amd64 my-template
   ```
6. Push to Docker Hub or your container registry for use with Runpod

## Automated Builds

This repository includes a GitHub Actions workflow (`.github/workflows/dev.yml`) that automatically:

- Builds both pip and uv-based images on push to main
- Pushes images to Docker Hub as:
  - `runpod/pod-template:latest` (pip-based)
  - `runpod/pod-template:pip-latest` (pip-based)
  - `runpod/pod-template:uv-latest` (uv-based)

To use the workflow, add these GitHub secrets:

- `DOCKERHUB_USERNAME` - Your Docker Hub username
- `DOCKERHUB_TOKEN` - Your Docker Hub access token

## Customization

- Modify the `FROM` line in the Dockerfile to use other Runpod base images
- Add system dependencies in the `apt-get install` section
- Update `requirements.txt` with your Python packages
- Replace `main.py` with your application entry point
- Choose entrypoint/service option (see Entrypoint and Service Options above)
- Customize `run.sh` if using Option 2
