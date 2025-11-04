const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { google } = require('googleapis');

admin.initializeApp();

// Google Calendar API setup
const calendar = google.calendar('v3');
const auth = new google.auth.GoogleAuth({
  keyFile: 'path/to/service-account-key.json', // Add your service account key
  scopes: ['https://www.googleapis.com/auth/calendar']
});

exports.confirmBooking = functions.firestore
  .document('bookings/{bookingId}')
  .onUpdate(async (change, context) => {
    const newValue = change.after.data();
    const previousValue = change.before.data();
    
    // Check if status changed to confirmed
    if (newValue.status === 'confirmed' && previousValue.status === 'pending') {
      try {
        const bookingId = context.params.bookingId;
        const { date, expertName, userEmail, topic } = newValue;
        
        // Create Google Calendar event
        const event = {
          summary: `LeafSense Session: ${topic}`,
          description: `One-on-one session with ${expertName}`,
          start: {
            dateTime: date.toDate().toISOString(),
            timeZone: 'UTC',
          },
          end: {
            dateTime: new Date(date.toDate().getTime() + 60 * 60 * 1000).toISOString(), // 1 hour session
            timeZone: 'UTC',
          },
          attendees: [{ email: userEmail }],
          conferenceData: {
            createRequest: {
              requestId: bookingId,
              conferenceSolutionKey: { type: 'hangoutsMeet' }
            }
          }
        };

        const authClient = await auth.getClient();
        const response = await calendar.events.insert({
          auth: authClient,
          calendarId: 'primary',
          resource: event,
          conferenceDataVersion: 1
        });

        const meetLink = response.data.conferenceData?.entryPoints?.[0]?.uri;

        // Update booking with meet link
        await admin.firestore().collection('bookings').doc(bookingId).update({
          meetLink: meetLink,
          calendarEventId: response.data.id
        });

        console.log('Booking confirmed and meet link generated:', meetLink);
      } catch (error) {
        console.error('Error confirming booking:', error);
      }
    }
  });