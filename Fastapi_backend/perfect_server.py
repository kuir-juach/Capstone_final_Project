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

class_names = [
    'Basale', 'Betle', 'Drumstick', 'Guava', 'Jackfruit',
    'Lemon', 'Mentha', 'Neem', 'Roxburgh fig', 'sinensis'
]

model = None

def load_model():
    global model
    try:
        model = tf.keras.models.load_model("Medicinal_model.h5", compile=False)
        print("Model loaded successfully!")
        return True
    except Exception as e:
        print(f"Model loading failed: {e}")
        return False

def preprocess_image(image_bytes):
    image = Image.open(io.BytesIO(image_bytes)).convert('RGB')
    image = image.resize((256, 256), Image.Resampling.LANCZOS)
    img_array = np.array(image, dtype=np.float32) / 255.0
    return np.expand_dims(img_array, axis=0)

# Load model on startup
model_loaded = load_model()

@app.get("/health")
async def health_check():
    return {"status": "healthy", "model_loaded": model_loaded}

@app.options("/predict")
async def predict_options():
    return {"message": "OK"}

@app.get("/plants")
async def list_plants():
    return class_names

@app.post("/predict")
async def predict_plant(file: UploadFile = File(...)):
    if not model_loaded:
        raise HTTPException(status_code=500, detail="Model not loaded")
    
    try:
        image_bytes = await file.read()
        processed_image = preprocess_image(image_bytes)
        
        predictions = model.predict(processed_image, verbose=0)
        predicted_idx = np.argmax(predictions[0])
        confidence = float(predictions[0][predicted_idx])
        predicted_class = class_names[predicted_idx]
        
        all_predictions = {}
        for i, class_name in enumerate(class_names):
            all_predictions[class_name] = round(float(predictions[0][i]), 4)
        
        return {
            "predicted_class": predicted_class,
            "confidence": round(confidence, 4),
            "all_predictions": all_predictions,
            "medical_warning": "MEDICAL DISCLAIMER: Consult healthcare professionals."
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=False)