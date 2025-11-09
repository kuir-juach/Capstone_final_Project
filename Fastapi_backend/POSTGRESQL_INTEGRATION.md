# LeafSense PostgreSQL Integration

## Overview
LeafSense now uses PostgreSQL as the primary database for storing all application data including:
- **Predictions**: Plant identification results with confidence scores
- **Appointments**: Medical consultations with doctors
- **Feedback**: User feedback and reviews

## Database Schema

### Tables

#### 1. Predictions
```sql
CREATE TABLE predictions (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR NOT NULL,
    image_url VARCHAR,
    prediction_result VARCHAR NOT NULL,
    confidence FLOAT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 2. Appointments
```sql
CREATE TABLE appointments (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR NOT NULL,
    name VARCHAR NOT NULL,
    email VARCHAR NOT NULL,
    date VARCHAR NOT NULL,
    time VARCHAR,
    doctor VARCHAR,
    reason TEXT NOT NULL,
    status appointment_status DEFAULT 'pending',
    meet_link VARCHAR,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 3. Feedback
```sql
CREATE TABLE feedback (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR NOT NULL,
    message TEXT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## API Endpoints

### Predictions
- `POST /predict` - Predict plant (anonymous user)
- `POST /predict/user/{user_id}` - Predict plant for specific user
- `GET /api/predictions` - Get all predictions
- `GET /api/predictions/user/{user_id}` - Get user's predictions

### Appointments
- `POST /api/appointments/` - Create appointment
- `GET /api/appointments/` - Get all appointments
- `GET /api/appointments/user/{user_id}` - Get user's appointments
- `PATCH /api/appointments/{id}` - Update appointment status
- `POST /approve_appointment/{id}` - Approve appointment
- `POST /reject_appointment/{id}` - Reject appointment

### Feedback
- `POST /api/feedback/` - Submit feedback
- `GET /api/feedback/` - Get all feedback
- `GET /api/feedback/user/{user_id}` - Get user's feedback

### System
- `GET /api/stats` - Get system statistics
- `GET /health` - Health check
- `POST /cleanup_expired_appointments` - Clean old appointments

## Setup Instructions

### 1. Database Setup
```bash
# Install PostgreSQL
# Create database and user
psql -U postgres
CREATE DATABASE leafsense_db;
CREATE USER leafsense_user WITH PASSWORD 'admin123';
GRANT ALL PRIVILEGES ON DATABASE leafsense_db TO leafsense_user;
```

### 2. Environment Configuration
Create `.env` file:
```env
DATABASE_URL=postgresql://leafsense_user:admin123@localhost:5432/leafsense_db
POSTGRES_USER=leafsense_user
POSTGRES_PASSWORD=admin123
POSTGRES_DB=leafsense_db
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Initialize Database
```bash
python init_db.py
```

### 5. Start Server
```bash
# Option 1: Direct start
python main.py

# Option 2: With database initialization
python start_with_db.py

# Option 3: Using uvicorn
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

## Testing

### Run API Tests
```bash
python test_postgresql_api.py
```

### Manual Testing
1. Visit `http://localhost:8000/docs` for interactive API documentation
2. Test endpoints using the Swagger UI
3. Check database content using PostgreSQL client

## Key Features

### 1. Data Persistence
- All data is stored in PostgreSQL
- No more in-memory storage
- Data survives server restarts

### 2. User-Specific Data
- Track predictions per user
- User-specific appointment history
- Personal feedback tracking

### 3. Comprehensive Statistics
- System-wide statistics
- User activity tracking
- Performance metrics

### 4. Robust Error Handling
- Database connection validation
- Transaction management
- Proper error responses

### 5. Background Tasks
- Email notifications for appointments
- Asynchronous processing
- Google Meet link generation

## Database Maintenance

### Backup
```bash
pg_dump -U leafsense_user -h localhost leafsense_db > backup.sql
```

### Restore
```bash
psql -U leafsense_user -h localhost leafsense_db < backup.sql
```

### Monitor
```sql
-- Check table sizes
SELECT schemaname,tablename,attname,n_distinct,correlation FROM pg_stats;

-- Check active connections
SELECT * FROM pg_stat_activity;
```

## Migration from In-Memory Storage

The application has been fully migrated from in-memory storage to PostgreSQL:

1. ✅ Removed all global lists (`appointments`, `feedback_list`, `predictions_list`)
2. ✅ Updated all endpoints to use database operations
3. ✅ Added proper database session management
4. ✅ Implemented user-specific data retrieval
5. ✅ Added comprehensive error handling
6. ✅ Created database initialization scripts
7. ✅ Added testing and monitoring tools

## Troubleshooting

### Common Issues

1. **Connection Error**
   - Check PostgreSQL service is running
   - Verify database credentials in `.env`
   - Ensure database exists

2. **Table Not Found**
   - Run `python init_db.py`
   - Check database permissions

3. **Import Errors**
   - Install all requirements: `pip install -r requirements.txt`
   - Check Python version compatibility

### Logs
Check server logs for detailed error information:
```bash
tail -f server.log
```

## Performance Considerations

1. **Database Indexing**: Indexes on `user_id` fields for faster queries
2. **Connection Pooling**: SQLAlchemy handles connection pooling
3. **Query Optimization**: Efficient queries for user-specific data
4. **Background Tasks**: Non-blocking operations for email notifications

## Security

1. **Environment Variables**: Sensitive data in `.env` file
2. **SQL Injection Protection**: SQLAlchemy ORM prevents SQL injection
3. **Input Validation**: Pydantic models validate all inputs
4. **Connection Security**: Secure database connections