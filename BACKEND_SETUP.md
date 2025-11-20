# Backend Setup Guide

## Current Status

**What we have:**
- ✅ iOS client code that makes API calls to a backend
- ✅ BackendService with all API endpoints defined
- ✅ Database schema documentation (see `DATABASE.md`)

**What's missing:**
- ❌ PostgreSQL database (not installed/running)
- ❌ Backend server/API (not created)
- ❌ Connection between server and database

## What You Need to Do

### Option 1: Quick Start (Recommended for Development)

**Use a Backend-as-a-Service (BaaS):**
- **Supabase** (PostgreSQL + API): https://supabase.com
- **Firebase** (NoSQL, but can work): https://firebase.google.com
- **Railway** (PostgreSQL + deploy): https://railway.app
- **Render** (PostgreSQL + API): https://render.com

These services provide:
- PostgreSQL database ready to use
- REST API endpoints
- Authentication
- No server code needed initially

### Option 2: Build Your Own Backend Server

You need to create a backend server that:
1. Connects to PostgreSQL
2. Implements the API endpoints
3. Handles authentication
4. Stores/retrieves data

**Technology Options:**
- **Swift/Vapor** (matches isowords): https://vapor.codes
- **Node.js/Express** (popular, easy)
- **Python/Flask** (simple)
- **Go/Gin** (fast)

### Option 3: Local Development Setup

For local testing, you can:

1. **Install PostgreSQL locally:**
   ```bash
   # macOS
   brew install postgresql
   brew services start postgresql
   
   # Create database
   createdb wordsearch
   ```

2. **Create tables** (use schema from `DATABASE.md`)

3. **Set up a simple API server** (Node.js example):
   ```bash
   npm init -y
   npm install express pg bcrypt jsonwebtoken
   ```

4. **Update BackendService URL:**
   ```swift
   // In BackendService.swift
   self.baseURL = "http://localhost:8080"  // Your local server
   ```

## Quick Setup with Supabase (Easiest)

1. **Sign up at https://supabase.com**
2. **Create a new project**
3. **Get your API URL and keys**
4. **Create tables** using the SQL from `DATABASE.md`
5. **Update BackendService.swift:**
   ```swift
   self.baseURL = "https://your-project.supabase.co"
   // Add Supabase API key to headers
   ```

## What the Backend Needs to Implement

The backend must provide these endpoints (see `BackendService.swift`):

- `POST /api/auth` - User login
- `POST /api/register` - User registration  
- `POST /api/statistics` - Sync statistics (auth required)
- `GET /api/leaderboard?limit=100` - Get leaderboard
- `POST /api/game-history` - Sync game history (auth required)
- `GET /api/dictionary` - Get dictionary file

## Current App Behavior

**Without backend:**
- ✅ App works fully offline
- ✅ Local statistics saved
- ✅ Game history stored locally
- ❌ No authentication
- ❌ No leaderboard
- ❌ No cloud sync

**With backend:**
- ✅ All above features
- ✅ User accounts
- ✅ Global leaderboard
- ✅ Cloud sync across devices
- ✅ Multiplayer features (future)

## Next Steps

1. **For now:** App works perfectly without backend (all local)
2. **When ready:** Choose Option 1, 2, or 3 above
3. **Update BackendService.swift** with your backend URL
4. **Test authentication** and sync features

## Testing Without Backend

The app is designed to work offline. You can:
- Play games
- Track statistics locally
- View local game history
- All features work except leaderboard and cloud sync

Backend is **optional** for core gameplay!

