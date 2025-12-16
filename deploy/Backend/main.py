from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import torch
import torch.nn as nn
import torch.nn.functional as F
from torchvision import transforms
from PIL import Image
import io
import os

app = FastAPI(
    title="Fashion MNIST Classifier API",
    description="API for classifying Fashion MNIST images",
    version="1.0.0"
)

# Enable CORS for Flutter web app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your Flutter app's URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Fashion MNIST class labels
FASHION_CLASSES = [
    'T-shirt/Top',
    'Trouser',
    'Pullover',
    'Dress',
    'Coat',
    'Sandal',
    'Shirt',
    'Sneaker',
    'Bag',
    'Ankle Boot'
]

# LeNet Architecture (required for loading the model)
class Net(nn.Module):
    def __init__(self):
        super().__init__()
        self.conv1 = nn.Conv2d(1, 6, 5)
        self.pool = nn.MaxPool2d(2, 2)
        self.conv2 = nn.Conv2d(6, 16, 5)
        self.fc1 = nn.Linear(5 * 5 * 16, 120)
        self.fc2 = nn.Linear(120, 84)
        self.fc3 = nn.Linear(84, 10)

    def forward(self, x):
        x = self.pool(F.relu(self.conv1(x)))
        x = self.pool(F.relu(self.conv2(x)))
        x = torch.flatten(x, 1)
        x = F.relu(self.fc1(x))
        x = F.relu(self.fc2(x))
        x = self.fc3(x)
        return x

# Load model
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model = None

def load_model():
    global model
    # Get the directory where this script is located
    script_dir = os.path.dirname(os.path.abspath(__file__))
    # model.pth is at the root: Fashion_MNIST-Classication/model.pth
    model_path = os.path.join(script_dir, "..", "..", "model.pth")
    
    try:
        # Load the model with weights_only=False since it contains the full model
        model = torch.load(model_path, map_location=device, weights_only=False)
        model.eval()
        print(f"Model loaded successfully from {model_path}!")
    except Exception as e:
        print(f"Error loading model: {e}")
        raise e

# Image preprocessing (same as training)
transform = transforms.Compose([
    transforms.Grayscale(num_output_channels=1),
    transforms.Resize((32, 32)),
    transforms.ToTensor(),
    transforms.Normalize((0.5,), (0.5,)),
])

@app.on_event("startup")
async def startup_event():
    load_model()

@app.get("/")
async def root():
    return {"message": "Fashion MNIST Classifier API", "status": "running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "model_loaded": model is not None}

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    """
    Predict the class of an uploaded fashion image.
    
    - **file**: Image file (PNG, JPG, JPEG)
    
    Returns:
    - **predicted_class**: Class index (0-9)
    - **class_name**: Human readable class name
    - **confidence**: Prediction confidence percentage
    - **all_probabilities**: Probabilities for all classes
    """
    if model is None:
        raise HTTPException(status_code=500, detail="Model not loaded")
    
    # Validate file type
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")
    
    try:
        # Read image
        contents = await file.read()
        image = Image.open(io.BytesIO(contents))
        
        # Convert to RGB first if necessary, then transform
        if image.mode != 'L':
            image = image.convert('L')
        
        # Apply transforms
        image_tensor = transform(image).unsqueeze(0).to(device)
        
        # Predict
        with torch.no_grad():
            outputs = model(image_tensor)
            probabilities = F.softmax(outputs, dim=1)
            confidence, predicted = torch.max(probabilities, 1)
            
            predicted_class = predicted.item()
            confidence_percent = confidence.item() * 100
            all_probs = probabilities[0].tolist()
        
        return JSONResponse(content={
            "predicted_class": predicted_class,
            "class_name": FASHION_CLASSES[predicted_class],
            "confidence": round(confidence_percent, 2),
            "all_probabilities": {
                FASHION_CLASSES[i]: round(prob * 100, 2) 
                for i, prob in enumerate(all_probs)
            }
        })
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing image: {str(e)}")

@app.get("/classes")
async def get_classes():
    """Get all Fashion MNIST class labels"""
    return {"classes": FASHION_CLASSES}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)