# Tech Context

## Technologies Used
- **Frontend**: Flutter (Dart) for iOS and Android.
- **Backend**: Node.js 24 (Express & Socket.io) - Self-hostable.
- **Database**: PostgreSQL 18 (Alpine) - Using version-specific cluster management.
- **Communication**: WebSockets (Socket.io) for real-time chat, location, and system logs.
- **Infrastructure**: Docker & Docker-compose for containerization.
- **Hosting**: User's own server.

## Development Setup
- Flutter SDK (User side).
- Node.js & npm (Backend).
- Docker for local backend testing and deployment.
- IDE: VS Code.

## Technical Constraints
- Cross-platform compatibility.
- Real-time performance for messaging and location.
- Privacy-focused data handling.
- Efficient battery usage for background location tracking.

## Dependencies
- **Backend**: express, socket.io, sequelize, pg, bcryptjs, jsonwebtoken, dotenv, cors, multer.
- **Mobile**: flutter, cupertino_icons, socket_io_client, flutter_map, geolocator, http, provider, shared_preferences, image_picker.
