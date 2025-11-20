# Quick Setup Guide

## 1. Install PostgreSQL

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

## 2. Create Database

```bash
createdb wordsearch
```

Or using psql:
```bash
psql postgres
CREATE DATABASE wordsearch;
\q
```

## 3. Configure Environment

Create a `.env` file in the Server directory:

```env
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=
DATABASE_NAME=wordsearch
JWT_SECRET=your-secret-key-change-in-production-min-32-chars
```

**Note:** If you don't have a PostgreSQL password set, leave `DATABASE_PASSWORD` empty.

## 4. Build and Run Server

```bash
cd Server
swift build
swift run App
```

The server will:
- Connect to PostgreSQL
- Run database migrations automatically
- Start on `http://localhost:8080`

## 5. Test the Server

```bash
# Test health (should return 404, but server is running)
curl http://localhost:8080

# Test registration
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"password123"}'
```

## 6. Update iOS App

The iOS app is already configured to use `http://localhost:8080` by default.

For iOS Simulator, `localhost` works fine.
For physical device, use your Mac's IP address:
```swift
self.baseURL = "http://192.168.1.X:8080"  // Your Mac's local IP
```

## Troubleshooting

**Database connection error:**
- Check PostgreSQL is running: `brew services list` or `sudo systemctl status postgresql`
- Verify database exists: `psql -l | grep wordsearch`
- Check credentials in `.env` file

**Port already in use:**
- Change port in `.env`: `DATABASE_PORT=5433`
- Or kill process using port 8080

**Migration errors:**
- Drop and recreate database: `dropdb wordsearch && createdb wordsearch`

## Production Deployment

For production:
1. Use strong JWT_SECRET (32+ characters)
2. Set secure DATABASE_PASSWORD
3. Use environment variables (not .env file)
4. Set up SSL/TLS
5. Use reverse proxy (nginx)
6. Configure firewall rules

