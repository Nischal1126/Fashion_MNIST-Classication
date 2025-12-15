# Fashion MNIST Classification

A CNN-based(leNet) image classification model trained on the Fashion-MNIST dataset using PyTorch.

## Dataset

**Fashion-MNIST** contains 70,000 grayscale images (28×28 pixels) across 10 clothing categories:
- T-shirt/top, Trouser, Pullover, Dress, Coat, Sandal, Shirt, Sneaker, Bag, Ankle boot

- Training set: 60,000 images
- Test set: 10,000 images

Dataset is automatically downloaded from torchvision.

## Model Architecture

Simple CNN with:
- 2 Convolutional layers (Conv2d + ReLU + MaxPool2d)
- Dropout for regularization (25% after conv, 50% after fc)
- 3 Fully connected layers
- Input: 32×32 grayscale images
- Output: 10 classes

## Project Structure

```
AlexNet/
├── data_prep.py          # Data loading and preprocessing
├── model.ipynb           # Training and evaluation notebook
├── model_weights.pth     # Saved model weights
├── FashionMNIST/         # Downloaded dataset (auto-generated)
└── test_image/           # Custom test images
```

## Setup

1. **Clone repository:**
```bash
git clone https://github.com/Nischal1126/Fashion_MNIST-Classication.git
cd Fashion_MNIST-Classication
```

2. **Create environment:**
```bash
conda create -n dl_env python=3.9 -y
conda activate dl_env
```

3. **Install dependencies:**
```bash
pip install torch torchvision matplotlib pillow numpy scikit-learn seaborn
```

## Usage

### Training

1. Run data preparation:
```bash
python data_prep.py
```

2. Open and run `model.ipynb` in VS Code or Jupyter:
   - Define model architecture
   - Train for multiple epochs
   - Evaluate on test set
   - Save model weights

### Inference on Custom Images

Place your image in `test_image/` and run the inference cell in `model.ipynb`:
```python
net = Net()
net.load_state_dict(torch.load("model_weights.pth"))
net.eval()
# Prediction code...
```

## Results

- **Training Accuracy:** ~87%
- **Test Accuracy:** ~86%

Performance can be improved with:
- Larger batch sizes (32-64)
- More epochs (10-20)
- Data augmentation
- Deeper architectures

## Configuration

**Hyperparameters** (in `data_prep.py` and training cells):
- Batch size: 32
- Learning rate: 0.001
- Optimizer: SGD with momentum (0.9)
- Loss function: CrossEntropyLoss
- Epochs: 10-20

## Requirements

- Python 3.9+
- PyTorch 2.0+
- torchvision
- matplotlib
- Pillow
- NumPy
- scikit-learn
- seaborn


## Author

Nischal

