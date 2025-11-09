from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from datetime import datetime, timedelta
import json
import os

class GoogleMeetService:
    def __init__(self, credentials_file='token.json'):
        self.credentials_file = credentials_file
        self.service = None
        self._initialize_service()
    
    def _initialize_service(self):
        """Initialize Google Calendar service"""
        try:
            if os.path.exists(self.credentials_file):
                creds = Credentials.from_authorized_user_file(self.credentials_file)
                self.service = build('calendar', 'v3', credentials=creds)
            else:
                print(f"Credentials file {self.credentials_file} not found. Using mock service.")
                self.service = None
        except Exception as e:
            print(f"Failed to initialize Google Calendar service: {e}")
            self.service = None
    
    def create_meet_event(self, appointment_data):
        """Create Google Calendar event with Meet link"""
        if not self.service:
            # Return mock Meet link if service not available
            return f"https://meet.google.com/mock-{appointment_data['id']}"
        
        try:
            # Parse appointment date
            appointment_date = datetime.strptime(appointment_data['date'], '%d/%m/%Y')
            start_time = appointment_date.replace(hour=10, minute=0)  # Default 10 AM
            end_time = start_time + timedelta(hours=1)  # 1 hour duration
            
            event = {
                'summary': f'LeafSense Consultation - {appointment_data["name"]}',
                'description': f'Consultation for: {appointment_data["reason"]}',
                'start': {
                    'dateTime': start_time.isoformat(),
                    'timeZone': 'UTC',
                },
                'end': {
                    'dateTime': end_time.isoformat(),
                    'timeZone': 'UTC',
                },
                'attendees': [
                    {'email': appointment_data['email']},
                ],
                'conferenceData': {
                    'createRequest': {
                        'requestId': f"leafsense-{appointment_data['id']}",
                        'conferenceSolutionKey': {'type': 'hangoutsMeet'}
                    }
                },
                'reminders': {
                    'useDefault': False,
                    'overrides': [
                        {'method': 'email', 'minutes': 24 * 60},  # 1 day before
                        {'method': 'popup', 'minutes': 30},       # 30 minutes before
                    ],
                },
            }
            
            # Create the event
            created_event = self.service.events().insert(
                calendarId='primary',
                body=event,
                conferenceDataVersion=1
            ).execute()
            
            # Extract Meet link
            meet_link = created_event.get('conferenceData', {}).get('entryPoints', [{}])[0].get('uri', '')
            return meet_link
            
        except Exception as e:
            print(f"Failed to create Google Meet event: {e}")
            # Return mock link as fallback
            return f"https://meet.google.com/fallback-{appointment_data['id']}"
    
    def delete_event(self, event_id):
        """Delete Google Calendar event"""
        if not self.service:
            return True
        
        try:
            self.service.events().delete(calendarId='primary', eventId=event_id).execute()
            return True
        except Exception as e:
            print(f"Failed to delete event: {e}")
            return False

# Global instance
google_meet_service = GoogleMeetService()