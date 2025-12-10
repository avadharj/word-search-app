//
//  DailyChallengeView.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import SwiftUI

struct DailyChallengeView: View {
    @ObservedObject private var challengeService = DailyChallengeService.shared
    @ObservedObject private var backendService = BackendService.shared
    @Binding var navigationPath: NavigationPath
    @State private var showLeaderboard = false
    @State private var leaderboard: [DailyChallengeLeaderboardEntry] = []
    @State private var isLoadingLeaderboard = false
    
    var challenge: DailyChallenge {
        challengeService.getTodayChallenge()
    }
    
    init(navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
    }
    
    var body: some View {
        ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Daily Challenge")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(challenge.displayDate)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        if challengeService.hasCompletedToday() {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Completed!")
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Your Score Card
                    if let result = challengeService.userResult {
                        VStack(spacing: 12) {
                            Text("Your Score")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("\(result.score)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.orange)
                            
                            Text("\(result.wordsFound) words found")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // Play Button
                    Button(action: {
                        SoundManager.shared.playHaptic(.medium)
                        navigationPath.append("dailyChallengeGame")
                    }) {
                        HStack {
                            Image(systemName: challengeService.hasCompletedToday() ? "arrow.clockwise" : "play.fill")
                            Text(challengeService.hasCompletedToday() ? "Play Again" : "Start Challenge")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(challengeService.hasCompletedToday() ? Color.blue : Color.orange)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Leaderboard Button
                    Button(action: {
                        showLeaderboard = true
                        loadLeaderboard()
                    }) {
                        HStack {
                            Image(systemName: "trophy.fill")
                            Text("View Leaderboard")
                        }
                        .font(.headline)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Info Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About Daily Challenges")
                            .font(.headline)
                        
                        Text("• Same puzzle for everyone today")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("• Compete with players worldwide")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("• New challenge every day at midnight")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("• Leaderboard resets daily")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Daily Challenge")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showLeaderboard) {
            DailyChallengeLeaderboardView(
                leaderboard: leaderboard,
                isLoading: isLoadingLeaderboard
            )
        }
    }
    
    private func loadLeaderboard() {
        isLoadingLeaderboard = true
        Task {
            do {
                let entries = try await BackendService.shared.fetchDailyChallengeLeaderboard(challengeId: challenge.id)
                await MainActor.run {
                    leaderboard = entries
                    isLoadingLeaderboard = false
                }
            } catch {
                await MainActor.run {
                    isLoadingLeaderboard = false
                    print("Failed to load leaderboard: \(error)")
                }
            }
        }
    }
}

// MARK: - Daily Challenge Game View
struct DailyChallengeGameView: View {
    let challenge: DailyChallenge
    @Binding var navigationPath: NavigationPath
    @StateObject private var gameState: GameState
    @State private var showResults = false
    @State private var gameEngine = GameEngine()
    @ObservedObject private var challengeService = DailyChallengeService.shared
    
    init(challenge: DailyChallenge, navigationPath: Binding<NavigationPath>) {
        self.challenge = challenge
        self._navigationPath = navigationPath
        // Initialize with the challenge puzzle
        self._gameState = StateObject(wrappedValue: GameState(cube: challenge.puzzle.cube))
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Challenge Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Daily Challenge")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(challenge.displayDate)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Score")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(gameState.score)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // 3D Cube View
                CubeView(gameState: gameState) { index in
                    gameEngine.processWordSelection(at: index, gameState: gameState)
                }
                .frame(height: 400)
                .cornerRadius(20)
                .padding(.horizontal)
                
                // Current Word Display
                if !gameState.currentWord.isEmpty {
                    HStack {
                        Text("Current Word:")
                            .font(.headline)
                        Text(gameState.currentWord.uppercased())
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Found Words List
                if !gameState.wordsFound.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(gameState.wordsFound, id: \.self) { word in
                                Text(word.uppercased())
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.orange.opacity(0.2))
                                    .foregroundColor(.orange)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // End Game Button
                Button(action: {
                    SoundManager.shared.playSound("gameComplete")
                    SoundManager.shared.playHaptic(.success)
                    showResults = true
                }) {
                    Label("End Challenge", systemImage: "flag.checkered")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle("Daily Challenge")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showResults) {
            DailyChallengeResultsView(
                score: gameState.score,
                wordsFound: gameState.wordsFound.count,
                challenge: challenge,
                navigationPath: $navigationPath
            )
        }
    }
}

// MARK: - Daily Challenge Results View
struct DailyChallengeResultsView: View {
    let score: Int
    let wordsFound: Int
    let challenge: DailyChallenge
    @Binding var navigationPath: NavigationPath
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var challengeService = DailyChallengeService.shared
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Challenge Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    ResultCard(
                        title: "Score",
                        value: "\(score)",
                        icon: "star.fill",
                        color: .orange
                    )
                    
                    ResultCard(
                        title: "Words Found",
                        value: "\(wordsFound)",
                        icon: "text.word.spacing",
                        color: .blue
                    )
                }
                .padding()
                
                if let previousResult = challengeService.userResult,
                   score > previousResult.score {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                        Text("New Best Score!")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }
                
                Button(action: {
                    submitResult()
                }) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Submit Score")
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isSubmitting ? Color.gray : Color.orange)
                    .cornerRadius(12)
                }
                .disabled(isSubmitting)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                        navigationPath.removeLast()
                    }
                }
            }
        }
        .onAppear {
            // Save result locally
            challengeService.submitResult(score: score, wordsFound: Array(repeating: "", count: wordsFound))
        }
    }
    
    private func submitResult() {
        isSubmitting = true
        Task {
            do {
                try await BackendService.shared.submitDailyChallengeResult(
                    challengeId: challenge.id,
                    score: score,
                    wordsFound: wordsFound
                )
                await MainActor.run {
                    isSubmitting = false
                    dismiss()
                    navigationPath.removeLast()
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    print("Failed to submit result: \(error)")
                }
            }
        }
    }
}

// MARK: - Daily Challenge Leaderboard View
struct DailyChallengeLeaderboardView: View {
    let leaderboard: [DailyChallengeLeaderboardEntry]
    let isLoading: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Text("Loading...")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else if leaderboard.isEmpty {
                    Text("No leaderboard data yet")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(leaderboard) { entry in
                        HStack {
                            Text("#\(entry.rank)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .frame(width: 40)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.playerName)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                
                                Text("\(entry.wordsFound) words")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("\(entry.score)")
                                .font(.headline)
                                .foregroundColor(.orange)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Daily Challenge Leaderboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Leaderboard Entry Model
struct DailyChallengeLeaderboardEntry: Identifiable, Codable {
    let id: UUID
    let playerName: String
    let score: Int
    let wordsFound: Int
    let rank: Int
}

#Preview {
    NavigationStack {
        DailyChallengeView(navigationPath: .constant(NavigationPath()))
    }
}

