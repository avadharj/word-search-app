//
//  BackendService.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import Foundation

// MARK: - Backend Service
// This service will handle communication with the PostgreSQL backend
// For now, it's a placeholder that can be extended when backend is ready

class BackendService {
    static let shared = BackendService()
    
    // TODO: Configure with actual backend URL
    private let baseURL = "https://api.example.com" // Replace with actual backend URL
    
    private init() {}
    
    // MARK: - API Endpoints (to be implemented)
    
    enum APIEndpoint: String {
        case statistics = "/api/statistics"
        case leaderboard = "/api/leaderboard"
        case gameHistory = "/api/game-history"
        case sync = "/api/sync"
    }
    
    // MARK: - Statistics Sync
    
    func syncStatistics(_ statistics: DataPersistence.GameStatistics) async throws {
        // TODO: Implement POST request to PostgreSQL backend
        // POST /api/statistics
        // Body: { totalGames, totalWords, totalScore, highScore, longestWord }
    }
    
    // MARK: - Leaderboard
    
    func fetchLeaderboard(limit: Int = 100) async throws -> [LeaderboardEntry] {
        // TODO: Implement GET request to PostgreSQL backend
        // GET /api/leaderboard?limit=100
        // Returns: [LeaderboardEntry]
        return []
    }
    
    // MARK: - Game History Sync
    
    func syncGameHistory(_ records: [DataPersistence.GameRecord]) async throws {
        // TODO: Implement POST request to PostgreSQL backend
        // POST /api/game-history
        // Body: [GameRecord]
    }
    
    // MARK: - User Authentication (for future)
    
    func authenticate(username: String, password: String) async throws -> AuthToken {
        // TODO: Implement authentication with PostgreSQL backend
        throw BackendError.notImplemented
    }
    
    func registerUser(username: String, email: String, password: String) async throws -> AuthToken {
        // TODO: Implement user registration with PostgreSQL backend
        throw BackendError.notImplemented
    }
}

// MARK: - Backend Errors

enum BackendError: Error {
    case notImplemented
    case networkError
    case invalidResponse
    case authenticationFailed
    case serverError(String)
}

// MARK: - Auth Token

struct AuthToken: Codable {
    let token: String
    let expiresAt: Date
    let userId: UUID
}

