from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import Feedback
from schemas import FeedbackCreate, FeedbackResponse
from typing import List

router = APIRouter(prefix="/api/feedback", tags=["feedback"])

@router.post("/", response_model=dict)
async def create_feedback(feedback: FeedbackCreate, db: Session = Depends(get_db)):
    try:
        db_feedback = Feedback(**feedback.dict())
        db.add(db_feedback)
        db.commit()
        db.refresh(db_feedback)
        
        return {
            "status": "success",
            "message": "Feedback received successfully",
            "data": {"id": db_feedback.id}
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to save feedback: {str(e)}")

@router.get("/", response_model=List[FeedbackResponse])
async def get_all_feedback(db: Session = Depends(get_db)):
    try:
        feedback_list = db.query(Feedback).order_by(Feedback.timestamp.desc()).all()
        return feedback_list
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch feedback: {str(e)}")