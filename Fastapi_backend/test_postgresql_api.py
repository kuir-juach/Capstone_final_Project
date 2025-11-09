#!/usr/bin/env python3
"""
Test script for LeafSense API with PostgreSQL integration
Tests all endpoints to ensure proper database connectivity
"""

import requests
import json
import time
from datetime import datetime

BASE_URL = "http://localhost:8000"

def test_health():
    """Test health endpoint"""
    print("🔍 Testing health endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/health")
        print(f"✅ Health check: {response.json()}")
        return True
    except Exception as e:
        print(f"❌ Health check failed: {e}")
        return False

def test_feedback():
    """Test feedback endpoints"""
    print("\n🔍 Testing feedback endpoints...")
    
    # Create feedback
    feedback_data = {
        "user_id": "test_user_123",
        "message": "Great app! The plant identification is very accurate."
    }
    
    try:
        response = requests.post(f"{BASE_URL}/api/feedback/", json=feedback_data)
        print(f"✅ Create feedback: {response.json()}")
        
        # Get all feedback
        response = requests.get(f"{BASE_URL}/api/feedback/")
        print(f"✅ Get all feedback: Found {len(response.json())} feedback entries")
        
        # Get user feedback
        response = requests.get(f"{BASE_URL}/api/feedback/user/test_user_123")
        print(f"✅ Get user feedback: Found {len(response.json())} entries for test_user_123")
        
        return True
    except Exception as e:
        print(f"❌ Feedback test failed: {e}")
        return False

def test_appointments():
    """Test appointment endpoints"""
    print("\n🔍 Testing appointment endpoints...")
    
    # Create appointment
    appointment_data = {
        "user_id": "test_user_123",
        "name": "John Doe",
        "email": "john.doe@example.com",
        "date": "2024-01-15",
        "time": "10:00 AM",
        "doctor": "Dr. Smith",
        "reason": "Plant identification consultation"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/api/appointments/", json=appointment_data)
        result = response.json()
        print(f"✅ Create appointment: {result}")
        appointment_id = result["data"]["id"]
        
        # Get all appointments
        response = requests.get(f"{BASE_URL}/api/appointments/")
        print(f"✅ Get all appointments: Found {len(response.json())} appointments")
        
        # Get user appointments
        response = requests.get(f"{BASE_URL}/api/appointments/user/test_user_123")
        print(f"✅ Get user appointments: Found {len(response.json())} appointments for test_user_123")
        
        # Update appointment status
        status_data = {"status": "approved"}
        response = requests.patch(f"{BASE_URL}/api/appointments/{appointment_id}", json=status_data)
        print(f"✅ Update appointment status: {response.json()}")
        
        return True
    except Exception as e:
        print(f"❌ Appointment test failed: {e}")
        return False

def test_predictions():
    """Test prediction endpoints"""
    print("\n🔍 Testing prediction endpoints...")
    
    try:
        # Get all predictions
        response = requests.get(f"{BASE_URL}/api/predictions")
        print(f"✅ Get all predictions: Found {len(response.json())} predictions")
        
        # Get user predictions
        response = requests.get(f"{BASE_URL}/api/predictions/user/test_user_123")
        print(f"✅ Get user predictions: Found {len(response.json())} predictions for test_user_123")
        
        return True
    except Exception as e:
        print(f"❌ Prediction test failed: {e}")
        return False

def test_stats():
    """Test system stats endpoint"""
    print("\n🔍 Testing system stats...")
    
    try:
        response = requests.get(f"{BASE_URL}/api/stats")
        stats = response.json()
        print(f"✅ System stats:")
        print(f"   - Total predictions: {stats['total_predictions']}")
        print(f"   - Total appointments: {stats['total_appointments']}")
        print(f"   - Total feedback: {stats['total_feedback']}")
        print(f"   - Pending appointments: {stats['pending_appointments']}")
        print(f"   - Approved appointments: {stats['approved_appointments']}")
        
        return True
    except Exception as e:
        print(f"❌ Stats test failed: {e}")
        return False

def test_profiles():
    """Test profile endpoints"""
    print("\n🔍 Testing profile endpoints...")
    
    user_id = "test_profile_user_123"
    
    # Create profile
    profile_data = {
        "user_id": user_id,
        "name": "John Doe",
        "email": "john.doe@example.com",
        "phone": "+1234567890",
        "state": "California"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/api/profile/", json=profile_data)
        print(f"✅ Create profile: {response.json()}")
        
        # Get profile
        response = requests.get(f"{BASE_URL}/api/profile/{user_id}")
        print(f"✅ Get profile: {response.json()}")
        
        # Update profile
        update_data = {
            "name": "John Smith",
            "phone": "+0987654321"
        }
        response = requests.put(f"{BASE_URL}/api/profile/{user_id}", json=update_data)
        print(f"✅ Update profile: {response.json()}")
        
        # Get all profiles
        response = requests.get(f"{BASE_URL}/api/profiles")
        print(f"✅ Get all profiles: Found {len(response.json())} profiles")
        
        return True
    except Exception as e:
        print(f"❌ Profile test failed: {e}")
        return False

def main():
    """Run all tests"""
    print("🚀 Starting LeafSense PostgreSQL API Tests")
    print("=" * 50)
    
    tests = [
        test_health,
        test_feedback,
        test_appointments,
        test_predictions,
        test_stats,
        test_profiles
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        if test():
            passed += 1
        time.sleep(1)  # Small delay between tests
    
    print("\n" + "=" * 50)
    print(f"🏁 Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("✅ All tests passed! PostgreSQL integration is working correctly.")
    else:
        print("❌ Some tests failed. Check the database connection and server status.")

if __name__ == "__main__":
    main()