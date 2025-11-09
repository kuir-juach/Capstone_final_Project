const API_BASE_URL = 'http://localhost:8000';

// Global data storage
let feedbackData = [];
let predictionsData = [];
let appointmentsData = [];
let profilesData = [];

// Initialize dashboard
document.addEventListener('DOMContentLoaded', function() {
    loadDashboardData();
    // Auto-refresh every 30 seconds
    setInterval(loadDashboardData, 30000);
});

// Navigation functions
function showSection(sectionName) {
    // Hide all sections
    document.querySelectorAll('.section').forEach(section => {
        section.style.display = 'none';
    });
    
    // Remove active class from all nav links
    document.querySelectorAll('.nav-link').forEach(link => {
        link.classList.remove('active');
    });
    
    // Show selected section
    document.getElementById(sectionName + '-section').style.display = 'block';
    
    // Add active class to clicked nav link
    event.target.classList.add('active');
    
    // Update page title
    document.getElementById('page-title').textContent = 
        sectionName.charAt(0).toUpperCase() + sectionName.slice(1);
    
    // Load section-specific data
    if (sectionName === 'feedback') {
        loadFeedback();
    } else if (sectionName === 'predictions') {
        loadPredictions();
    } else if (sectionName === 'appointments') {
        loadAppointments();
    } else if (sectionName === 'profiles') {
        loadProfiles();
    }
}

// Data loading functions
async function loadDashboardData() {
    try {
        await Promise.all([
            loadFeedback(),
            loadPredictions(),
            loadAppointments(),
            loadProfiles()
        ]);
        updateDashboardStats();
    } catch (error) {
        console.error('Error loading dashboard data:', error);
    }
}

async function loadFeedback() {
    try {
        const response = await fetch(`${API_BASE_URL}/api/feedback/`);
        feedbackData = await response.json();
        displayFeedback();
        updateDashboardStats();
    } catch (error) {
        console.error('Error loading feedback:', error);
        feedbackData = [];
    }
}

async function loadPredictions() {
    try {
        const response = await fetch(`${API_BASE_URL}/api/predictions`);
        predictionsData = await response.json();
        displayPredictions();
        updateDashboardStats();
    } catch (error) {
        console.error('Error loading predictions:', error);
        predictionsData = [];
    }
}

async function loadAppointments() {
    try {
        const response = await fetch(`${API_BASE_URL}/api/appointments/`);
        appointmentsData = await response.json();
        displayAppointments();
        updateDashboardStats();
    } catch (error) {
        console.error('Error loading appointments:', error);
        appointmentsData = [];
    }
}

async function loadProfiles() {
    try {
        const response = await fetch(`${API_BASE_URL}/api/profiles`);
        profilesData = await response.json();
        displayProfiles();
        updateDashboardStats();
    } catch (error) {
        console.error('Error loading profiles:', error);
        profilesData = [];
    }
}

// Display functions
function displayFeedback() {
    const tbody = document.getElementById('feedback-table-body');
    tbody.innerHTML = '';
    
    feedbackData.forEach(feedback => {
        const row = `
            <tr>
                <td>${feedback.id}</td>
                <td>${feedback.user_id}</td>
                <td>${feedback.message}</td>
                <td>${new Date(feedback.timestamp).toLocaleString()}</td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
}

function displayPredictions() {
    const tbody = document.getElementById('predictions-table-body');
    tbody.innerHTML = '';
    
    predictionsData.forEach(prediction => {
        const row = `
            <tr>
                <td>${prediction.id}</td>
                <td>${prediction.user_id}</td>
                <td>${prediction.prediction_result}</td>
                <td>${(prediction.confidence * 100).toFixed(2)}%</td>
                <td>${new Date(prediction.timestamp).toLocaleString()}</td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
}

function displayAppointments() {
    const tbody = document.getElementById('appointments-table-body');
    tbody.innerHTML = '';
    
    appointmentsData.forEach(appointment => {
        const statusClass = `status-${appointment.status}`;
        const statusBadge = appointment.status === 'approved' ? 'badge bg-success' : 
                           appointment.status === 'rejected' ? 'badge bg-danger' : 
                           appointment.status === 'cancelled' ? 'badge' : 'badge bg-warning';
        const cancelledStyle = appointment.status === 'cancelled' ? 'style="background-color: #ffcccb; color: #000;"' : '';
        
        const meetLinkDisplay = appointment.meet_link ? 
            `<a href="${appointment.meet_link}" target="_blank" class="btn btn-sm btn-primary" 
               onclick="window.open('${appointment.meet_link}', '_blank'); return false;">
                <i class="fas fa-video"></i> Join Meet
            </a>` : '-';
        
        const row = `
            <tr id="appointment-${appointment.id}">
                <td>${appointment.id}</td>
                <td>${appointment.name}</td>
                <td>${appointment.email}</td>
                <td>${appointment.doctor || 'Dr. Achol Dut Amol'}</td>
                <td>${appointment.date} ${appointment.time || ''}</td>
                <td>${appointment.reason}</td>
                <td><span class="${statusBadge}" ${cancelledStyle}>${appointment.status.toUpperCase()}</span></td>
                <td>
                    ${appointment.status === 'pending' ? `
                        <button class="btn btn-sm btn-success me-1" onclick="updateAppointmentStatus(${appointment.id}, 'approved')">
                            <i class="fas fa-check"></i> Approve
                        </button>
                        <button class="btn btn-sm btn-danger me-1" onclick="updateAppointmentStatus(${appointment.id}, 'rejected')">
                            <i class="fas fa-times"></i> Reject
                        </button>
                        <button class="btn btn-sm btn-warning" onclick="cancelAppointment(${appointment.id})">
                            <i class="fas fa-ban"></i> Cancel
                        </button>
                    ` : appointment.status === 'approved' ? `
                        ${meetLinkDisplay}
                        <button class="btn btn-sm btn-warning ms-1" onclick="cancelAppointment(${appointment.id})">
                            <i class="fas fa-ban"></i> Cancel
                        </button>
                    ` : meetLinkDisplay}
                    <button class="btn btn-sm btn-danger ms-1" onclick="deleteAppointment(${appointment.id})">
                        <i class="fas fa-trash"></i> Remove
                    </button>
                </td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
}

function displayProfiles() {
    const tbody = document.getElementById('profiles-table-body');
    tbody.innerHTML = '';
    
    profilesData.forEach(profile => {
        const profileImage = profile.profile_image_url ? 
            `<img src="${API_BASE_URL}/${profile.profile_image_url}" alt="Profile" style="width: 40px; height: 40px; border-radius: 50%; object-fit: cover;">` : 
            '<i class="fas fa-user-circle fa-2x text-muted"></i>';
        
        const row = `
            <tr>
                <td>${profile.id}</td>
                <td>${profile.user_id}</td>
                <td>${profile.name || '-'}</td>
                <td>${profile.email || '-'}</td>
                <td>${profile.phone || '-'}</td>
                <td>${profile.state || '-'}</td>
                <td>${profileImage}</td>
                <td>${new Date(profile.created_at).toLocaleDateString()}</td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
}

// Update dashboard statistics
function updateDashboardStats() {
    document.getElementById('total-feedback').textContent = feedbackData.length;
    document.getElementById('total-predictions').textContent = predictionsData.length;
    document.getElementById('total-appointments').textContent = appointmentsData.length;
    document.getElementById('total-profiles').textContent = profilesData.length;
    
    const pendingAppointments = appointmentsData.filter(apt => apt.status === 'pending').length;
    document.getElementById('pending-appointments').textContent = pendingAppointments;
}

// Appointment management functions
async function updateAppointmentStatus(appointmentId, status) {
    try {
        console.log(`Updating appointment ${appointmentId} to ${status}`);
        
        const response = await fetch(`${API_BASE_URL}/api/appointments/${appointmentId}`, {
            method: 'PATCH',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ status: status })
        });
        
        const responseData = await response.json();
        console.log('Response:', responseData);
        
        if (response.ok && responseData.status === 'success') {
            // Highlight the updated row
            const row = document.getElementById(`appointment-${appointmentId}`);
            if (row) {
                row.style.backgroundColor = status === 'approved' ? '#d4edda' : '#f8d7da';
                row.style.transition = 'background-color 0.5s ease';
            }
            
            await loadAppointments();
            updateDashboardStats();
            
            // Show success message
            const alertDiv = document.createElement('div');
            alertDiv.className = `alert alert-success alert-dismissible fade show`;
            alertDiv.innerHTML = `
                <strong>Success!</strong> ${responseData.message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            `;
            document.querySelector('main').insertBefore(alertDiv, document.querySelector('main').firstChild);
            
            // Auto dismiss after 3 seconds
            setTimeout(() => {
                if (alertDiv.parentNode) {
                    alertDiv.remove();
                }
            }, 3000);
        } else {
            throw new Error(responseData.message || 'Failed to update appointment status');
        }
    } catch (error) {
        console.error('Error updating appointment:', error);
        
        // Show error message
        const alertDiv = document.createElement('div');
        alertDiv.className = `alert alert-danger alert-dismissible fade show`;
        alertDiv.innerHTML = `
            <strong>Error!</strong> ${error.message || 'Failed to update appointment status'}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        `;
        document.querySelector('main').insertBefore(alertDiv, document.querySelector('main').firstChild);
        
        // Auto dismiss after 5 seconds
        setTimeout(() => {
            if (alertDiv.parentNode) {
                alertDiv.remove();
            }
        }, 5000);
    }
}

function filterAppointments(status) {
    const tbody = document.getElementById('appointments-table-body');
    const rows = tbody.querySelectorAll('tr');
    
    rows.forEach(row => {
        if (status === 'all') {
            row.style.display = '';
        } else {
            const statusCell = row.querySelector('td:nth-child(7)');
            if (statusCell && statusCell.textContent.toLowerCase().includes(status)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        }
    });
}

// Delete appointment function
async function deleteAppointment(appointmentId) {
    if (!confirm('Are you sure you want to permanently remove this appointment?')) {
        return;
    }
    
    try {
        const response = await fetch(`${API_BASE_URL}/admin/appointments/${appointmentId}`, {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json',
            }
        });
        
        const responseData = await response.json();
        
        if (response.ok && responseData.status === 'success') {
            await loadAppointments();
            updateDashboardStats();
            
            const alertDiv = document.createElement('div');
            alertDiv.className = `alert alert-info alert-dismissible fade show`;
            alertDiv.innerHTML = `
                <strong>Removed!</strong> ${responseData.message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            `;
            document.querySelector('main').insertBefore(alertDiv, document.querySelector('main').firstChild);
            
            setTimeout(() => {
                if (alertDiv.parentNode) {
                    alertDiv.remove();
                }
            }, 3000);
        } else {
            throw new Error(responseData.message || 'Failed to remove appointment');
        }
    } catch (error) {
        console.error('Error removing appointment:', error);
        alert('Failed to remove appointment: ' + error.message);
    }
}

// Cancel appointment function
async function cancelAppointment(appointmentId) {
    if (!confirm('Are you sure you want to cancel this appointment?')) {
        return;
    }
    
    try {
        const response = await fetch(`${API_BASE_URL}/cancel_appointment/${appointmentId}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            }
        });
        
        const responseData = await response.json();
        
        if (response.ok && responseData.status === 'success') {
            await loadAppointments();
            updateDashboardStats();
            
            // Show success message
            const alertDiv = document.createElement('div');
            alertDiv.className = `alert alert-warning alert-dismissible fade show`;
            alertDiv.innerHTML = `
                <strong>Cancelled!</strong> ${responseData.message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            `;
            document.querySelector('main').insertBefore(alertDiv, document.querySelector('main').firstChild);
            
            setTimeout(() => {
                if (alertDiv.parentNode) {
                    alertDiv.remove();
                }
            }, 3000);
        } else {
            throw new Error(responseData.message || 'Failed to cancel appointment');
        }
    } catch (error) {
        console.error('Error cancelling appointment:', error);
        alert('Failed to cancel appointment: ' + error.message);
    }
}

// Refresh data
async function refreshData() {
    const refreshBtn = document.querySelector('button[onclick="refreshData()"]');
    const icon = refreshBtn.querySelector('i');
    
    // Add spinning animation
    icon.classList.add('fa-spin');
    refreshBtn.disabled = true;
    
    try {
        await loadDashboardData();
    } finally {
        // Remove spinning animation
        setTimeout(() => {
            icon.classList.remove('fa-spin');
            refreshBtn.disabled = false;
        }, 500);
    }
}