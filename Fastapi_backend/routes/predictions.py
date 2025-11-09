from fastapi import APIRouter, Depends, HTTPException, File, UploadFile, Form
from sqlalchemy.orm import Session
from database import get_db
from models import Prediction
from schemas import PredictionResponse
from typing import List, Optional
import os
import tensorflow as tf
import numpy as np
from PIL import Image
import io

router = APIRouter(prefix="/api", tags=["predictions"])

# Load your trained model
model = None
class_names = [
    'Basale', 'Betle', 'Drumstick', 'Guava', 'Jackfruit',
    'Lemon', 'Mentha', 'Neem', 'Roxburgh fig', 'sinensis'
]

def load_model():
    global model
    try:
        model = tf.keras.models.load_model("Medicinal_model.h5", compile=False)
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

@router.post("/predict", response_model=dict)
async def predict_plant(
    file: UploadFile = File(...),
    user_id: str = Form(...),
    db: Session = Depends(get_db)
):
    if not model_loaded:
        raise HTTPException(status_code=500, detail="Model not loaded")
    
    try:
        # Process image
        image_bytes = await file.read()
        processed_image = preprocess_image(image_bytes)
        
        # Make prediction
        predictions = model.predict(processed_image, verbose=0)
        predicted_idx = np.argmax(predictions[0])
        confidence = float(predictions[0][predicted_idx])
        predicted_class = class_names[predicted_idx]
        
        # Save prediction to database
        db_prediction = Prediction(
            user_id=user_id,
            image_url=f"uploads/{file.filename}",  # You can implement file storage
            prediction_result=predicted_class,
            confidence=confidence
        )
        db.add(db_prediction)
        db.commit()
        db.refresh(db_prediction)
        
        # Create response with all predictions
        all_predictions = {}
        for i, class_name in enumerate(class_names):
            all_predictions[class_name] = round(float(predictions[0][i]), 4)
        
        return {
            "status": "success",
            "message": "Prediction completed successfully",
            "data": {
                "predicted_class": predicted_class,
                "confidence": round(confidence, 4),
                "all_predictions": all_predictions,
                "prediction_id": db_prediction.id
            }
        }
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")

@router.get("/predictions", response_model=List[PredictionResponse])
async def get_all_predictions(db: Session = Depends(get_db)):
    try:
        predictions = db.query(Prediction).order_by(Prediction.timestamp.desc()).all()
        return predictions
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch predictions: {str(e)}")