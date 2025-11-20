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
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .font(.caption)
            } else if leaderboard.isEmpty {
                Text("No leaderboard data")
                    .foregroundColor(.secondary)
                    .font(.caption)
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
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
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

