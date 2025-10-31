# Smart Reminders App Architecture

## Overview
A mobile app that sends smart reminders based on location, time, or WiFi connection triggers with Google Sign-In authentication.

## Core Features
1. **Authentication**: Google Sign-In via Firebase Auth
2. **Task Management**: Create, view, edit, delete, and categorize tasks
3. **Smart Triggers**:
   - Location-based (enter/exit geofence)
   - Time-based (specific date/time)
   - WiFi-based (connect/disconnect from network)
4. **Notifications**: Local notifications with snooze functionality
5. **Task History**: View completed/snoozed tasks
6. **Location Management**: Save locations with map-based perimeter selection
7. **Categories**: Home, Work, School, All

## Technology Stack
- **Authentication**: Firebase Auth (Google Sign-In)
- **Database**: Firebase Firestore
- **Notifications**: flutter_local_notifications
- **Location**: geolocator, google_maps_flutter
- **WiFi**: connectivity_plus, network_info_plus
- **Background Tasks**: workmanager
- **Storage**: shared_preferences

## Data Models

### User
- id (String)
- email (String)
- displayName (String)
- photoUrl (String?)
- createdAt (DateTime)
- updatedAt (DateTime)

### Task
- id (String)
- userId (String)
- title (String)
- description (String?)
- category (TaskCategory: home, work, school, all)
- triggerType (TriggerType: location, time, wifi)
- triggerConfig (Map<String, dynamic>) - stores trigger-specific data
- stateChange (StateChange?) - enter/exit for location, connect/disconnect for wifi
- isCompleted (bool)
- isSnoozed (bool)
- snoozeUntil (DateTime?)
- completedAt (DateTime?)
- createdAt (DateTime)
- updatedAt (DateTime)

### SavedLocation
- id (String)
- userId (String)
- name (String)
- latitude (double)
- longitude (double)
- radiusMeters (double)
- createdAt (DateTime)
- updatedAt (DateTime)

### TaskHistory
- id (String)
- taskId (String)
- userId (String)
- action (HistoryAction: completed, snoozed, triggered)
- timestamp (DateTime)

## File Structure

```
lib/
├── main.dart
├── theme.dart
├── models/
│   ├── user.dart
│   ├── task.dart
│   ├── saved_location.dart
│   └── task_history.dart
├── services/
│   ├── auth_service.dart
│   ├── task_service.dart
│   ├── location_service.dart
│   ├── notification_service.dart
│   ├── wifi_service.dart
│   └── background_service.dart
├── screens/
│   ├── auth/
│   │   └── login_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── task/
│   │   ├── add_task_screen.dart
│   │   └── task_history_screen.dart
│   └── location/
│       └── add_location_screen.dart
└── widgets/
    ├── task_card.dart
    ├── task_form.dart
    ├── location_picker.dart
    └── category_chip.dart
```

## Service Layer

### AuthService
- Google Sign-In integration
- Firebase Auth management
- User session handling

### TaskService
- CRUD operations for tasks
- Firestore integration
- Task filtering by category and status

### LocationService
- Get current location
- Monitor location changes
- Check geofence boundaries
- Manage saved locations

### NotificationService
- Schedule notifications
- Handle notification actions
- Snooze functionality
- Background notification handling

### WiFiService
- Get current WiFi SSID
- Monitor WiFi connection changes
- Detect connect/disconnect events

### BackgroundService
- Monitor location changes in background
- Monitor WiFi connection changes
- Trigger notifications when conditions are met
- Use WorkManager for periodic checks

## UI Screens

### LoginScreen
- Google Sign-In button
- App logo and description
- Clean, modern design

### HomeScreen
- List of active tasks
- Category filter chips (All, Home, Work, School)
- FAB for adding new task
- Menu with options:
  - Add Location
  - Task History
  - Logout

### AddTaskScreen
- Task title and description
- Category selection
- Trigger type selection (Location, Time, WiFi)
- State change selection (for location and WiFi)
- Trigger configuration based on type:
  - Location: Select saved location
  - Time: Date/time picker
  - WiFi: Select from known networks

### TaskHistoryScreen
- List of completed/snoozed tasks
- Filter by action type
- Grouped by date

### AddLocationScreen
- Google Maps integration
- Set location name
- Adjust perimeter radius with slider
- Visual circle on map showing geofence

## Permissions Required

### Android (AndroidManifest.xml)
- INTERNET
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION
- ACCESS_BACKGROUND_LOCATION
- ACCESS_WIFI_STATE
- ACCESS_NETWORK_STATE
- RECEIVE_BOOT_COMPLETED
- SCHEDULE_EXACT_ALARM
- POST_NOTIFICATIONS

### iOS (Info.plist)
- NSLocationWhenInUseUsageDescription
- NSLocationAlwaysUsageDescription
- NSLocalNetworkUsageDescription

## Design Approach
- **Style**: Sophisticated Monochrome for productivity focus
- **Colors**: Blue accent on dark/light backgrounds
- **Layout**: Card-based design with generous spacing
- **Navigation**: Bottom navigation for main sections
- **Icons**: Material Icons throughout
