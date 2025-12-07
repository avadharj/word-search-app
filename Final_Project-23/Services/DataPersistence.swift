//
//  DataPersistence.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import Foundation

// MARK: - Data Persistence Service
// This service handles local storage and can be extended to sync with PostgreSQL backend
class DataPersistence {
    static let shared = DataPersistence()
    
    private let userDefaults = UserDefaults.standard
    private let statisticsKey = "gameStatistics"
    private let gameHistoryKey = "gameHistory"
    
    private init() {}
    
    // MARK: - Statistics Persistence
    
    struct GameStatistics: Codable {
        var totalGames: Int = 0
        var totalWords: Int = 0
        var totalScore: Int = 0
        var highScore: Int = 0
        var longestWord: String = ""
        var wordsFound: Set<String> = []
        var lastUpdated: Date = Date()
    }
    
    func loadStatistics() -> GameStatistics {
        guard let data = userDefaults.data(forKey: statisticsKey),
              let stats = try? JSONDecoder().decode(GameStatistics.self, from: data) else {
            return GameStatistics()
        }
        return stats
    }
    
    func saveStatistics(_ statistics: GameStatistics) {
        if let data = try? JSONEncoder().encode(statistics) {
            userDefaults.set(data, forKey: statisticsKey)
        }
    }
    
    func updateStatistics(score: Int, wordsFound: [String]) {
        var stats = loadStatistics()
        stats.totalGames += 1
        stats.totalWords += wordsFound.count
        stats.totalScore += score
        stats.highScore = max(stats.highScore, score)
        
        // Update longest word
        let longest = wordsFound.max(by: { $0.count < $1.count }) ?? ""
        if longest.count > stats.longestWord.count {
            stats.longestWord = longest
        }
        
        // Add new words to found words set
        stats.wordsFound.formUnion(wordsFound)
        stats.lastUpdated = Date()
        
        saveStatistics(stats)
    }
    
    // MARK: - Game History
    
    struct GameRecord: Codable, Identifiable {
        let id: UUID
        let date: Date
        let score: Int
        let wordsFound: Int
        let words: [String]
    }
    
    func saveGameRecord(score: Int, wordsFound: [String]) {
        let record = GameRecord(
            id: UUID(),
            date: Date(),
            score: score,
            wordsFound: wordsFound.count,
            words: wordsFound
        )
        
        var history = loadGameHistory()
        history.append(record)
        
        // Keep only last 100 games
        if history.count > 100 {
            history = Array(history.suffix(100))
        }
        
        if let data = try? JSONEncoder().encode(history) {
            userDefaults.set(data, forKey: gameHistoryKey)
        }
    }
    
    func loadGameHistory() -> [GameRecord] {
        guard let data = userDefaults.data(forKey: gameHistoryKey),
              let history = try? JSONDecoder().decode([GameRecord].self, from: data) else {
            return []
        }
        return history
    }
    
    // MARK: - PostgreSQL Sync Methods
    
    func syncStatisticsToBackend() async throws {
        let stats = loadStatistics()
        try await BackendService.shared.syncStatistics(stats)
    }
    
    func syncGameHistoryToBackend() async throws {
        let history = loadGameHistory()
        try await BackendService.shared.syncGameHistory(history)
    }
    
    func loadLeaderboard() async throws -> [LeaderboardEntry] {
        return try await BackendService.shared.fetchLeaderboard(limit: 100)
    }
}

// MARK: - Leaderboard Models (for future PostgreSQL integration)

struct LeaderboardEntry: Codable, Identifiable {
    let id: UUID
    let playerName: String
    let score: Int
    let wordsFound: Int
    let date: Date
    let rank: Int
}

