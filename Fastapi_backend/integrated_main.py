from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import engine, Base
from routes import feedback, predictions, appointments
import os

# Create database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="LeafSense API",
    description="Medicinal Plant Classification System with User Management",
    version="1.0.0"
)

# CORS middleware for Flutter and Admin Dashboard
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure specific origins in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(feedback.router)
app.include_router(predictions.router)
app.include_router(appointments.router)

@app.get("/")
async def root():
    return {
        "message": "LeafSense API is running",
        "version": "1.0.0",
        "endpoints": {
            "feedback": "/api/feedback",
            "predictions": "/api/predictions",
            "appointments": "/api/appointments",
            "docs": "/docs"
        }
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "LeafSense API"}

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)