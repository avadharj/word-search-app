//
//  StatsView.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import SwiftUI

struct StatsView: View {
    // TODO: Replace with actual data from game state
    @State private var totalGames = 0
    @State private var totalWords = 0
    @State private var highScore = 0
    @State private var averageScore = 0
    @State private var longestWord = ""
    
    var body: some View {
        List {
            Section("Your Statistics") {
                StatRow(
                    icon: "gamecontroller.fill",
                    title: "Games Played",
                    value: "\(totalGames)",
                    color: .blue
                )
                
                StatRow(
                    icon: "text.word.spacing",
                    title: "Words Found",
                    value: "\(totalWords)",
                    color: .green
                )
                
                StatRow(
                    icon: "star.fill",
                    title: "High Score",
                    value: "\(highScore)",
                    color: .orange
                )
                
                StatRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Average Score",
                    value: "\(averageScore)",
                    color: .purple
                )
                
                StatRow(
                    icon: "textformat.size",
                    title: "Longest Word",
                    value: longestWord.isEmpty ? "—" : longestWord.uppercased(),
                    color: .red
                )
            }
            
            Section("Achievements") {
                AchievementRow(
                    title: "First Word",
                    description: "Find your first word",
                    isUnlocked: totalWords > 0,
                    icon: "trophy.fill"
                )
                
                AchievementRow(
                    title: "Word Master",
                    description: "Find 100 words",
                    isUnlocked: totalWords >= 100,
                    icon: "crown.fill"
                )
                
                AchievementRow(
                    title: "High Scorer",
                    description: "Score over 1000 points",
                    isUnlocked: highScore >= 1000,
                    icon: "star.circle.fill"
                )
            }
            
            Section("Leaderboard") {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.secondary)
                    Text("Global Leaderboard")
                    Spacer()
                    Text("Coming Soon")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // TODO: Add leaderboard entries when backend is ready
            }
        }
        .navigationTitle("Statistics")
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(color)
                .cornerRadius(8)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

struct AchievementRow: View {
    let title: String
    let description: String
    let isUnlocked: Bool
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isUnlocked ? .yellow : .gray)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

#Preview {
    NavigationView {
        StatsView()
    }
}

