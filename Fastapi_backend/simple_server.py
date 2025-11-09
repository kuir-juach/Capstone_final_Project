from fastapi import FastAPI, HTTPException, File, UploadFile, Form
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
import json
import os

app = FastAPI(title="LeafSense API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Simple in-memory storage
appointments = []
feedback_list = []
predictions_list = []

class AppointmentCreate(BaseModel):
    user_id: str
    name: str
    email: str
    date: str
    reason: str

class FeedbackCreate(BaseModel):
    user_id: str
    message: str

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.post("/api/appointments/")
async def create_appointment(appointment: AppointmentCreate):
    try:
        new_appointment = {
            "id": len(appointments) + 1,
            "user_id": appointment.user_id,
            "name": appointment.name,
            "email": appointment.email,
            "date": appointment.date,
            "reason": appointment.reason,
            "status": "pending",
            "timestamp": "2024-01-01T00:00:00"
        }
        appointments.append(new_appointment)
        
        return {
            "status": "success",
            "message": "Appointment booked successfully",
            "data": {"id": new_appointment["id"], "status": "pending"}
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/appointments/")
async def get_appointments():
    return appointments

@app.post("/api/feedback/")
async def create_feedback(feedback: FeedbackCreate):
    try:
        new_feedback = {
            "id": len(feedback_list) + 1,
            "user_id": feedback.user_id,
            "message": feedback.message,
            "timestamp": "2024-01-01T00:00:00"
        }
        feedback_list.append(new_feedback)
        
        return {
            "status": "success",
            "message": "Feedback received successfully",
            "data": {"id": new_feedback["id"]}
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/feedback/")
async def get_feedback():
    return feedback_list

@app.post("/api/predict")
async def predict_plant(file: UploadFile = File(...), user_id: str = Form(...)):
    try:
        # Simulate prediction
        import random
        plants = ['Basale', 'Betle', 'Drumstick', 'Guava', 'Jackfruit', 'Lemon', 'Mentha', 'Neem', 'Roxburgh fig', 'sinensis']
        predicted_class = random.choice(plants)
        confidence = random.uniform(0.6, 0.95)
        
        new_prediction = {
            "id": len(predictions_list) + 1,
            "user_id": user_id,
            "image_url": f"uploads/{file.filename}",
            "prediction_result": predicted_class,
            "confidence": confidence,
            "timestamp": "2024-01-01T00:00:00"
        }
        predictions_list.append(new_prediction)
        
        return {
            "status": "success",
            "message": "Prediction completed successfully",
            "data": {
                "predicted_class": predicted_class,
                "confidence": round(confidence, 4),
                "prediction_id": new_prediction["id"]
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/predictions")
async def get_predictions():
    return predictions_list

@app.patch("/api/appointments/{appointment_id}")
async def update_appointment_status(appointment_id: int, status_data: dict):
    try:
        for apt in appointments:
            if apt["id"] == appointment_id:
                apt["status"] = status_data["status"]
                return {
                    "status": "success",
                    "message": f"Appointment {status_data['status']} successfully",
                    "data": {"id": appointment_id, "status": status_data["status"]}
                }
        raise HTTPException(status_code=404, detail="Appointment not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    print("Starting simple LeafSense API server...")
    print("Server will be available at: http://localhost:8000")
    print("API docs: http://localhost:8000/docs")
    uvicorn.run(app, host="0.0.0.0", port=8000)