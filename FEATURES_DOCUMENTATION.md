# ZYMM App - Features Documentation

This document provides comprehensive information about the Notification Center and Feedback System implementations.

---

# 1. Notification Center

## Overview
A complete notification system that displays notifications fetched from the backend API. The notification center supports marking notifications as read, filtering between all and unread notifications, and displays unread counts with a badge on the home screen.

## Features

### Notification Type Enum
Six types of notifications (maps to backend IDs 1-6):
- **NotificationZymm** (1) 🏋️
- **NotificationGeneralInfo** (2) ℹ️
- **NotificationGymBroadcast** (3) 📢
- **NotificationMembershipReq** (4) 📝
- **NotificationMembershipRes** (5) ✅
- **NotificationFeedbackReceived** (6) 💬

### UI Features
- Two tabs: "All" and "Unread" notifications
- Beautiful color-coded cards for each notification type
- Mark as Read button on each unread notification
- Floating Action Button to mark all as read
- Unread count badge on home screen bell icon
- Pull-to-refresh support
- Loading and error states with retry
- Empty states with helpful messages

### API Endpoints
```
GET  /zymm/v1/notification/getMyNotifications
POST /zymm/v1/notification/markAsRead
```

### Usage
```dart
// Navigate to notification center
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const NotificationCenter(),
  ),
);

// Access from home screen via bell icon in app bar
```

### File Structure
```
lib/common/enums/
└── notification_type.dart

lib/features/notifications/
├── data/
│   ├── models/
│   │   ├── notification_model.dart
│   │   └── mark_as_read_request_model.dart
│   └── repositories/
│       └── notification_repository.dart
└── presentation/
    ├── notification_center.dart
    └── viewmodel/
        └── notification_viewmodel.dart
```

---

# 2. Feedback System

## Overview
A complete feedback/rating system for gym reviews. Members and all roles (except owners) can rate gyms from 1-5 stars with optional comments. Includes three screens: Create Feedback, View All Feedbacks, and Individual Feedback Detail.

## Features

### Three Main Screens

#### 1. Create Feedback Screen
**Purpose:** Rate a gym with 1-5 stars and optional comments

**Features:**
- Gym info header showing name, location, current rating
- Interactive 5-star rating selector
- Optional comments field (max 500 characters)
- Form validation (rating is mandatory)
- Submit with loading state

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CreateFeedbackScreen(gymId: 1),
  ),
);
```

#### 2. All Feedbacks Screen
**Purpose:** View all reviews for a gym

**Features:**
- Rating summary card with:
  - Average rating display
  - Star visualization
  - Rating distribution chart (1-5 stars)
  - Total reviews count
- List of all feedbacks (sorted newest first)
- User avatars, names, dates, ratings
- Comments preview
- Tap to view full details

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AllFeedbacksScreen(
      gymId: 1,
      gymName: 'My Gym', // optional
    ),
  ),
);
```

#### 3. Feedback Detail Screen
**Purpose:** View individual feedback in detail

**Features:**
- Beautiful gradient header
- Large user avatar
- Full date and time
- Large star rating display
- Complete comments text
- Feedback ID reference

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => FeedbackDetailScreen(feedbackId: 1),
  ),
);
```

### API Endpoints
```
POST /zymm/v1/feedback/create
GET  /zymm/v1/feedback/getAllByGymId?gymId={id}
GET  /zymm/v1/feedback/get?feedbackId={id}
GET  /zymm/v1/gym/getGymData?gymId={id}
```

### Data Models
- **FeedbackModel** - Complete feedback data
- **GymModel** - Gym information with statistics
- **CreateFeedbackRequestModel** - Request for creating feedback

### Validation Rules
- **Rating**: Required, 1-5 (inclusive), Integer
- **Comments**: Optional, Max 500 characters

### File Structure
```
lib/features/feedback/
├── data/
│   ├── models/
│   │   ├── feedback_model.dart
│   │   ├── gym_model.dart
│   │   └── create_feedback_request_model.dart
│   └── repositories/
│       └── feedback_repository.dart
└── presentation/
    ├── screens/
    │   ├── create_feedback_screen.dart
    │   ├── all_feedbacks_screen.dart
    │   └── feedback_detail_screen.dart
    └── viewmodel/
        └── feedback_viewmodel.dart
```

### Role-Based Access
**Can Create Feedback:**
- ✅ Members (roleId: 5)
- ✅ Trainers (roleId: 4)
- ✅ Staff (roleId: 3)
- ✅ Managers (roleId: 2)
- ❌ Owners (roleId: 1) - Cannot rate their own gyms

**Can View Feedback:**
- ✅ All roles

---

# Provider Setup

Both features are registered in `main.dart`:

```dart
MultiProvider(
  providers: [
    // ... other providers
    ChangeNotifierProvider(create: (_) => NotificationViewModel()),
    ChangeNotifierProvider(create: (_) => FeedbackViewModel()),
  ],
  // ...
)
```

---

# Common UI/UX Patterns

## Visual Design
1. **Gradient Headers** - Beautiful gradient backgrounds
2. **Card-based Layout** - Clean, modern card designs
3. **Color Coding** - Type-specific colors for clarity
4. **User Avatars** - Profile pictures or colored initials
5. **Star Ratings** - Visual star displays with amber color

## User Experience
1. **Loading States** - Progress indicators during API calls
2. **Error Handling** - Clear messages with retry buttons
3. **Empty States** - Helpful messages when no data exists
4. **Pull-to-Refresh** - Refresh by pulling down
5. **Form Validation** - Prevent invalid submissions
6. **Success Feedback** - SnackBar notifications
7. **Navigation Flow** - Intuitive screen transitions

## Accessibility
1. **Large Touch Targets** - Minimum 48px for interactive elements
2. **Clear Labels** - Descriptive text everywhere
3. **Color Contrast** - High contrast for readability
4. **Readable Fonts** - Appropriate sizes and weights

---

# Integration Examples

## Example 1: Home Screen with Notifications
The notification bell icon with unread badge is already integrated in the home screen app bar.

## Example 2: Gym Details with Feedback
```dart
// In your Gym Details screen
Column(
  children: [
    // ... gym info ...
    
    // Rate this gym button
    ElevatedButton.icon(
      icon: const Icon(Icons.star),
      label: const Text('Rate This Gym'),
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateFeedbackScreen(gymId: gym.gymId),
          ),
        );
        
        // Refresh if feedback was created
        if (result == true) {
          // Refresh gym data or feedbacks list
        }
      },
    ),
    
    // View all reviews button
    TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllFeedbacksScreen(
              gymId: gym.gymId,
              gymName: gym.gymName,
            ),
          ),
        );
      },
      child: const Text('See All Reviews'),
    ),
  ],
)
```

## Example 3: Notification to Feedback Navigation
```dart
// When user taps on a feedback notification
if (notification.notificationType == NotificationType.notificationFeedbackReceived) {
  // Extract feedbackId from notification data
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => FeedbackDetailScreen(
        feedbackId: extractedFeedbackId,
      ),
    ),
  );
}
```

---

# Testing Checklist

## Notification Center
- [ ] Opens from home screen bell icon
- [ ] Displays all notifications correctly
- [ ] Filters to unread tab works
- [ ] Mark as read updates UI immediately
- [ ] Mark all as read works
- [ ] Unread badge shows correct count
- [ ] Pull-to-refresh works
- [ ] Empty states display properly
- [ ] Error states show retry option

## Feedback System

### Create Feedback
- [ ] Opens with gymId
- [ ] Displays gym info correctly
- [ ] Star rating is interactive
- [ ] Cannot submit without rating
- [ ] Can submit rating only
- [ ] Can submit rating + comments
- [ ] Shows success/error messages
- [ ] Returns to previous screen

### All Feedbacks
- [ ] Shows rating summary
- [ ] Lists all feedbacks chronologically
- [ ] Pull-to-refresh works
- [ ] Tap navigates to detail
- [ ] Empty state displays
- [ ] Loading/error states work

### Feedback Detail
- [ ] Opens with feedbackId
- [ ] Displays all information
- [ ] Shows "no comments" state
- [ ] Handles loading/error

---

# API Response Examples

## Notification Response
```json
{
  "status": 200,
  "data": [
    {
      "notificationId": 1,
      "notificationType": 2,
      "notificationTitle": "Membership Expiry!!!",
      "notificationDesc": "Please renew your membership...",
      "userId": 2,
      "createdBy": 1,
      "createdOn": "2025-10-29T09:09:34.94Z",
      "isRead": false
    }
  ]
}
```

## Feedback Response
```json
{
  "status": 200,
  "data": [
    {
      "feedbackId": 1,
      "rating": 5,
      "comments": "Great gym!",
      "gymId": 1,
      "createdBy": 2,
      "createdByName": "John Doe",
      "profilePic": null,
      "createdAt": "2025-10-29T10:01:29.95Z"
    }
  ]
}
```

---

# Notes

- All API calls include automatic authentication via ApiService
- Data is cached in ViewModels during app session
- Notifications auto-fetch on login (in GreetingScreen)
- Profile pictures display when available, else show initials
- All lists are sorted by date (newest first)
- Form validation prevents invalid submissions
- Success/error feedback provided via SnackBars
- Empty and error states have retry options

---

# Support & Troubleshooting

## Common Issues

### Notifications not loading
- Check authentication token validity
- Verify API endpoint is accessible
- Check for error messages in ViewModel

### Feedback submission fails
- Ensure rating is between 1-5
- Check gymId is valid
- Verify user is not owner of the gym
- Check network connectivity

### UI not updating
- Ensure ViewModel is properly provided
- Check notifyListeners() is called
- Verify Consumer/Provider setup

## Debug Tips
- Use debug prints in ViewModels
- Check API responses in ApiService logs
- Verify model parsing with breakpoints
- Test with different user roles

---

For detailed backend API documentation, refer to the backend repository.
For component-specific details, check the individual feature directories.

