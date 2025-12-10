//
//  LeaderboardView.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import SwiftUI

struct LeaderboardView: View {
    @State private var leaderboard: [LeaderboardEntry] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        Group {
            if isLoading {
                HStack {
                    ProgressView()
                    Text("Loading...")
                        .foregroundColor(.secondary)
                }
            } else if let errorMessage = errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else if leaderboard.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trophy")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No leaderboard data yet")
                        .foregroundColor(.secondary)
                        .font(.headline)
                    Text("Be the first to play and sync your score!")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                    Text("Make sure you've synced your progress after playing a game.")
                        .foregroundColor(.secondary)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .padding()
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
                            .foregroundColor(.accentColor)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .onAppear {
            loadLeaderboard()
        }
        .refreshable {
            loadLeaderboard()
        }
    }
    
    private func loadLeaderboard() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let entries = try await DataPersistence.shared.loadLeaderboard()
                await MainActor.run {
                    leaderboard = entries
                    isLoading = false
                    if entries.isEmpty {
                        print("⚠️ Leaderboard is empty - no players have synced scores yet")
                        print("💡 Make sure you've played a game and tapped 'Sync Progress' in Settings")
                    } else {
                        print("✅ Loaded \(entries.count) leaderboard entries")
                    }
                }
            } catch {
                await MainActor.run {
                    let errorMsg: String
                    if let backendError = error as? BackendError {
                        switch backendError {
                        case .networkError:
                            errorMsg = "Cannot connect to server. Make sure the server is running."
                        case .authenticationFailed:
                            errorMsg = "Please sign in to view the leaderboard."
                        default:
                            errorMsg = "Error: \(error.localizedDescription)"
                        }
                    } else {
                        errorMsg = "Error: \(error.localizedDescription)"
                    }
                    errorMessage = errorMsg
                    isLoading = false
                    print("❌ Leaderboard error: \(error)")
                }
            }
        }
    }
}

#Preview {
    List {
        Section("Leaderboard") {
            LeaderboardView()
        }
    }
}
