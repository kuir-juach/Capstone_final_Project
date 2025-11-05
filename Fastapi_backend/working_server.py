from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
import tensorflow as tf
import numpy as np
from PIL import Image
import io
from typing import Dict, List

# Initialize FastAPI app
app = FastAPI(
    title="Medicinal Plant Classifier API",
    description="CNN-based medicinal plant identification system",
    version="1.0.0"
)

# Add CORS middleware for Flutter integration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)

# Configuration
MODEL_PATH = "Medicinal_model.h5"
CLASS_NAMES_PATH = "class_names.txt"
TARGET_SIZE = (256, 256)

# Global variables
model = None
class_names = []

def load_model_and_classes():
    global model, class_names
    
    # Load class names
    try:
        if os.path.exists(CLASS_NAMES_PATH):
            with open(CLASS_NAMES_PATH, 'r', encoding='utf-8') as f:
                class_names = [line.strip() for line in f.readlines() if line.strip()]
        else:
            class_names = [
                'Basale', 'Betle', 'Drumstick', 'Guava', 'Jackfruit',
                'Lemon', 'Mentha', 'Neem', 'Roxburgh fig', 'sinensis'
            ]
        print(f"Loaded {len(class_names)} classes")
    except Exception as e:
        print(f"Error loading classes: {e}")
        class_names = [
            'Basale', 'Betle', 'Drumstick', 'Guava', 'Jackfruit',
            'Lemon', 'Mentha', 'Neem', 'Roxburgh fig', 'sinensis'
        ]
    
    # Load model
    try:
        if os.path.exists(MODEL_PATH):
            model = tf.keras.models.load_model(MODEL_PATH, compile=False)
            print(f"Loaded model from {MODEL_PATH}")
        else:
            raise Exception(f"Model file {MODEL_PATH} not found")
    except Exception as e:
        print(f"Error loading model: {e}")
        raise e

def preprocess_image(image_bytes: bytes) -> np.ndarray:
    try:
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        image = image.resize(TARGET_SIZE, Image.Resampling.LANCZOS)
        img_array = np.array(image, dtype=np.float32)
        img_array = img_array / 255.0
        img_array = np.expand_dims(img_array, axis=0)
        return img_array
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Image preprocessing failed: {str(e)}")

# Load model on startup
load_model_and_classes()

@app.get("/health")
async def health_check() -> Dict[str, str]:
    """Health check endpoint"""
    return {"status": "healthy", "message": "Server is running"}

@app.options("/predict")
async def predict_options():
    """Handle CORS preflight for predict endpoint"""
    return {"message": "OK"}

@app.get("/plants")
async def list_plants() -> List[str]:
    """List all plant classes"""
    return class_names

@app.post("/predict")
async def predict_plant(file: UploadFile = File(...)) -> Dict:
    """Predict medicinal plant from uploaded image"""
    
    # Accept any file type for now (Flutter web sends different content types)
    print(f"Received file: {file.filename}, Content-Type: {file.content_type}")
    
    if not file.filename:
        raise HTTPException(status_code=400, detail="No file provided")
    
    try:
        # Read and preprocess image
        image_bytes = await file.read()
        processed_image = preprocess_image(image_bytes)
        
        # Make prediction using actual model
        predictions = model.predict(processed_image, verbose=0)
        
        # Get predicted class and confidence
        predicted_index = np.argmax(predictions[0])
        confidence = float(predictions[0][predicted_index])
        
        # Map index to class name
        if predicted_index < len(class_names):
            predicted_class = class_names[predicted_index]
        else:
            raise HTTPException(status_code=500, detail="Invalid prediction index")
        
        # Medical safety check
        if confidence < 0.5:
            predicted_class = "OUT OF SCOPE - Not a recognized medicinal plant"
            warning = "Low confidence prediction. This plant may not be in our trained database."
        else:
            warning = "MEDICAL DISCLAIMER: This is AI prediction only. Always consult healthcare professionals."
        
        # Get all class probabilities
        all_predictions = {}
        for i, class_name in enumerate(class_names):
            all_predictions[class_name] = round(float(predictions[0][i]), 4)
        
        return {
            "predicted_class": predicted_class,
            "confidence": round(confidence, 4),
            "all_predictions": all_predictions,
            "medical_warning": warning,
            "safety_note": "Never consume unknown plants. Misidentification can be dangerous or fatal."
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    print("Starting FastAPI server...")
    print("Server will be available at: http://localhost:8000")
    print("Health check: http://localhost:8000/health")
    print("API docs: http://localhost:8000/docs")
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)