"""
Example template application.
This demonstrates how to extend a Runpod PyTorch base image.
"""

import sys
import torch
import time
import signal

def main():
    print("Hello from your Runpod template!")
    print(f"Python version: {sys.version.split()[0]}")
    print(f"PyTorch version: {torch.__version__}")
    print(f"CUDA available: {torch.cuda.is_available()}")
    
    if torch.cuda.is_available():
        print(f"CUDA version: {torch.version.cuda}")
        print(f"GPU device: {torch.cuda.get_device_name(0)}")
    
    print("\nContainer is running. Add your application logic here.")
    print("Press Ctrl+C to stop.")
    
    # Keep container running
    def signal_handler(sig, frame):
        print("\nShutting down...")
        sys.exit(0)
    
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Keep running until terminated
    try:
        while True:
            time.sleep(60)
    except KeyboardInterrupt:
        signal_handler(None, None)

if __name__ == "__main__":
    main()

