#!/usr/bin/env python3
"""
LeafSense Integration Test Script
Tests the complete flow from Flutter app to Admin Dashboard
"""

import requests
import json
import time
from datetime import datetime

# Configuration
API_BASE_URL = "http://localhost:8000"
TEST_USER_ID = f"test_user_{int(time.time())}"

def test_api_health():
    """Test if the API is running"""
    try:
        response = requests.get(f"{API_BASE_URL}/health")
        assert response.status_code == 200
        print("✅ API Health Check: PASSED")
        return True
    except Exception as e:
        print(f"❌ API Health Check: FAILED - {e}")
        return False

def test_feedback_flow():
    """Test feedback submission and retrieval"""
    try:
        # Submit feedback
        feedback_data = {
            "user_id": TEST_USER_ID,
            "message": "This is a test feedback message from integration test"
        }
        
        response = requests.post(f"{API_BASE_URL}/api/feedback/", json=feedback_data)
        assert response.status_code == 200
        
        result = response.json()
        assert result["status"] == "success"
        feedback_id = result["data"]["id"]
        
        # Retrieve feedback
        response = requests.get(f"{API_BASE_URL}/api/feedback/")
        assert response.status_code == 200
        
        feedback_list = response.json()
        assert any(f["id"] == feedback_id for f in feedback_list)
        
        print("✅ Feedback Flow: PASSED")
        return True
    except Exception as e:
        print(f"❌ Feedback Flow: FAILED - {e}")
        return False

def test_appointment_flow():
    """Test appointment booking and management"""
    try:
        # Book appointment
        appointment_data = {
            "user_id": TEST_USER_ID,
            "name": "Test User",
            "email": "test@example.com",
            "date": "15/12/2024",
            "reason": "Test consultation for integration testing"
        }
        
        response = requests.post(f"{API_BASE_URL}/api/appointments/", json=appointment_data)
        assert response.status_code == 200
        
        result = response.json()
        assert result["status"] == "success"
        appointment_id = result["data"]["id"]
        
        # Retrieve appointments
        response = requests.get(f"{API_BASE_URL}/api/appointments/")
        assert response.status_code == 200
        
        appointments = response.json()
        appointment = next((a for a in appointments if a["id"] == appointment_id), None)
        assert appointment is not None
        assert appointment["status"] == "pending"
        
        # Approve appointment
        response = requests.patch(
            f"{API_BASE_URL}/api/appointments/{appointment_id}",
            json={"status": "approved"}
        )
        assert response.status_code == 200
        
        result = response.json()
        assert result["status"] == "success"
        
        # Verify status change
        response = requests.get(f"{API_BASE_URL}/api/appointments/{appointment_id}")
        assert response.status_code == 200
        
        appointment = response.json()
        assert appointment["status"] == "approved"
        
        print("✅ Appointment Flow: PASSED")
        return True
    except Exception as e:
        print(f"❌ Appointment Flow: FAILED - {e}")
        return False

def test_prediction_endpoints():
    """Test prediction endpoints (without actual model)"""
    try:
        # Test predictions retrieval
        response = requests.get(f"{API_BASE_URL}/api/predictions")
        assert response.status_code == 200
        
        predictions = response.json()
        assert isinstance(predictions, list)
        
        print("✅ Prediction Endpoints: PASSED")
        return True
    except Exception as e:
        print(f"❌ Prediction Endpoints: FAILED - {e}")
        return False

def test_cors_headers():
    """Test CORS headers for frontend integration"""
    try:
        response = requests.options(f"{API_BASE_URL}/api/feedback/")
        
        # Check for CORS headers
        headers = response.headers
        assert "Access-Control-Allow-Origin" in headers
        assert "Access-Control-Allow-Methods" in headers
        
        print("✅ CORS Configuration: PASSED")
        return True
    except Exception as e:
        print(f"❌ CORS Configuration: FAILED - {e}")
        return False

def run_integration_tests():
    """Run all integration tests"""
    print("🚀 Starting LeafSense Integration Tests")
    print("=" * 50)
    
    tests = [
        test_api_health,
        test_cors_headers,
        test_feedback_flow,
        test_appointment_flow,
        test_prediction_endpoints
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        if test():
            passed += 1
        time.sleep(1)  # Brief pause between tests
    
    print("=" * 50)
    print(f"📊 Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All integration tests PASSED!")
        print("\n✅ Your LeafSense system is ready for deployment!")
    else:
        print("⚠️  Some tests FAILED. Please check the API server and database connection.")
    
    return passed == total

if __name__ == "__main__":
    success = run_integration_tests()
    exit(0 if success else 1)