from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import Appointment, AppointmentStatus
from schemas import AppointmentCreate, AppointmentUpdate, AppointmentResponse
from typing import List, Optional

router = APIRouter(prefix="/api/appointments", tags=["appointments"])

@router.post("/", response_model=dict)
async def create_appointment(appointment: AppointmentCreate, db: Session = Depends(get_db)):
    try:
        db_appointment = Appointment(**appointment.dict())
        db.add(db_appointment)
        db.commit()
        db.refresh(db_appointment)
        
        return {
            "status": "success",
            "message": "Appointment booked successfully",
            "data": {
                "id": db_appointment.id,
                "status": db_appointment.status.value
            }
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to book appointment: {str(e)}")

@router.get("/", response_model=List[AppointmentResponse])
async def get_all_appointments(db: Session = Depends(get_db)):
    try:
        appointments = db.query(Appointment).order_by(Appointment.timestamp.desc()).all()
        return appointments
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch appointments: {str(e)}")

@router.get("/pending", response_model=List[AppointmentResponse])
async def get_pending_appointments(db: Session = Depends(get_db)):
    try:
        appointments = db.query(Appointment).filter(
            Appointment.status == AppointmentStatus.pending
        ).order_by(Appointment.timestamp.desc()).all()
        return appointments
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch pending appointments: {str(e)}")

@router.patch("/{appointment_id}", response_model=dict)
async def update_appointment_status(
    appointment_id: int,
    appointment_update: AppointmentUpdate,
    db: Session = Depends(get_db)
):
    try:
        appointment = db.query(Appointment).filter(Appointment.id == appointment_id).first()
        if not appointment:
            raise HTTPException(status_code=404, detail="Appointment not found")
        
        appointment.status = appointment_update.status
        db.commit()
        db.refresh(appointment)
        
        return {
            "status": "success",
            "message": f"Appointment {appointment_update.status.value} successfully",
            "data": {
                "id": appointment.id,
                "status": appointment.status.value
            }
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to update appointment: {str(e)}")

@router.get("/{appointment_id}", response_model=AppointmentResponse)
async def get_appointment(appointment_id: int, db: Session = Depends(get_db)):
    try:
        appointment = db.query(Appointment).filter(Appointment.id == appointment_id).first()
        if not appointment:
            raise HTTPException(status_code=404, detail="Appointment not found")
        return appointment
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch appointment: {str(e)}")