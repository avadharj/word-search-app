# Quick Start Guide

## Prerequisites

1. **Install PostgreSQL:**
   ```bash
   brew install postgresql
   brew services start postgresql
   ```

2. **Create Database:**
   ```bash
   createdb wordsearch
   ```

3. **Install Swift 5.9+** (usually comes with Xcode)

## Setup

1. **Create `.env` file in Server directory:**
   ```env
   DATABASE_HOST=localhost
   DATABASE_PORT=5432
   DATABASE_USERNAME=postgres
   DATABASE_PASSWORD=
   DATABASE_NAME=wordsearch
   JWT_SECRET=your-secret-key-minimum-32-characters-long-for-production
   ```

2. **Build and run:**
   ```bash
   cd Server
   swift build
   swift run App
   ```

Server will start on `http://localhost:8080`

## Test It

```bash
# Register a user
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@test.com","password":"password123"}'

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"password123"}'
```

## iOS App Connection

The iOS app is already configured to use `http://localhost:8080`.

- **Simulator**: Works with `localhost`
- **Physical Device**: Use your Mac's IP: `http://192.168.1.X:8080`

Update in `BackendService.swift` if needed.

## Troubleshooting

**"Cannot connect to database":**
- Check PostgreSQL is running: `brew services list`
- Verify database exists: `psql -l | grep wordsearch`

**"Port 8080 already in use":**
- Kill the process or change port in code

**Migration errors:**
- Drop and recreate: `dropdb wordsearch && createdb wordsearch`

