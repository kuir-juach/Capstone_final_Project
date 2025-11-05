from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import random
from typing import Dict

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

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.options("/predict")
async def predict_options():
    return {"message": "OK"}

@app.post("/predict")
async def predict_plant(file: UploadFile = File(...)):
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Invalid file type")
    
    # Simulate prediction
    predicted_class = random.choice(class_names)
    confidence = random.uniform(0.6, 0.95)
    
    return {
        "predicted_class": predicted_class,
        "confidence": round(confidence, 4),
        "medical_warning": "This is a demo prediction. Consult healthcare professionals."
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)