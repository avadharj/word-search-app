# Database Architecture

## Overview

This project follows the isowords architecture pattern with a hybrid storage approach:

1. **Local Storage (iOS Client)**: UserDefaults/CoreData for offline game state
2. **PostgreSQL Backend (Server)**: For multiplayer, leaderboards, and cloud sync

## Current Implementation

### Local Storage (Implemented)

- **UserDefaults**: Settings, onboarding state
- **DataPersistence Service**: Game statistics, game history
- **Statistics**: Total games, words found, high scores, longest words
- **Game History**: Last 100 games stored locally

### PostgreSQL Backend (Planned)

The backend service is structured to support PostgreSQL integration:

- **BackendService**: API client for backend communication
- **Data Models**: Ready for PostgreSQL schema mapping
- **Sync Methods**: Placeholder methods for cloud synchronization

## Database Schema (PostgreSQL)

When implementing the backend, the PostgreSQL schema should include:

### Tables

```sql
-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Game Statistics table
CREATE TABLE game_statistics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    total_games INTEGER DEFAULT 0,
    total_words INTEGER DEFAULT 0,
    total_score BIGINT DEFAULT 0,
    high_score INTEGER DEFAULT 0,
    longest_word VARCHAR(255),
    last_updated TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Game History table
CREATE TABLE game_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    score INTEGER NOT NULL,
    words_found INTEGER NOT NULL,
    words TEXT[] NOT NULL,
    played_at TIMESTAMP DEFAULT NOW()
);

-- Leaderboard table (materialized view or computed)
CREATE TABLE leaderboard (
    user_id UUID REFERENCES users(id),
    username VARCHAR(255),
    high_score INTEGER,
    total_words INTEGER,
    rank INTEGER,
    last_updated TIMESTAMP
);

-- Indexes
CREATE INDEX idx_game_history_user_id ON game_history(user_id);
CREATE INDEX idx_game_history_played_at ON game_history(played_at DESC);
CREATE INDEX idx_leaderboard_high_score ON leaderboard(high_score DESC);
```

## Implementation Plan

### Phase 1: Local Storage (Current)
- ✅ UserDefaults for settings
- ✅ DataPersistence service for statistics
- ✅ Local game history

### Phase 2: Backend API (Next)
- [ ] Set up PostgreSQL database
- [ ] Implement REST API endpoints
- [ ] Add authentication
- [ ] Sync statistics to backend
- [ ] Fetch leaderboard from backend

### Phase 3: Real-time Features (Future)
- [ ] WebSocket support for multiplayer
- [ ] Real-time leaderboard updates
- [ ] Push notifications

## Usage

### Local Storage

```swift
// Save statistics after game
DataPersistence.shared.updateStatistics(score: 1000, wordsFound: ["CAT", "DOG"])

// Load statistics
let stats = DataPersistence.shared.loadStatistics()

// Save game record
DataPersistence.shared.saveGameRecord(score: 1000, wordsFound: ["CAT", "DOG"])
```

### Backend Sync (When Ready)

```swift
// Sync statistics to PostgreSQL
try await BackendService.shared.syncStatistics(statistics)

// Fetch leaderboard
let leaderboard = try await BackendService.shared.fetchLeaderboard(limit: 100)
```

## Notes

- The current implementation uses local storage only
- Backend service methods are placeholders ready for PostgreSQL integration
- Statistics are automatically saved after each game
- Leaderboard sync will be implemented when backend is ready

