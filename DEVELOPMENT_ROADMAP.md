# Development Roadmap

## Current Phase: Core Game Development ✅

### Completed
- ✅ UI skeleton with all main screens
- ✅ Navigation system
- ✅ Core game logic (3D cube, word validation, scoring)
- ✅ Local data persistence
- ✅ Statistics tracking

### In Progress / Next Steps
- [ ] Polish game mechanics
- [ ] Improve puzzle generation (embed valid words)
- [ ] Add animations and visual feedback
- [ ] Sound effects and haptics
- [ ] Game difficulty levels
- [ ] Tutorial/help system

## Future Phase: Backend Integration (PostgreSQL)

### When to Add Backend
**Decision: Add backend later** - After core game is polished and tested.

**Rationale:**
- Core game logic needs refinement first
- Local storage is sufficient for single-player development
- Backend adds significant complexity (PostgreSQL, server, deployment)
- Faster iteration without backend overhead
- Backend needed for: multiplayer, global leaderboards, cloud sync

### Backend Implementation Plan

#### Phase 1: Database Setup
- [ ] Set up PostgreSQL database
- [ ] Create database schema (see DATABASE.md)
- [ ] Set up connection pooling
- [ ] Database migrations

#### Phase 2: API Development
- [ ] REST API server (Swift/Vapor or Node.js)
- [ ] Authentication endpoints
- [ ] Statistics sync endpoints
- [ ] Leaderboard endpoints
- [ ] Game history endpoints

#### Phase 3: Client Integration
- [ ] Implement BackendService methods
- [ ] Add authentication UI
- [ ] Sync local data to backend
- [ ] Fetch leaderboard from backend
- [ ] Handle offline/online states

#### Phase 4: Advanced Features
- [ ] Multiplayer support
- [ ] Real-time leaderboard updates
- [ ] Push notifications
- [ ] Social features (friends, challenges)

## Current Architecture

### Local Storage (Active)
- **UserDefaults**: Settings, onboarding
- **DataPersistence**: Game statistics, history
- **WordValidator**: Local dictionary

### Backend Service (Ready for Integration)
- **BackendService**: API client structure in place
- **Data Models**: Ready for PostgreSQL mapping
- **Sync Methods**: Placeholder methods ready to implement

## Development Best Practices

1. **Test locally first** - Ensure game works perfectly offline
2. **Iterate quickly** - Focus on gameplay improvements
3. **Add backend when needed** - When multiplayer/leaderboards are required
4. **Keep backend structure** - Already in place for easy integration

## Notes

- Backend service structure is already implemented in `Services/BackendService.swift`
- Database schema is documented in `DATABASE.md`
- Local storage works independently and will sync when backend is ready
- No breaking changes needed when adding backend - it's designed to be additive

