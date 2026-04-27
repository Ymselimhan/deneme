# System Patterns

## Architecture
- **Client**: Flutter Mobile App (iOS/Android).
- **Server**: Node.js (Express) API Server.
- **Communication Layer**:
    - REST API for static data.
    - Socket.io for real-time bi-directional communication.
- **Containerization**: Docker for backend and database services.

## Key Technical Decisions
- **Background Location**: Implementation of background services in Flutter to update location even when the app is closed.
- **WebSocket Protocol**: Using a standard WebSocket or Socket.io for bi-directional communication.
- **Self-Hosting Strategy**: Using Docker/Docker-compose for easy deployment on the user's server.
- **Real-time Logging**: Intercepting `console.log` on the server and streaming via Socket.io for dashboard monitoring.

## Design Patterns
- **Provider or BLoC**: For state management in the Flutter app.
- **Service Pattern**: Separating API logic (AuthService, SocketService) from UI.
- **Repository Pattern**: Abstracting data sources.

## Data Models (Backend)
- **User**: username, email, password, coupleId, lastLat, lastLng.
- **Couple**: name, anniversaryDate, inviteCode.
- **Message**: text, senderId, coupleId.
- **Song**: title, artist, url, coupleId, addedBy.
- **Memory**: title, imageUrl, coupleId, addedBy.

## Critical Implementation Paths
1. Flutter App & Node.js Backend Setup (DONE).
2. Auth & Partner Linking (DONE).
3. Real-time Messaging & History (DONE).
4. Shared Music List (DONE).
5. Location Tracking (OSM) (DONE).
6. Shared Photo Gallery (DONE).
