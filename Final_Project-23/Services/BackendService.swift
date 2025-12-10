//
//  BackendService.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import Foundation

// MARK: - Backend Service
// Handles communication with PostgreSQL backend API

class BackendService: ObservableObject {
    static let shared = BackendService()
    
    // Configure with actual backend URL
    private let baseURL: String
    private let session: URLSession
    @Published private var authToken: AuthToken?
    
    private init() {
        // Set backend URL - defaults to localhost for development
        // For production, set BACKEND_URL environment variable or update here
        self.baseURL = ProcessInfo.processInfo.environment["BACKEND_URL"] ?? "http://localhost:8080"
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        
        // Load token from UserDefaults on initialization
        _ = getAuthToken()
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
        case dailyChallenge = "/api/daily-challenge"
        case dailyChallengeLeaderboard = "/api/daily-challenge/leaderboard"
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
        
        var responseData: Data?
        do {
            let (data, response) = try await session.data(for: request)
            responseData = data
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BackendError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                // Try to decode error message from response
                if let errorData = try? JSONDecoder().decode([String: String].self, from: data),
                   let reason = errorData["reason"] {
                    throw BackendError.serverError(reason)
                }
                
                if httpResponse.statusCode == 401 {
                    throw BackendError.authenticationFailed
                }
                throw BackendError.serverError("Authentication failed with status \(httpResponse.statusCode)")
            }
            
            // Decode AuthResponse from server (includes user field)
            struct ServerAuthResponse: Codable {
                let token: String
                let expiresAt: Date
                let userId: UUID
                let user: UserResponse?
            }
            
            struct UserResponse: Codable {
                let id: UUID
                let username: String
                let email: String
            }
            
            // Configure JSON decoder for ISO8601 dates (Vapor default)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let authResponse = try decoder.decode(ServerAuthResponse.self, from: data)
            let token = AuthToken(
                token: authResponse.token,
                expiresAt: authResponse.expiresAt,
                userId: authResponse.userId
            )
            self.authToken = token
            saveAuthToken(token)
            // Notify observers that authentication state changed
            objectWillChange.send()
            return token
        } catch let decodingError as DecodingError {
            // Better error message for decoding failures
            let errorMessage: String
            switch decodingError {
            case .typeMismatch(let type, let context):
                errorMessage = "Type mismatch: expected \(type), path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            case .valueNotFound(let type, let context):
                errorMessage = "Value not found: \(type), path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            case .keyNotFound(let key, let context):
                errorMessage = "Key not found: \(key.stringValue), path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            case .dataCorrupted(let context):
                errorMessage = "Data corrupted: \(context.debugDescription)"
            @unknown default:
                errorMessage = "Decoding error: \(decodingError.localizedDescription)"
            }
            
            // Log the actual response for debugging
            if let data = responseData, let responseString = String(data: data, encoding: .utf8) {
                print("Server response: \(responseString)")
            }
            
            throw BackendError.serverError("Login failed: \(errorMessage)")
        } catch let urlError as URLError {
            // Handle network errors with better messages
            switch urlError.code {
            case .notConnectedToInternet:
                throw BackendError.networkError
            case .cannotConnectToHost, .timedOut:
                throw BackendError.serverError("Cannot connect to server at \(baseURL). Make sure the server is running.")
            default:
                throw BackendError.serverError("Network error: \(urlError.localizedDescription)")
            }
        } catch let backendError as BackendError {
            throw backendError
        } catch {
            // Log the actual response for debugging
            if let data = responseData, let responseString = String(data: data, encoding: .utf8) {
                print("Server response: \(responseString)")
            }
            throw BackendError.serverError("Login failed: \(error.localizedDescription)")
        }
    }
    
    func registerUser(username: String, email: String, password: String) async throws -> AuthToken {
        let endpoint = "/api/auth/register"  // Match server route
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
        
        var responseData: Data?
        do {
            let (data, response) = try await session.data(for: request)
            responseData = data
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BackendError.invalidResponse
            }
            
            // Accept both 200 (OK) and 201 (Created) as success
            guard (200...299).contains(httpResponse.statusCode) else {
                // Try to decode error message from response
                if let errorData = try? JSONDecoder().decode([String: String].self, from: data),
                   let reason = errorData["reason"] {
                    throw BackendError.serverError(reason)
                }
                
                if httpResponse.statusCode == 409 {
                    throw BackendError.serverError("Username or email already exists")
                }
                throw BackendError.serverError("Registration failed with status \(httpResponse.statusCode)")
            }
            
            // Decode AuthResponse from server (includes user field)
            struct ServerAuthResponse: Codable {
                let token: String
                let expiresAt: Date
                let userId: UUID
                let user: UserResponse?
            }
            
            struct UserResponse: Codable {
                let id: UUID
                let username: String
                let email: String
            }
            
            // Configure JSON decoder for ISO8601 dates (Vapor default)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let authResponse = try decoder.decode(ServerAuthResponse.self, from: data)
            let token = AuthToken(
                token: authResponse.token,
                expiresAt: authResponse.expiresAt,
                userId: authResponse.userId
            )
            self.authToken = token
            saveAuthToken(token)
            // Notify observers that authentication state changed
            objectWillChange.send()
            return token
        } catch let decodingError as DecodingError {
            // Better error message for decoding failures
            let errorMessage: String
            switch decodingError {
            case .typeMismatch(let type, let context):
                errorMessage = "Type mismatch: expected \(type), path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            case .valueNotFound(let type, let context):
                errorMessage = "Value not found: \(type), path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            case .keyNotFound(let key, let context):
                errorMessage = "Key not found: \(key.stringValue), path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            case .dataCorrupted(let context):
                errorMessage = "Data corrupted: \(context.debugDescription)"
            @unknown default:
                errorMessage = "Decoding error: \(decodingError.localizedDescription)"
            }
            
            // Log the actual response for debugging
            if let data = responseData, let responseString = String(data: data, encoding: .utf8) {
                print("Server response: \(responseString)")
            }
            
            throw BackendError.serverError("Registration failed: \(errorMessage)")
        } catch let urlError as URLError {
            // Handle network errors with better messages
            switch urlError.code {
            case .notConnectedToInternet:
                throw BackendError.networkError
            case .cannotConnectToHost, .timedOut:
                throw BackendError.serverError("Cannot connect to server at \(baseURL). Make sure the server is running.")
            default:
                throw BackendError.serverError("Network error: \(urlError.localizedDescription)")
            }
        } catch let backendError as BackendError {
            throw backendError
        } catch {
            // Log the actual response for debugging
            if let data = responseData, let responseString = String(data: data, encoding: .utf8) {
                print("Server response: \(responseString)")
            }
            throw BackendError.serverError("Registration failed: \(error.localizedDescription)")
        }
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
        
        // Configure JSON decoder for ISO8601 dates (Vapor default)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let serverEntries = try decoder.decode([ServerLeaderboardEntry].self, from: data)
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
        } catch let decodingError as DecodingError {
            // Better error message for decoding failures
            let errorMessage: String
            switch decodingError {
            case .typeMismatch(let type, let context):
                errorMessage = "Type mismatch: expected \(type), path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            case .valueNotFound(let type, let context):
                errorMessage = "Value not found: \(type), path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            case .keyNotFound(let key, let context):
                errorMessage = "Key not found: \(key.stringValue), path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            case .dataCorrupted(let context):
                errorMessage = "Data corrupted: \(context.debugDescription)"
            @unknown default:
                errorMessage = "Decoding error: \(decodingError.localizedDescription)"
            }
            
            // Log the actual response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Leaderboard server response: \(responseString)")
            }
            
            throw BackendError.serverError("Failed to decode leaderboard: \(errorMessage)")
        } catch {
            // Log the actual response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Leaderboard server response: \(responseString)")
            }
            throw BackendError.serverError("Failed to fetch leaderboard: \(error.localizedDescription)")
        }
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
        // Return cached token if available
        if let token = authToken, token.expiresAt > Date() {
            return token
        }
        
        // Try to load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "authToken"),
           let token = try? JSONDecoder().decode(AuthToken.self, from: data) {
            // Check if token is expired
            if token.expiresAt > Date() {
                authToken = token // Update cached token
                return token
            } else {
                // Token expired, remove it
                UserDefaults.standard.removeObject(forKey: "authToken")
            }
        }
        return nil
    }
    
    func logout() {
        authToken = nil
        UserDefaults.standard.removeObject(forKey: "authToken")
        // Notify observers that authentication state changed
        objectWillChange.send()
    }
    
    var isAuthenticated: Bool {
        return authToken != nil || getAuthToken() != nil
    }
    
    // MARK: - Daily Challenge
    
    func submitDailyChallengeResult(challengeId: String, score: Int, wordsFound: Int) async throws {
        guard let token = getAuthToken() else {
            throw BackendError.authenticationFailed
        }
        
        let endpoint = APIEndpoint.dailyChallenge.rawValue
        let url = URL(string: "\(baseURL)\(endpoint)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token.token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "challengeId": challengeId,
            "score": score,
            "wordsFound": wordsFound
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw BackendError.serverError("Failed to submit daily challenge result with status \(httpResponse.statusCode)")
        }
    }
    
    func fetchDailyChallengeLeaderboard(challengeId: String, limit: Int = 100) async throws -> [DailyChallengeLeaderboardEntry] {
        let endpoint = APIEndpoint.dailyChallengeLeaderboard.rawValue
        var components = URLComponents(string: "\(baseURL)\(endpoint)")!
        components.queryItems = [
            URLQueryItem(name: "challengeId", value: challengeId),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
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
            throw BackendError.serverError("Failed to fetch daily challenge leaderboard with status \(httpResponse.statusCode)")
        }
        
        // Decode server response
        struct ServerDailyChallengeEntry: Codable {
            let id: UUID
            let playerName: String
            let score: Int
            let wordsFound: Int
            let date: Date
            let rank: Int
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let serverEntries = try decoder.decode([ServerDailyChallengeEntry].self, from: data)
        let leaderboard = serverEntries.map { entry in
            DailyChallengeLeaderboardEntry(
                id: entry.id,
                playerName: entry.playerName,
                score: entry.score,
                wordsFound: entry.wordsFound,
                rank: entry.rank
            )
        }
        return leaderboard
    }
}

// MARK: - Backend Errors

enum BackendError: Error, LocalizedError {
    case notImplemented
    case networkError
    case invalidResponse
    case authenticationFailed
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "This feature is not yet implemented"
        case .networkError:
            return "No internet connection. Please check your network settings."
        case .invalidResponse:
            return "Invalid response from server"
        case .authenticationFailed:
            return "Invalid username or password"
        case .serverError(let message):
            return message
        }
    }
}

// MARK: - Auth Token

struct AuthToken: Codable {
    let token: String
    let expiresAt: Date
    let userId: UUID
}

