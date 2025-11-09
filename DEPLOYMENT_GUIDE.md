# LeafSense Deployment Guide

## 🚀 Complete Integration Setup

### Prerequisites
- Python 3.8+
- PostgreSQL database
- Node.js (for admin dashboard)
- Flutter SDK (for mobile app)

## 1️⃣ Backend Deployment (FastAPI)

### Local Setup
```bash
cd Fastapi_backend

# Install dependencies
pip install -r requirements_integrated.txt

# Set environment variables
cp .env.example .env
# Edit .env with your database credentials

# Initialize database
alembic init alembic
alembic revision --autogenerate -m "Initial migration"
alembic upgrade head

# Run server
python integrated_main.py
```

### Railway Deployment
1. Create Railway account
2. Connect GitHub repository
3. Set environment variables:
   ```
   DATABASE_URL=postgresql://user:pass@host:port/dbname
   PORT=8000
   ENVIRONMENT=production
   ```
4. Deploy from `Fastapi_backend` directory

## 2️⃣ Database Setup (PostgreSQL)

### Local PostgreSQL
```sql
CREATE DATABASE leafsense;
CREATE USER leafsense_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE leafsense TO leafsense_user;
```

### Railway PostgreSQL
1. Add PostgreSQL service in Railway
2. Copy connection string to `DATABASE_URL`

## 3️⃣ Flutter App Integration

### Update API Configuration
```dart
// In lib/services/api_service.dart
static String get baseUrl {
  if (kIsWeb) {
    return 'https://your-railway-app.railway.app'; // Production URL
  } else {
    return 'https://your-railway-app.railway.app'; // Production URL
  }
}
```

### Build and Run
```bash
cd LeafSense_mobile_app

# Install dependencies
flutter pub get

# Run app
flutter run -d chrome  # For web
flutter run -d android # For Android
```

## 4️⃣ Admin Dashboard Deployment

### Netlify Deployment
1. Update API URL in `dashboard.js`:
   ```javascript
   const API_BASE_URL = 'https://your-railway-app.railway.app';
   ```

2. Deploy to Netlify:
   - Drag and drop `admin_dashboard` folder
   - Or connect GitHub repository

### Vercel Deployment
```bash
cd admin_dashboard
npx vercel --prod
```

## 5️⃣ Testing the Integration

### Run Integration Tests
```bash
# Make sure API is running
python test_integration.py
```

### Manual Testing Checklist

#### ✅ Flutter App → API
- [ ] Submit feedback → Check admin dashboard
- [ ] Make prediction → Verify in admin predictions
- [ ] Book appointment → Appears in admin appointments

#### ✅ Admin Dashboard → API
- [ ] View all feedback
- [ ] View all predictions
- [ ] Approve/reject appointments
- [ ] Filter appointments by status

#### ✅ End-to-End Flow
- [ ] User submits feedback → Instantly visible in admin
- [ ] User books appointment → Shows as "pending" in admin
- [ ] Admin approves appointment → Status updates
- [ ] Predictions are logged and viewable

## 6️⃣ Environment Variables

### Backend (.env)
```
DATABASE_URL=postgresql://user:pass@host:port/dbname
PORT=8000
ENVIRONMENT=production
ALLOWED_ORIGINS=https://your-admin-dashboard.netlify.app,https://your-flutter-app.web.app
```

### Frontend (Flutter)
Update `api_service.dart` with production URLs

### Admin Dashboard
Update `dashboard.js` with production API URL

## 7️⃣ CORS Configuration

Ensure FastAPI allows requests from:
- Flutter web app domain
- Admin dashboard domain
- Mobile app (for production builds)

## 8️⃣ Database Migrations

### Create Migration
```bash
alembic revision --autogenerate -m "Description"
```

### Apply Migration
```bash
alembic upgrade head
```

## 9️⃣ Monitoring and Logs

### Railway Logs
```bash
railway logs
```

### Health Checks
- API: `https://your-api.railway.app/health`
- Admin: Check dashboard loads and connects to API

## 🔧 Troubleshooting

### Common Issues

1. **CORS Errors**
   - Update `ALLOWED_ORIGINS` in backend
   - Check admin dashboard API URL

2. **Database Connection**
   - Verify `DATABASE_URL` format
   - Check PostgreSQL service status

3. **Model Loading**
   - Ensure `Medicinal_model.h5` is in backend directory
   - Check TensorFlow compatibility

4. **Flutter Build Issues**
   - Run `flutter clean && flutter pub get`
   - Check API URL configuration

## 📱 Production URLs

After deployment, update these URLs:
- **API**: `https://your-app.railway.app`
- **Admin**: `https://your-admin.netlify.app`
- **Flutter Web**: `https://your-flutter.web.app`

## 🎉 Success Verification

Your LeafSense system is fully integrated when:
- ✅ Users can submit feedback via Flutter app
- ✅ Feedback appears instantly in admin dashboard
- ✅ Plant predictions are logged and viewable
- ✅ Appointment booking works end-to-end
- ✅ Admin can approve/reject appointments
- ✅ All components communicate seamlessly

## 📞 Support

If you encounter issues:
1. Check the integration test results
2. Verify all environment variables
3. Ensure all services are running
4. Check CORS configuration
5. Review API logs for errors