Project Overview

Goal: Train a simple CNN on FashionMNIST and run inference on a custom image.
Dataset: FashionMNIST (60k train, 10k test), auto-downloaded to the project root.
Code: Data loaders in data_prep.py, training and inference in model.ipynb.

Structure

data_prep.py: Builds trainloader/testloader and label names.
model.ipynb: Visualizes samples, defines Net, trains, saves model_full.pth, and runs inference.
FashionMNIST: Raw IDX files auto-downloaded by torchvision.
test_image: Place custom grayscale test images (e.g., shirt.jpg).
model_full.pth: Saved trained model

Prerequisites

Python: 3.9+ recommended
Environment: conda or venv (Windows)
Packages: torch, torchvision, matplotlib, Pillow, numpy, ipykernel
