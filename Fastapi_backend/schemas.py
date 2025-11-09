from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from models import AppointmentStatus

class FeedbackCreate(BaseModel):
    user_id: str
    message: str

class FeedbackResponse(BaseModel):
    id: int
    user_id: str
    message: str
    timestamp: datetime
    
    class Config:
        from_attributes = True

class PredictionCreate(BaseModel):
    user_id: str
    image_url: Optional[str] = None
    prediction_result: str
    confidence: float

class PredictionResponse(BaseModel):
    id: int
    user_id: str
    image_url: Optional[str]
    prediction_result: str
    confidence: float
    timestamp: datetime
    
    class Config:
        from_attributes = True

class AppointmentCreate(BaseModel):
    user_id: str
    name: str
    email: str
    date: str
    time: Optional[str] = None
    doctor: Optional[str] = None
    reason: str

class AppointmentUpdate(BaseModel):
    status: AppointmentStatus

class AppointmentResponse(BaseModel):
    id: int
    user_id: str
    name: str
    email: str
    date: str
    reason: str
    status: AppointmentStatus
    timestamp: datetime
    
    class Config:
        from_attributes = True

class UserProfileCreate(BaseModel):
    user_id: str
    name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    state: Optional[str] = None
    profile_image_url: Optional[str] = None

class UserProfileUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    state: Optional[str] = None
    profile_image_url: Optional[str] = None

class UserProfileResponse(BaseModel):
    id: int
    user_id: str
    name: Optional[str]
    email: Optional[str]
    phone: Optional[str]
    state: Optional[str]
    profile_image_url: Optional[str]
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True