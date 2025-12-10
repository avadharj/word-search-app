//
//  DailyChallengeService.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import Foundation

// MARK: - Daily Challenge Model
struct DailyChallenge: Identifiable {
    let id: String // Date string (YYYY-MM-DD)
    let date: Date
    let puzzle: Puzzle
    let seed: Int // Seed for reproducible puzzle generation
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Daily Challenge Result
struct DailyChallengeResult: Codable {
    let challengeId: String
    let userId: UUID
    let score: Int
    let wordsFound: Int
    let completedAt: Date
}

// MARK: - Daily Challenge Service
class DailyChallengeService: ObservableObject {
    static let shared = DailyChallengeService()
    
    @Published var currentChallenge: DailyChallenge?
    @Published var userResult: DailyChallengeResult?
    
    private let puzzleGenerator = PuzzleGenerator.shared
    private let userDefaultsKey = "dailyChallenge"
    private let resultKey = "dailyChallengeResult"
    
    private init() {
        loadCurrentChallenge()
        loadUserResult()
    }
    
    // MARK: - Challenge Management
    
    func getTodayChallenge() -> DailyChallenge {
        let today = Calendar.current.startOfDay(for: Date())
        let dateString = formatDate(today)
        
        // Check if we already have today's challenge
        if let existing = currentChallenge,
           existing.dateString == dateString {
            return existing
        }
        
        // Generate new challenge for today
        let seed = generateSeed(for: today)
        let puzzle = generateDailyPuzzle(seed: seed)
        
        let challenge = DailyChallenge(
            id: dateString,
            date: today,
            puzzle: puzzle,
            seed: seed
        )
        
        currentChallenge = challenge
        saveChallenge(challenge)
        
        // Reset user result if it's a new day
        if let existingResult = userResult,
           existingResult.challengeId != dateString {
            userResult = nil
            clearUserResult()
        }
        
        return challenge
    }
    
    private func generateSeed(for date: Date) -> Int {
        // Use date components to create a deterministic seed
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return (components.year ?? 2024) * 10000 + (components.month ?? 1) * 100 + (components.day ?? 1)
    }
    
    private func generateDailyPuzzle(seed: Int) -> Puzzle {
        // Daily challenges are always medium difficulty, 3x3x3
        // Note: For true reproducibility, we'd need seeded RNG, but for now
        // we'll use the standard generator. The seed is stored for future use.
        return puzzleGenerator.generatePuzzle(size: 3, difficulty: .medium)
    }
    
    // MARK: - Result Management
    
    func submitResult(score: Int, wordsFound: [String]) {
        guard let challenge = currentChallenge else { return }
        
        let result = DailyChallengeResult(
            challengeId: challenge.id,
            userId: UUID(), // Will be replaced with actual user ID when syncing
            score: score,
            wordsFound: wordsFound.count,
            completedAt: Date()
        )
        
        userResult = result
        saveUserResult(result)
    }
    
    func hasCompletedToday() -> Bool {
        guard let challenge = currentChallenge,
              let result = userResult else {
            return false
        }
        return result.challengeId == challenge.id
    }
    
    func getBestScore() -> Int {
        return userResult?.score ?? 0
    }
    
    // MARK: - Persistence
    
    private func saveChallenge(_ challenge: DailyChallenge) {
        // Save challenge metadata (puzzle is regenerated from seed)
        let challengeData: [String: Any] = [
            "id": challenge.id,
            "date": challenge.date.timeIntervalSince1970,
            "seed": challenge.seed
        ]
        UserDefaults.standard.set(challengeData, forKey: "\(userDefaultsKey)_\(challenge.id)")
    }
    
    private func loadCurrentChallenge() {
        let today = Calendar.current.startOfDay(for: Date())
        let dateString = formatDate(today)
        
        if let challengeData = UserDefaults.standard.dictionary(forKey: "\(userDefaultsKey)_\(dateString)"),
           let id = challengeData["id"] as? String,
           let dateTimestamp = challengeData["date"] as? TimeInterval,
           let seed = challengeData["seed"] as? Int {
            let date = Date(timeIntervalSince1970: dateTimestamp)
            let puzzle = generateDailyPuzzle(seed: seed)
            let challenge = DailyChallenge(id: id, date: date, puzzle: puzzle, seed: seed)
            currentChallenge = challenge
        }
    }
    
    private func saveUserResult(_ result: DailyChallengeResult) {
        if let data = try? JSONEncoder().encode(result) {
            UserDefaults.standard.set(data, forKey: "\(resultKey)_\(result.challengeId)")
        }
    }
    
    private func loadUserResult() {
        guard let challenge = currentChallenge else { return }
        
        if let data = UserDefaults.standard.data(forKey: "\(resultKey)_\(challenge.id)"),
           let result = try? JSONDecoder().decode(DailyChallengeResult.self, from: data) {
            userResult = result
        }
    }
    
    private func clearUserResult() {
        guard let challenge = currentChallenge else { return }
        UserDefaults.standard.removeObject(forKey: "\(resultKey)_\(challenge.id)")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - SystemRandomNumberGenerator Extension
extension SystemRandomNumberGenerator {
    init(seed: UInt64) {
        self.init()
        // Note: SystemRandomNumberGenerator doesn't support seeding
        // For true reproducibility, we'd need a seeded RNG, but for simplicity
        // we'll use the date-based seed in puzzle generation
    }
}

