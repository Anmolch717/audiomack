# AudioMack - Flutter Music Player App

A modern, feature-rich music player application built with Flutter, offering a premium music streaming experience with a beautiful dark UI.

## Detailed App Overview

### Authentication Screens

#### Login Screen
- **Purpose**: Secure user authentication and access control
- **Features**:
  - Email and password input fields with validation
  - "Remember Me" option for persistent login
  - Password visibility toggle
  - Error handling for invalid credentials
  - Link to registration for new users
  - Dark theme with gradient background
  - Loading indicators during authentication
  - Secure password storage using encryption

#### Registration Screen
- **Purpose**: New user account creation
- **Features**:
  - Username, email, and password fields
  - Password strength indicator
  - Email format validation
  - Username availability check
  - Terms and conditions acceptance
  - Profile picture upload option
  - Success confirmation and auto-login
  - Error handling for existing accounts

### Main App Screens

#### Home Screen
- **Purpose**: Central hub for music navigation and playback
- **Layout**:
  - Bottom navigation bar with three tabs
  - Persistent mini player
  - App bar with premium and admin controls
- **Features**:
  - **Library Tab**:
    - Grid/List view toggle
    - Sort options (Recently Added, Alphabetical, Most Played)
    - Filter by genre/artist
    - Premium content indicators
    - Quick play buttons
    - Album cover thumbnails
  - **Search Tab**:
    - Real-time search with debouncing
    - Search history
    - Voice search option
    - Advanced filters
    - Search suggestions
  - **Profile Tab**:
    - User information display
    - Premium status badge
    - Favorite songs list
    - Playback history
    - Settings access
    - Logout option

#### Mini Player
- **Purpose**: Quick access to current playback
- **Features**:
  - Album art thumbnail
  - Song title and artist
  - Progress bar with seek functionality
  - Play/pause toggle
  - Next track button
  - Expand to full player
  - Background blur effect
  - Gesture controls (swipe to dismiss)

#### Full Player Screen
- **Purpose**: Complete music playback control
- **Features**:
  - Large album art with spin animation
  - Detailed song information
  - Progress bar with time display
  - Playback controls (play/pause, next/previous)
  - Shuffle and repeat modes
  - Volume control
  - Favorite/unfavorite button
  - Share option
  - Queue management
  - Lyrics display (if available)
  - Background gradient based on album art

#### Premium Screen
- **Purpose**: Premium subscription management
- **Features**:
  - Current subscription status
  - Premium benefits list
  - Feature comparison
  - Subscription plans
  - Payment integration
  - Trial period option
  - Restore purchases
  - Terms and conditions
  - FAQ section

#### Admin Screen
- **Purpose**: Application management and monitoring
- **Features**:
  - **User Management**:
    - User list with search
    - Role assignment
    - Premium status control
    - Account suspension
    - User activity logs
  - **Content Management**:
    - Song upload interface
    - Metadata editing
    - Premium content marking
    - Content moderation
    - Analytics dashboard
  - **System Management**:
    - Data backup/restore
    - Cache clearing
    - System logs
    - Performance metrics

#### Upload Screen
- **Purpose**: Content addition to the platform
- **Features**:
  - **Audio Upload**:
    - Multiple file selection
    - Format validation
    - Progress tracking
    - Background upload
    - Error handling
  - **Metadata Management**:
    - Title and artist input
    - Album selection
    - Genre tagging
    - Release date
    - Premium content marking
  - **Cover Art**:
    - Image picker
    - Crop and resize
    - Format conversion
    - Preview
  - **Advanced Options**:
    - Privacy settings
    - Distribution control
    - Rights management

### Core Features in Detail

#### 1. Authentication System
- **Implementation**:
  - Secure password hashing
  - JWT token management
  - Session persistence
  - Auto-logout on security breach
  - Password reset functionality
  - Email verification
  - Social login integration (future)

#### 2. Music Playback
- **Audio Engine**:
  - Just Audio implementation
  - Multiple format support
  - Streaming optimization
  - Buffer management
  - Error recovery
  - Background playback
  - Audio session handling
- **Playback Features**:
  - Gapless playback
  - Crossfade between tracks
  - Playback speed control
  - Sleep timer
  - Equalizer (future)
  - Audio effects (future)

#### 3. File Management
- **Storage System**:
  - Local file caching
  - Cloud storage integration
  - Automatic cleanup
  - Storage optimization
  - File format conversion
  - Metadata extraction
- **Permission Handling**:
  - Android 13+ storage access
  - iOS privacy permissions
  - Permission request UI
  - Fallback mechanisms
  - Error handling

#### 4. Premium Features
- **Subscription System**:
  - In-app purchases
  - Subscription management
  - Trial period handling
  - Payment processing
  - Receipt validation
  - Restore purchases
- **Premium Content**:
  - DRM protection
  - Offline access
  - High-quality streaming
  - Exclusive content
  - Early access

#### 5. User Experience
- **UI Components**:
  - Material Design 3
  - Custom animations
  - Responsive layouts
  - Dark theme
  - Accessibility support
  - RTL support
- **Performance**:
  - Lazy loading
  - Image caching
  - Memory management
  - Battery optimization
  - Network optimization

### Technical Implementation

#### 1. State Management
- **Provider Pattern**:
  - User state
  - Playback state
  - UI state
  - Cache state
  - Network state
- **Data Flow**:
  - Unidirectional data flow
  - State persistence
  - State restoration
  - Error handling

#### 2. Data Persistence
- **Storage Solutions**:
  - JSON file storage
  - SQLite database
  - Shared preferences
  - Secure storage
  - Cloud sync
- **Data Models**:
  - User model
  - Song model
  - Playlist model
  - Settings model

#### 3. Security
- **Implementation**:
  - Data encryption
  - Secure storage
  - Network security
  - Input validation
  - Error handling
  - Logging system

### Future Roadmap

#### 1. Social Features
- User profiles
- Playlist sharing
- Social media integration
- Comments and ratings
- Artist following

#### 2. Advanced Audio
- Custom equalizer
- Audio effects
- Crossfade settings
- Audio visualization
- High-resolution audio

#### 3. Offline Mode
- Download management
- Offline library
- Background sync
- Storage management
- Download quality options

#### 4. Analytics
- User behavior tracking
- Playback statistics
- Performance metrics
- Error reporting
- Usage analytics

#### 5. Cloud Integration
- Cloud backup
- Cross-device sync
- Remote control
- Cloud storage
- API integration

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Dependencies

- `just_audio`: Audio playback
- `file_picker`: File selection
- `permission_handler`: Permission management
- `path_provider`: File system access
- `provider`: State management
- `json_annotation`: JSON serialization
- `shared_preferences`: Local storage

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
