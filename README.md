# Word Search App

An iOS word search game played on a vanishing cube. Connect touching letters to form words, the longer the better, and the third time a letter is used its cube is removed, revealing more letters inside!

## 🚀 Quick Start

**New to this project?** Start here:

1. **Read the [TESTING_GUIDE.md](./TESTING_GUIDE.md)** - Complete setup and testing instructions
2. **Set up the server** - See `Server/QUICKSTART.md` for backend setup
3. **Open in Xcode** - Open `Final_Project-23.xcodeproj` and run

## 📋 Requirements Met

✅ **Multiple screens** with navigation  
✅ **Location services** (GPS sensor)  
✅ **Cloud database** (PostgreSQL via Vapor server)  
✅ **User authentication** with multiple users  
✅ **Multi-user interaction** (Leaderboard)

## 🏗️ Project Structure

```
Final_Project-23/
├── Final_Project-23/          # iOS App
│   ├── Views/                 # SwiftUI views
│   ├── Services/              # Business logic
│   ├── Models/                # Data models
│   └── Assets.xcassets/       # Images and assets
├── Server/                    # Backend server (Vapor)
│   ├── Sources/App/           # Server code
│   └── Package.swift          # Swift Package dependencies
└── TESTING_GUIDE.md           # Testing instructions
```

## 🧪 Testing

See **[TESTING_GUIDE.md](./TESTING_GUIDE.md)** for complete testing instructions.

**Quick test:**
1. Start PostgreSQL: `brew services start postgresql`
2. Create database: `createdb wordsearch`
3. Configure server: See `Server/QUICKSTART.md`
4. Run server: `cd Server && swift run App`
5. Open app in Xcode and run

## 📱 Features

- **3D Cube Gameplay** - Interactive 3D word search cube
- **Word Validation** - Real-time dictionary checking
- **User Accounts** - Register, login, sync progress
- **Leaderboard** - Compete with other players
- **Statistics** - Track your progress
- **Location Services** - Location-based features
- **Sound & Haptics** - Immersive gameplay

## 🛠️ Tech Stack

- **iOS:** SwiftUI, SceneKit, CoreLocation
- **Backend:** Vapor (Swift web framework)
- **Database:** PostgreSQL
- **Authentication:** JWT tokens

## 📚 Documentation

- **[TESTING_GUIDE.md](./TESTING_GUIDE.md)** - How to test the app
- **[Server/README.md](./Server/README.md)** - Server documentation
- **[Server/QUICKSTART.md](./Server/QUICKSTART.md)** - Quick server setup

## 📝 License

See LICENSE file for details.
