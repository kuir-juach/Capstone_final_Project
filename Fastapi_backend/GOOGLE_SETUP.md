# Google Calendar API Setup Guide

## Step 1: Enable Google Calendar API

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the Google Calendar API
4. Go to "Credentials" → "Create Credentials" → "OAuth 2.0 Client IDs"
5. Download the credentials JSON file as `credentials.json`

## Step 2: Generate Token File

Run this script once to generate the `token.json` file:

```python
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

SCOPES = ['https://www.googleapis.com/auth/calendar']

def authenticate():
    creds = None
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file('credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        
        with open('token.json', 'w') as token:
            token.write(creds.to_json())
    
    return creds

if __name__ == '__main__':
    authenticate()
    print("Authentication successful! token.json created.")
```

## Step 3: Email Configuration

Update the email settings in `main.py`:

```python
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
EMAIL_ADDRESS = "your-email@gmail.com"
EMAIL_PASSWORD = "your-app-password"  # Use App Password, not regular password
```

## Step 4: Install Dependencies

```bash
pip install -r requirements_google_meet.txt
```

## Step 5: Test the Integration

1. Start the FastAPI server
2. Book an appointment through the Flutter app
3. Approve it through the admin dashboard
4. Check that Google Meet link is generated and email is sent

## Notes

- The system works with mock Meet links even without Google API setup
- For production, ensure proper OAuth2 flow and token refresh
- Email sending is currently in demo mode (prints to console)
- Uncomment email sending code in `send_email_notification()` for actual emails