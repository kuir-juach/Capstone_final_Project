"""
Medicinal Plant Classification FastAPI
Exact replication of Jupyter notebook training pipeline
"""

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
import tensorflow as tf
import numpy as np
from PIL import Image
import io
from typing import List, Dict

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
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration
MODEL_PATH = "Medicinal_model.h5"
CLASS_NAMES_PATH = "class_names.txt"
TARGET_SIZE = (224, 224)  # Match training size from notebook

# Global variables
model = None
class_names = []

def create_dummy_model():
    """Create a dummy model for deployment when real model fails to load"""
    from tensorflow.keras import layers, models
    
    model = models.Sequential([
        layers.Input(shape=(*TARGET_SIZE, 3)),
        layers.Conv2D(32, 3, activation='relu'),
        layers.GlobalAveragePooling2D(),
        layers.Dense(28, activation='softmax')  # 28 classes from notebook
    ])
    
    model.compile(
        optimizer='adam',
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    
    return model

def load_model_and_classes():
    """Load the trained model and class names exactly as in training"""
    global model, class_names
    
    try:
        # Load class names first
        if os.path.exists(CLASS_NAMES_PATH):
            with open(CLASS_NAMES_PATH, 'r', encoding='utf-8') as f:
                class_names = [line.strip() for line in f.readlines() if line.strip()]
        else:
            # Full class names from notebook
            class_names = [
                'Alpinia Galanga (Rasna)', 'Amaranthus Viridis (Arive-Dantu)', 
                'Artocarpus Heterophyllus (Jackfruit)', 'Basale', 
                'Carissa Carandas (Karanda)', 'Citrus Limon (Lemon)', 
                'Ficus Religiosa (Peepal Tree)', 'Guava', 'Hibiscus Rosa-sinensis', 
                'Jasminum (Jasmine)', 'Mango', 'Mentha (Mint)', 
                'Moringa Oleifera (Drumstick)', 'Muntingia Calabura (Jamaica Cherry-Gasagase)', 
                'Murraya Koenigii (Curry)', 'Neem', 'Nerium Oleander (Oleander)', 
                'Nyctanthes Arbor-tristis (Parijata)', 'Ocimum Tenuiflorum (Tulsi)', 
                'Piper Betle (Betel)', 'Plectranthus Amboinicus (Mexican Mint)', 
                'Punica Granatum (Pomegranate)', 'Roxburgh fig', 
                'Santalum Album (Sandalwood)', 'Syzygium Cumini (Jamun)', 
                'Syzygium Jambos (Rose Apple)', 'Tabernaemontana Divaricata (Crape Jasmine)', 
                'Trigonella Foenum-graecum (Fenugreek)'
            ]
        
        print(f"✅ Loaded {len(class_names)} classes")
        
        # Load the actual trained model
        model = tf.keras.models.load_model(MODEL_PATH)
        print(f"✅ Model loaded successfully from {MODEL_PATH}")
        print(f"Model input shape: {model.input_shape}")
        print(f"Model output shape: {model.output_shape}")
        
    except Exception as e:
        print(f"❌ Error loading classes: {e}")
        raise e

# Load model on startup
load_model_and_classes()

def preprocess_image(image_bytes: bytes) -> np.ndarray:
    """
    Preprocess image exactly as ImageDataGenerator in training:
    - Convert to RGB
    - Resize to (256, 256)
    - Normalize pixel values by dividing by 255.0
    """
    try:
        # Open image and convert to RGB
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        
        # Resize to target size (224x224 from notebook)
        image = image.resize(TARGET_SIZE, Image.Resampling.LANCZOS)
        
        # Convert to numpy array with float32 dtype
        img_array = np.array(image, dtype=np.float32)
        
        # Normalize pixel values (same as ImageDataGenerator rescale=1./255)
        img_array = img_array / 255.0
        
        # Add batch dimension for model input
        img_array = np.expand_dims(img_array, axis=0)
        
        return img_array
        
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Image preprocessing failed: {str(e)}")

@app.get("/health")
async def health_check() -> Dict[str, str]:
    """Health check endpoint"""
    return {"status": "healthy"}

@app.get("/model/info")
async def get_model_info() -> Dict:
    """Get model information and details"""
    global model
    if model is None:
        try:
            load_model_and_classes()
        except:
            raise HTTPException(status_code=500, detail="Model loading failed - incompatible format")
    
    return {
        "model_path": MODEL_PATH,
        "input_size": TARGET_SIZE,
        "num_classes": len(class_names),
        "model_input_shape": list(model.input_shape),
        "model_output_shape": list(model.output_shape),
        "preprocessing": "RGB conversion, resize to 256x256, normalize by /255.0"
    }

@app.get("/plants")
async def list_plants() -> List[str]:
    """List all plant classes in alphabetical order"""
    return class_names

@app.post("/predict")
async def predict_plant(file: UploadFile = File(...)) -> Dict:
    """
    Predict medicinal plant from uploaded image
    Returns plant name, confidence score, and medical warnings
    """
    # Load model if not already loaded
    global model
    if model is None:
        try:
            load_model_and_classes()
        except:
            # Return mock response when model fails to load
            return {
                "predicted_class": "Model temporarily unavailable",
                "confidence": 0.0,
                "medical_warning": "Service temporarily unavailable. Model compatibility issue.",
                "safety_note": "Please try again later or contact support."
            }
    
    # Validate file type
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=400, 
            detail="Invalid file type. Please upload a JPG or PNG image."
        )
    
    try:
        # Read and preprocess image
        image_bytes = await file.read()
        processed_image = preprocess_image(image_bytes)
        
        # Make prediction using the loaded model
        predictions = model.predict(processed_image, verbose=0)
        
        # Get predicted class and confidence
        predicted_index = np.argmax(predictions[0])
        confidence = float(predictions[0][predicted_index])
        
        # Map index to class name
        if predicted_index < len(class_names):
            predicted_class = class_names[predicted_index]
        else:
            raise HTTPException(status_code=500, detail="Invalid prediction index")
        
        # Strict out-of-scope detection for medical safety
        if confidence < 0.8:
            predicted_class = "OUT OF SCOPE - Not a recognized medicinal plant"
            warning = "This plant is not in our trained database or confidence is too low. NEVER use unidentified plants for medical purposes."
        elif predicted_class in ["Low confidence - Consult medical expert"]:
            predicted_class = "OUT OF SCOPE - Consult medical expert"
            warning = "Uncertain identification. Always consult healthcare professionals before using any plant medicinally."
        else:
            warning = "MEDICAL DISCLAIMER: This is AI prediction only. Always consult healthcare professionals before using any plant medicinally."
        
        # Get all class probabilities for transparency
        all_predictions = {}
        for i, class_name in enumerate(class_names):
            all_predictions[class_name] = round(float(predictions[0][i]), 4)
        
        return {
            "predicted_class": predicted_class,
            "confidence": round(confidence, 4),
            "all_predictions": all_predictions,
            "medical_warning": warning,
            "safety_note": "Never consume unknown plants. Misidentification can be dangerous or fatal.",
            "model_info": {
                "input_size": TARGET_SIZE,
                "preprocessing": "RGB conversion, resize to 256x256, normalize by /255.0"
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)