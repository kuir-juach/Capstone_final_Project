# LeafSense Profile Integration Setup Guide

## Overview
The LeafSense app now has complete user profile functionality with PostgreSQL backend integration. Users can:
- Upload profile pictures
- Add personal information (name, phone, email, state)
- Save all details to PostgreSQL database
- Edit and update their profiles

## Backend Setup

### 1. Database Models Added
- **UserProfile** table with fields:
  - `id` (Primary Key)
  - `user_id` (Unique identifier)
  - `name`, `email`, `phone`, `state`
  - `profile_image_url`
  - `created_at`, `updated_at` timestamps

### 2. API Endpoints Added
- `POST /api/profile/` - Create or update profile
- `GET /api/profile/{user_id}` - Get user profile
- `PUT /api/profile/{user_id}` - Update profile
- `POST /api/profile/{user_id}/upload-image` - Upload profile image
- `GET /api/profiles` - Get all profiles (admin)

### 3. File Upload Support
- Profile images saved to `uploads/profiles/` directory
- Automatic directory creation
- File validation for image types

## Flutter App Updates

### 1. Profile Screen Enhanced
- **Image Upload**: Tap profile picture to select from gallery
- **Form Fields**: Name, Phone, Email, State
- **Real-time Validation**: Input validation and error handling
- **Loading States**: Progress indicators during operations

### 2. Services Added
- **ProfileService**: Handles all API calls
- **Persistent User ID**: Uses SharedPreferences for user identification
- **Error Handling**: Comprehensive error management

### 3. Dependencies Added
- `shared_preferences: ^2.2.2` - For user ID persistence
- `http: ^1.1.0` - Already included for API calls

## Setup Instructions

### Backend Setup
1. **Initialize Database**:
   ```bash
   cd Fastapi_backend
   python init_db.py
   ```

2. **Start Server**:
   ```bash
   python start_with_db.py
   # or
   python -m uvicorn main:app --reload
   ```

3. **Test API**:
   ```bash
   python test_postgresql_api.py
   ```

### Flutter Setup
1. **Install Dependencies**:
   ```bash
   cd LeafSense_mobile_app
   flutter pub get
   ```

2. **Run App**:
   ```bash
   flutter run
   ```

## Usage Flow

### User Profile Creation
1. User opens Profile screen
2. App generates/retrieves unique user ID
3. User fills in profile information
4. User can upload profile picture
5. Tap "Save" to store in PostgreSQL
6. Success message confirms save

### Profile Updates
1. User taps "Edit" button
2. Fields become editable
3. User modifies information
4. Can change profile picture
5. Tap "Save" to update database
6. Changes reflected immediately

## Database Schema

```sql
CREATE TABLE user_profiles (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR UNIQUE NOT NULL,
    name VARCHAR,
    email VARCHAR,
    phone VARCHAR,
    state VARCHAR,
    profile_image_url VARCHAR,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## API Examples

### Create Profile
```bash
curl -X POST http://localhost:8000/api/profile/ \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user_123",
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "state": "California"
  }'
```

### Upload Profile Image
```bash
curl -X POST http://localhost:8000/api/profile/user_123/upload-image \
  -F "file=@profile.jpg"
```

### Get Profile
```bash
curl http://localhost:8000/api/profile/user_123
```

## Features

### ✅ Implemented
- Profile creation and updates
- Image upload and storage
- Form validation
- Error handling
- Database persistence
- User ID management
- API integration

### 🔄 Data Flow
1. **Flutter App** → **ProfileService** → **FastAPI Backend** → **PostgreSQL**
2. User interactions trigger API calls
3. Data stored persistently in database
4. Real-time updates in UI

### 🛡️ Security Features
- Input validation on both client and server
- File type validation for images
- SQL injection protection via SQLAlchemy ORM
- Error handling prevents data corruption

## Troubleshooting

### Common Issues
1. **Database Connection**: Ensure PostgreSQL is running
2. **File Upload**: Check `uploads/profiles/` directory permissions
3. **API Errors**: Verify server is running on port 8000
4. **Flutter Dependencies**: Run `flutter pub get`

### Testing
- Use `test_postgresql_api.py` to verify backend
- Check database with PostgreSQL client
- Monitor server logs for errors

## Next Steps
- Add user authentication integration
- Implement profile picture compression
- Add profile validation rules
- Create admin panel for profile management