"""
Example template application.
This demonstrates how to extend a Runpod PyTorch base image.
"""

import sys
import torch

def main():
    print("Hello from your Runpod template!")
    print(f"Python version: {sys.version.split()[0]}")
    print(f"PyTorch version: {torch.__version__}")
    print(f"CUDA available: {torch.cuda.is_available()}")
    
    if torch.cuda.is_available():
        print(f"CUDA version: {torch.version.cuda}")
        print(f"GPU device: {torch.cuda.get_device_name(0)}")
    
    # Add your application logic here
    return 0

if __name__ == "__main__":
    sys.exit(main())

