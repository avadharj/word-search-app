# Word Search Server

Vapor-based backend server for the Word Search iOS app.

## Prerequisites

- Swift 5.9+
- PostgreSQL 12+
- macOS or Linux

## Setup

### 1. Install PostgreSQL

**macOS:**
```bash
brew install postgresql
brew services start postgresql
```

**Linux:**
```bash
sudo apt-get install postgresql postgresql-contrib
sudo systemctl start postgresql
```

### 2. Create Database

```bash
createdb wordsearch
```

Or using psql:
```sql
CREATE DATABASE wordsearch;
```

### 3. Configure Environment

Create a `.env` file in the Server directory:

```env
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=your_password
DATABASE_NAME=wordsearch
JWT_SECRET=your-secret-key-change-in-production
```

### 4. Build and Run

```bash
cd Server
swift build
swift run App
```

The server will run on `http://localhost:8080`

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

### Statistics (Requires Auth)
- `POST /api/statistics` - Sync statistics
- `GET /api/statistics` - Get user statistics

### Leaderboard
- `GET /api/leaderboard?limit=100` - Get leaderboard

### Game History (Requires Auth)
- `POST /api/game-history` - Sync game history
- `GET /api/game-history?limit=100` - Get user game history

### Dictionary
- `GET /api/dictionary` - Get dictionary file

## iOS App Configuration

Update `BackendService.swift` in the iOS app:

```swift
self.baseURL = "http://localhost:8080"  // For local development
// Or
self.baseURL = "https://your-server.com"  // For production
```

## Production Deployment

For production, consider:
- Use environment variables for secrets
- Set up SSL/TLS
- Use a process manager (PM2, systemd)
- Configure reverse proxy (nginx)
- Set up database backups

## Testing

```bash
swift test
```

## Notes

- The server automatically runs migrations on startup
- JWT tokens expire after 7 days
- CORS is enabled for iOS app access
- Password hashing uses Bcrypt

