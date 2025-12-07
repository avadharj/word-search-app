//
//  BackendService.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import Foundation

// MARK: - Backend Service
// Handles communication with PostgreSQL backend API

class BackendService {
    static let shared = BackendService()
    
    // Configure with actual backend URL
    private let baseURL: String
    private let session: URLSession
    private var authToken: AuthToken?
    
    private init() {
        // Set backend URL - defaults to localhost for development
        // For production, set BACKEND_URL environment variable or update here
        self.baseURL = ProcessInfo.processInfo.environment["BACKEND_URL"] ?? "http://localhost:8080"
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - API Endpoints
    
    enum APIEndpoint: String {
        case statistics = "/api/statistics"
        case leaderboard = "/api/leaderboard"
        case gameHistory = "/api/game-history"
        case sync = "/api/sync"
        case auth = "/api/auth"
        case register = "/api/register"
        case dictionary = "/api/dictionary"
    }
    
    // MARK: - Authentication
    
    func authenticate(username: String, password: String) async throws -> AuthToken {
        let endpoint = "/api/auth/login"  // Updated to match server route
        let url = URL(string: "\(baseURL)\(endpoint)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "username": username,
            "password": password
        ]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw BackendError.authenticationFailed
            }
            throw BackendError.serverError("Authentication failed with status \(httpResponse.statusCode)")
        }
        
        let token = try JSONDecoder().decode(AuthToken.self, from: data)
        self.authToken = token
        saveAuthToken(token)
        return token
    }
    
    func registerUser(username: String, email: String, password: String) async throws -> AuthToken {
        let endpoint = APIEndpoint.register.rawValue
        let url = URL(string: "\(baseURL)\(endpoint)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "username": username,
            "email": email,
            "password": password
        ]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendError.invalidResponse
        }
        
        guard httpResponse.statusCode == 201 else {
            if httpResponse.statusCode == 409 {
                throw BackendError.serverError("Username or email already exists")
            }
            throw BackendError.serverError("Registration failed with status \(httpResponse.statusCode)")
        }
        
        let token = try JSONDecoder().decode(AuthToken.self, from: data)
        self.authToken = token
        saveAuthToken(token)
        return token
    }
    
    // MARK: - Statistics Sync
    
    func syncStatistics(_ statistics: DataPersistence.GameStatistics) async throws {
        guard let token = getAuthToken() else {
            throw BackendError.authenticationFailed
        }
        
        let endpoint = APIEndpoint.statistics.rawValue
        let url = URL(string: "\(baseURL)\(endpoint)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token.token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "totalGames": statistics.totalGames,
            "totalWords": statistics.totalWords,
            "totalScore": statistics.totalScore,
            "highScore": statistics.highScore,
            "longestWord": statistics.longestWord
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw BackendError.serverError("Sync failed with status \(httpResponse.statusCode)")
        }
    }
    
    // MARK: - Leaderboard
    
    func fetchLeaderboard(limit: Int = 100) async throws -> [LeaderboardEntry] {
        let endpoint = APIEndpoint.leaderboard.rawValue
        var components = URLComponents(string: "\(baseURL)\(endpoint)")!
        components.queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        
        guard let url = components.url else {
            throw BackendError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Optional: Add auth token if available
        if let token = getAuthToken() {
            request.setValue("Bearer \(token.token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw BackendError.serverError("Failed to fetch leaderboard with status \(httpResponse.statusCode)")
        }
        
        // Decode server response format
        struct ServerLeaderboardEntry: Codable {
            let id: UUID
            let playerName: String
            let score: Int
            let wordsFound: Int
            let date: Date
            let rank: Int
        }
        
        let serverEntries = try JSONDecoder().decode([ServerLeaderboardEntry].self, from: data)
        let leaderboard = serverEntries.map { entry in
            LeaderboardEntry(
                id: entry.id,
                playerName: entry.playerName,
                score: entry.score,
                wordsFound: entry.wordsFound,
                date: entry.date,
                rank: entry.rank
            )
        }
        return leaderboard
    }
    
    // MARK: - Game History Sync
    
    func syncGameHistory(_ records: [DataPersistence.GameRecord]) async throws {
        guard let token = getAuthToken() else {
            throw BackendError.authenticationFailed
        }
        
        let endpoint = APIEndpoint.gameHistory.rawValue
        let url = URL(string: "\(baseURL)\(endpoint)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token.token)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try JSONEncoder().encode(records)
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw BackendError.serverError("Sync failed with status \(httpResponse.statusCode)")
        }
    }
    
    // MARK: - Dictionary Sync
    
    func fetchDictionary() async throws -> String {
        let endpoint = APIEndpoint.dictionary.rawValue
        let url = URL(string: "\(baseURL)\(endpoint)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw BackendError.serverError("Failed to fetch dictionary with status \(httpResponse.statusCode)")
        }
        
        guard let dictionaryText = String(data: data, encoding: .utf8) else {
            throw BackendError.invalidResponse
        }
        
        return dictionaryText
    }
    
    // MARK: - Auth Token Management
    
    private func saveAuthToken(_ token: AuthToken) {
        if let data = try? JSONEncoder().encode(token) {
            UserDefaults.standard.set(data, forKey: "authToken")
        }
    }
    
    private func getAuthToken() -> AuthToken? {
        if let data = UserDefaults.standard.data(forKey: "authToken"),
           let token = try? JSONDecoder().decode(AuthToken.self, from: data) {
            // Check if token is expired
            if token.expiresAt > Date() {
                return token
            }
        }
        return nil
    }
    
    func logout() {
        authToken = nil
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
    
    var isAuthenticated: Bool {
        return getAuthToken() != nil
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

