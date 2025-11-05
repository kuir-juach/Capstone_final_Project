from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
import tensorflow as tf
import numpy as np
from PIL import Image
import io

app = FastAPI(title="Medicinal Plant Classifier API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)

# Exact class names from your training (alphabetical order)
class_names = [
    'Basale', 'Betle', 'Drumstick', 'Guava', 'Jackfruit',
    'Lemon', 'Mentha', 'Neem', 'Roxburgh fig', 'sinensis'
]

model = None

def load_model():
    global model
    model_path = "Medicinal_model.h5"
    
    try:
        print(f"Loading model from: {model_path}")
        model = tf.keras.models.load_model(model_path, compile=False)
        print("✅ Model loaded successfully")
        print(f"Input shape: {model.input_shape}")
        print(f"Output shape: {model.output_shape}")
        return True
    except Exception as e:
        print(f"❌ Model loading failed: {e}")
        return False

def preprocess_image(image_bytes):
    """Preprocess image exactly as during training"""
    try:
        # Load image
        image = Image.open(io.BytesIO(image_bytes))
        
        # Convert to RGB (remove alpha channel if present)
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # Resize to 256x256 (your training size)
        image = image.resize((256, 256), Image.Resampling.LANCZOS)
        
        # Convert to numpy array
        img_array = np.array(image, dtype=np.float32)
        
        # Normalize to [0,1] range (divide by 255)
        img_array = img_array / 255.0
        
        # Add batch dimension
        img_array = np.expand_dims(img_array, axis=0)
        
        print(f"Preprocessed image shape: {img_array.shape}")
        print(f"Image value range: [{img_array.min():.3f}, {img_array.max():.3f}]")
        
        return img_array
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Image preprocessing failed: {str(e)}")

# Load model on startup
if not load_model():
    print("❌ Failed to load model on startup")
    exit(1)

@app.get("/health")
async def health_check():
    return {"status": "healthy", "model_loaded": model is not None}

@app.options("/predict")
async def predict_options():
    return {"message": "OK"}

@app.get("/plants")
async def list_plants():
    return class_names

@app.post("/predict")
async def predict_plant(file: UploadFile = File(...)):
    if model is None:
        raise HTTPException(status_code=500, detail="Model not loaded")
    
    print(f"Received file: {file.filename}")
    
    try:
        # Read image
        image_bytes = await file.read()
        print(f"Image size: {len(image_bytes)} bytes")
        
        # Preprocess image
        processed_image = preprocess_image(image_bytes)
        
        # Make prediction
        print("Making prediction...")
        predictions = model.predict(processed_image, verbose=0)
        print(f"Raw predictions shape: {predictions.shape}")
        print(f"Raw predictions: {predictions[0]}")
        
        # Get predicted class
        predicted_index = np.argmax(predictions[0])
        confidence = float(predictions[0][predicted_index])
        predicted_class = class_names[predicted_index]
        
        print(f"Predicted index: {predicted_index}")
        print(f"Predicted class: {predicted_class}")
        print(f"Confidence: {confidence:.4f}")
        
        # Create all predictions
        all_predictions = {}
        for i, class_name in enumerate(class_names):
            all_predictions[class_name] = round(float(predictions[0][i]), 4)
        
        # Medical safety check
        if confidence < 0.5:
            warning = "Low confidence prediction. Consult experts before use."
        else:
            warning = "MEDICAL DISCLAIMER: AI prediction only. Consult healthcare professionals."
        
        return {
            "predicted_class": predicted_class,
            "confidence": round(confidence, 4),
            "predicted_index": int(predicted_index),
            "all_predictions": all_predictions,
            "medical_warning": warning,
            "total_classes": len(class_names)
        }
        
    except Exception as e:
        print(f"Prediction error: {e}")
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    print("Starting server with trained model...")
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=False)