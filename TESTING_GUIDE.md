# Testing Guide - Word Search App

This guide will help you set up and test the Word Search iOS app with its backend server. We hope this guide is comprehensive enough for any tester to test the end to end functionality of this app. If any issues are encountered, feel free to mail: 
avadhani.a@northeastern.edu

## 📋 Prerequisites

Before you begin, ensure you have:

- **macOS** (for iOS development)
- **Xcode 15+** (download from App Store or [developer.apple.com](https://developer.apple.com/xcode/))
- **PostgreSQL 12+** (for the database)
- **Swift 5.9+** (comes with Xcode)
- **iOS Simulator** or **Physical iOS Device** (iPhone/iPad)

---

## 🚀 Quick Setup (5 Steps)

### Step 1: Install PostgreSQL

**macOS (using Homebrew):**
```bash
brew install postgresql
brew services start postgresql
```

**Verify it's running:**
```bash
brew services list | grep postgresql
```

### Step 2: Create Database

```bash
createdb wordsearch
```

**Verify database exists:**
```bash
psql -l | grep wordsearch
```

### Step 3: Configure Server

Navigate to the `Server` directory and create a `.env` file:

```bash
cd Server
touch .env
```

Open `.env` and add:
```env
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=
DATABASE_NAME=wordsearch
JWT_SECRET=your-secret-key-minimum-32-characters-long-for-testing
```

**Note:** If you don't have a PostgreSQL password, leave `DATABASE_PASSWORD` empty. If you do have one, add it.

### Step 4: Start the Server

In the `Server` directory:

```bash
swift build
swift run App
```

You should see:
```
[ NOTICE ] Server starting on http://127.0.0.1:8080
```

**Keep this terminal window open!** The server must be running for the iOS app to work.

### Step 5: Open iOS App in Xcode

1. Open `Final_Project-23.xcodeproj` in Xcode
2. Select a simulator (iPhone 15 Pro recommended) or connect a physical device
3. Press `⌘R` (or click Run) to build and run

---

## ✅ Testing All Features

### 1. Multiple Screens & Navigation ✅

**Test:**
- ✅ Home screen appears first (after onboarding)
- ✅ Tap "Daily Challenge" → Navigate to daily challenge screen
- ✅ Tap "Play Game" → Navigate to regular game
- ✅ Tap "Statistics" → View stats
- ✅ Tap "Settings" → View settings
- ✅ Use back button to navigate between screens
- ✅ Onboarding appears on first launch

**Expected:** Smooth navigation between all screens

**New Features:**
- Daily Challenge option appears at the top of the home screen (orange card)
- All navigation paths work correctly

---

### 2. Location Services (Sensor) ✅

**Test:**
1. Go to **Settings** → You'll see "Location Services" section
2. Tap "Enable Location" if not enabled
3. Grant location permission when prompted
4. Go to **Statistics** → You'll see a "Location" section
5. Your location should appear (city, state, country)
6. Coordinates should be displayed

**Expected:**
- Location permission prompt appears
- Location is displayed in Statistics view
- Shows readable location name (e.g., "San Francisco, CA, United States")
- Shows coordinates (latitude, longitude)

**Note:** 
- **Simulator:** Will show "Cupertino, CA, United States" (Apple's default location)
- **Physical Device:** Will show your actual location
- Location updates automatically when you grant permission

---

### 3. User Authentication (Multiple Users) ✅

**Test:**
1. Go to **Settings** → Tap "Sign In"
2. Tap "Register" tab
3. Create a test account:
   - Username: `testuser1`
   - Email: `test1@example.com`
   - Password: `password123`
4. Tap "Register"
5. You should see "Successfully signed in!"
6. Go back to Settings → Should show "Signed In" with green checkmark

**Test Multiple Users:**
1. Sign out (tap "Sign Out" in Settings)
2. Register another user:
   - Username: `testuser2`
   - Email: `test2@example.com`
   - Password: `password123`
3. Both users should be able to sign in/out independently

**Expected:**
- Registration works
- Login works (no "data format" errors)
- Multiple users can be created
- Each user has separate account
- Sign out button works and updates UI immediately
- Authentication state persists between app launches

**Troubleshooting:**
- If you see "Login failed: The data couldn't be read because it isn't in the correct format" → This was fixed, make sure you have the latest code
- If sign out doesn't work → The UI should update immediately after tapping "Sign Out"

---

### 4. Cloud Database ✅

**Test:**
1. Sign in with a user account
2. Play a game (find some words, get a score)
3. End the game
4. Go to **Settings** → Tap "Sync Progress"
5. Go to **Statistics** → Your stats should be visible
6. Check the server terminal → Should see database queries

**Verify in Database:**
```bash
psql wordsearch
```

```sql
-- See all users
SELECT username, email FROM users;

-- See statistics
SELECT username, high_score, total_words FROM game_statistics 
JOIN users ON game_statistics.user_id = users.id;

-- See leaderboard data
SELECT * FROM game_statistics ORDER BY high_score DESC LIMIT 10;
```

**Expected:**
- User data stored in database
- Statistics synced to database
- Game history stored
- Leaderboard data available

---

### 5. Game Features ✅

**Test:**
1. Tap "Play Game" from home
2. **3D Cube:** Should see a 3D cube with letters
3. **Touch Interaction:** Tap letters to form words
4. **Word Validation:** 
   - Form a valid word (3+ letters) → Should be accepted
   - Form invalid word → Should show error
5. **Score:** Score increases when words are found
6. **Letter Removal:** Use a letter 3 times → It disappears
7. **Pause:** Tap pause button → Game pauses
8. **End Game:** Tap "End Game" → See results

**Expected:**
- 3D cube renders correctly
- Touch gestures work (tap, pan, pinch)
- Words are validated
- Score updates
- Letters disappear after 3 uses
- Game state persists

---

### 6. Leaderboard (Multi-User Interaction) ✅

**Important:** The leaderboard requires you to **sync your progress** after playing a game!

**Test:**
1. Sign in with user account
2. Play a game and get a score (find some words, end the game)
3. **Go to Settings → Tap "Sync Progress"** (This is required!)
4. Wait for sync to complete
5. Go to **Statistics** → Scroll to "Leaderboard" section
6. Should see leaderboard with your score

**Test with Multiple Users:**
1. Sign in as `testuser1`
2. Play a game, get a score (e.g., 500)
3. End game
4. **Go to Settings → Tap "Sync Progress"** (Important!)
5. Sign out
6. Sign in as `testuser2`
7. Play a game, get a different score (e.g., 300)
8. End game
9. **Go to Settings → Tap "Sync Progress"** (Important!)
10. View leaderboard → Should see both users ranked by score

**Expected:**
- Leaderboard shows multiple users
- Sorted by high score (highest first)
- Shows username, score, words found, rank
- Updates when new scores are synced
- If empty, shows helpful message: "No leaderboard data yet"

**Troubleshooting:**
- **"No leaderboard data yet"** → Make sure you:
  1. Played a game and got a score
  2. Ended the game (saves locally)
  3. Went to Settings → Tapped "Sync Progress"
  4. Waited for sync to complete
  5. Then checked the leaderboard
- **Empty leaderboard** → Check server terminal for sync requests
- **Error loading leaderboard** → Verify server is running and you're signed in

---

### 7. Daily Challenge Feature ✅

**Test:**
1. From **Home** screen, tap "Daily Challenge" (orange card at top)
2. You should see:
   - Today's date
   - "Start Challenge" button (or "Play Again" if already completed)
   - "View Leaderboard" button
   - Info about daily challenges
3. Tap "Start Challenge"
4. Play the puzzle (same gameplay as regular game)
5. Find words and build your score
6. Tap "End Challenge"
7. View your results
8. Tap "Submit Score" to save to leaderboard
9. Go back and tap "View Leaderboard" to see rankings

**Test Daily Challenge Leaderboard:**
1. Complete a daily challenge and submit score
2. Tap "View Leaderboard" in Daily Challenge view
3. Should see your score and rank
4. If multiple users play, should see all players ranked

**Expected:**
- Daily Challenge screen loads correctly
- Same puzzle for everyone on the same day
- Can play multiple times (shows "Play Again")
- Score tracking works
- Leaderboard shows daily challenge rankings
- New challenge appears each day

**Features:**
- Daily challenges use a date-based seed for consistent puzzles
- Everyone gets the same puzzle on the same day
- Leaderboard resets daily
- Your best score for the day is tracked

---

## 🔧 Troubleshooting

### Server Won't Start

**"Cannot connect to database":**
```bash
# Check PostgreSQL is running
brew services list

# Start if not running
brew services start postgresql

# Verify database exists
psql -l | grep wordsearch
```

**"Port 8080 already in use":**
```bash
# Find what's using port 8080
lsof -i :8080

# Kill the process
kill -9 <PID>
```

**"Migration errors":**
```bash
# Drop and recreate database
dropdb wordsearch
createdb wordsearch
# Then restart server (migrations run automatically)
```

---

### iOS App Can't Connect to Server

**Simulator:**
- ✅ `localhost:8080` should work
- Check server is running in terminal

**Physical Device:**
1. Find your Mac's IP address:
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1
   ```
2. Update `BackendService.swift`:
   ```swift
   self.baseURL = "http://192.168.1.X:8080"  // Your Mac's IP
   ```
3. Make sure Mac and iPhone are on same WiFi network

**"Network error" or "Connection refused":**
- Verify server is running (`swift run App` in Server directory)
- Check firewall isn't blocking port 8080
- For physical device, ensure Mac and device are on same network

---

### Location Services Not Working

**Simulator:**
- Go to **Features → Location** in Simulator menu
- Choose a location (e.g., "Custom Location...")
- Set coordinates manually
- Default shows "Cupertino, CA, United States"

**Physical Device:**
- Go to **Settings → Privacy & Security → Location Services**
- Ensure Location Services is ON
- Check app has permission

**"Location access denied":**
- Go to iOS Settings → Word Search App → Location
- Select "While Using the App"
- Or go to Settings in the app → Location Services section → Tap "Enable Location"

**Location not showing in Statistics:**
- Make sure you granted permission
- Check Settings → Location Services section shows "Enabled"
- Location should appear automatically in Statistics view

---

### Authentication Issues

**"Invalid credentials":**
- Make sure you registered first
- Check username/password are correct
- Verify server is running

**"Username already exists":**
- Try a different username
- Or check database: `psql wordsearch` → `SELECT * FROM users;`

**"Login failed: The data couldn't be read because it isn't in the correct format":**
- This was a date decoding issue that has been fixed
- Make sure you have the latest code with ISO8601 date decoding
- If still seeing this, check server is returning proper JSON

**Sign out not working:**
- The UI should update immediately when you tap "Sign Out"
- If it doesn't, the BackendService is now ObservableObject and should update automatically

---

### Leaderboard Issues

**"No leaderboard data yet":**
- **Most Common Issue:** You need to sync your progress after playing!
  1. Play a game and get a score
  2. End the game
  3. Go to **Settings** → Tap **"Sync Progress"**
  4. Wait for sync to complete
  5. Then check the leaderboard
- Make sure you're signed in (leaderboard requires authentication)
- Verify server is running and receiving sync requests
- Check server terminal for POST requests to `/api/statistics`

**Leaderboard shows empty after syncing:**
- Check server terminal for errors
- Verify database has data:
  ```bash
  psql wordsearch
  SELECT * FROM game_statistics;
  SELECT * FROM users;
  ```
- The leaderboard query joins `game_statistics` with `users`, so both must exist
- Make sure statistics were actually saved (check `high_score` field)

**"Error loading leaderboard":**
- Check server is running
- Verify you're signed in
- Check network connection
- Look at Xcode console for detailed error messages

---

## 📱 Testing Checklist

Use this checklist to verify all requirements:

- [ ] **Multiple Screens:** Can navigate between Home, Daily Challenge, Game, Stats, Settings
- [ ] **Location Services:** Location permission requested and location displayed in Statistics
- [ ] **Cloud Database:** User data stored in PostgreSQL (verify with `psql`)
- [ ] **Authentication:** Can register and login multiple users, sign out works
- [ ] **Multi-User Interaction:** Leaderboard shows multiple users' scores (after syncing!)
- [ ] **Game Play:** 3D cube, word selection, scoring all work
- [ ] **Data Sync:** Statistics sync to backend when signed in (Settings → Sync Progress)
- [ ] **Daily Challenge:** Can access daily challenge, play, and view leaderboard
- [ ] **Daily Challenge Leaderboard:** Shows rankings for today's challenge

---

## 🎯 Quick Test Script

Run through this sequence to test all features:

1. **Start server:** `cd Server && swift run App`
   - Keep terminal open and watch for requests
2. **Open app in Xcode:** Run on simulator (iPhone 15 Pro recommended)
3. **Complete onboarding** (first launch only)
4. **Enable location:**
   - Go to Settings → Location Services section
   - Tap "Enable Location" → Grant permission
5. **Register first user:**
   - Go to Settings → Tap "Sign In"
   - Tap "Register" tab
   - Create account: `testuser1` / `test1@example.com` / `password123`
6. **Test Daily Challenge:**
   - From Home, tap "Daily Challenge"
   - View today's challenge info
   - Tap "Start Challenge"
   - Find 2-3 words
   - Tap "End Challenge"
   - Submit score
7. **Play regular game:**
   - From Home, tap "Play Game"
   - Find 3-5 words in the game
   - Tap "End Game" and view results
8. **Sync progress:**
   - Go to Settings
   - Tap "Sync Progress" (IMPORTANT for leaderboard!)
   - Wait for sync to complete
9. **Check Statistics:**
   - Go to Statistics
   - Verify your stats are shown
   - Check Location section shows your location
   - Scroll to Leaderboard section
   - Should see your score (if synced)
10. **Test multiple users:**
    - Sign out in Settings
    - Register second user: `testuser2` / `test2@example.com` / `password123`
    - Play a game and get a different score
    - End game
    - Go to Settings → Tap "Sync Progress"
    - Check Leaderboard → Should see both users ranked
11. **Test Daily Challenge Leaderboard:**
    - Go to Daily Challenge
    - Tap "View Leaderboard"
    - Should see rankings for today's challenge

---

## 📝 Notes

- **Server must be running** for authentication, cloud features, and leaderboard
- **Location works in simulator** (shows Cupertino) and physical device (real location)
- **Database persists** between app restarts (data stays in PostgreSQL)
- **Multiple users** can use the app simultaneously (different devices or same device)
- **Leaderboard requires sync:** After playing a game, you MUST tap "Sync Progress" in Settings for your score to appear on the leaderboard
- **Daily Challenge:** Same puzzle for everyone on the same day, resets at midnight
- **Authentication:** Sign out now works correctly and updates UI immediately
- **Date handling:** All date formats use ISO8601 for proper server communication

---

## 🆘 Need Help?

If you encounter issues:

1. **Check server terminal** for error messages and API requests
   - You should see POST requests when syncing
   - You should see GET requests when loading leaderboard
2. **Check Xcode console** for iOS app errors
   - Look for error messages in the debug area
   - Check for network errors or decoding errors
3. **Verify PostgreSQL is running:** `brew services list`
4. **Verify database exists:** `psql -l | grep wordsearch`
5. **Check `.env` file** has correct database credentials
6. **Verify database has data:**
   ```bash
   psql wordsearch
   SELECT COUNT(*) FROM users;
   SELECT COUNT(*) FROM game_statistics;
   ```
7. **Check authentication:**
   - Make sure you're signed in to see leaderboard
   - Token should be saved in UserDefaults
8. **For leaderboard issues:**
   - Make sure you played a game AND synced progress
   - Check server received the sync request
   - Verify `game_statistics` table has your data

## 📊 Verifying Data in Database

To verify everything is working, check the database:

```bash
psql wordsearch
```

```sql
-- See all registered users
SELECT id, username, email, created_at FROM users;

-- See all statistics (should have entries after syncing)
SELECT 
    u.username,
    gs.high_score,
    gs.total_words,
    gs.total_games,
    gs.last_updated
FROM game_statistics gs
JOIN users u ON gs.user_id = u.id
ORDER BY gs.high_score DESC;

-- See game history
SELECT * FROM game_history ORDER BY date DESC LIMIT 10;

-- Count records
SELECT 
    (SELECT COUNT(*) FROM users) as user_count,
    (SELECT COUNT(*) FROM game_statistics) as stats_count,
    (SELECT COUNT(*) FROM game_history) as history_count;
```

**Expected Results:**
- After registering: `user_count` should be > 0
- After syncing: `stats_count` should match number of users who synced
- After playing games: `history_count` should show game records

---

## 🎉 Feature Summary

### Core Features
- ✅ Multiple screens with navigation
- ✅ 3D word search game with SceneKit
- ✅ Word validation with dictionary
- ✅ Score tracking and statistics
- ✅ Sound effects and haptic feedback

### Required Features (All Met)
- ✅ **Location Services** (GPS sensor) - Shows in Statistics
- ✅ **Cloud Database** (PostgreSQL via Vapor server)
- ✅ **User Authentication** - Register, login, multiple users
- ✅ **Multi-User Interaction** - Global leaderboard

### Additional Features
- ✅ **Daily Challenge** - Special daily puzzle with leaderboard
- ✅ **Data Persistence** - Local storage with cloud sync
- ✅ **Settings** - Sound, haptics, difficulty, location
- ✅ **Statistics** - Track progress, achievements, location
- ✅ **Onboarding** - First-time user experience

---

**Happy Testing! 🎮**

If you find any issues or have questions, please contact: avadhani.a@northeastern.edu

