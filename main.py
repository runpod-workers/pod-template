"""
Example template application with DistilBERT sentiment classification model.
This demonstrates how to extend a Runpod PyTorch base image and use a baked-in model.
"""

import sys
import torch
import time
import signal
from transformers import pipeline


def main():
    print("Hello from your Runpod template!")
    print(f"Python version: {sys.version.split()[0]}")
    print(f"PyTorch version: {torch.__version__}")
    print(f"CUDA available: {torch.cuda.is_available()}")

    if torch.cuda.is_available():
        print(f"CUDA version: {torch.version.cuda}")
        print(f"GPU device: {torch.cuda.get_device_name(0)}")

    # Initialize the sentiment analysis model (already cached in the image)
    print("\nLoading sentiment analysis model...")
    device = 0 if torch.cuda.is_available() else -1

    # OPTION A: Load from Hugging Face Hub (uses local cache, no downloads)
    # local_files_only=True ensures model is loaded from cache, fails if not cached
    classifier = pipeline(
        "sentiment-analysis",
        model="distilbert-base-uncased-finetuned-sst-2-english",
        device=device,
        model_kwargs={"local_files_only": True},
    )

    # OPTION B: Load from local path (if you downloaded via wget in Dockerfile)
    # classifier = pipeline('sentiment-analysis',
    #                       model='/app/models/distilbert-model',
    #                       device=device)

    print("Model loaded successfully!")

    # Example inference
    test_texts = [
        "This is a wonderful experience!",
        "I really don't like this at all.",
        "The weather is nice today.",
    ]

    print("\n--- Running sentiment analysis ---")
    for text in test_texts:
        result = classifier(text)
        print(f"Text: {text}")
        print(f"Result: {result[0]['label']} (confidence: {result[0]['score']:.4f})\n")

    print("Container is running. Press Ctrl+C to stop.")

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
