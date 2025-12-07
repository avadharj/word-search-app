//
//  StatsView.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import SwiftUI

struct StatsView: View {
    // --- CONFLICT RESOLVED: KEEPING DEV'S PERSISTENCE LOGIC ---
    @State private var statistics = DataPersistence.shared.loadStatistics()
    @State private var averageScore: Int = 0
    @ObservedObject private var locationManager = LocationManager.shared
    
    private var calculatedAverageScore: Int {
        guard statistics.totalGames > 0 else { return 0 }
        return statistics.totalScore / statistics.totalGames
    }
    // -----------------------------------------------------------
    
    var body: some View {
        List {
            Section("Your Statistics") {
                StatRow(
                    icon: "gamecontroller.fill",
                    title: "Games Played",
                    // --- CONFLICT RESOLVED: USING statistics.totalGames ---
                    value: "\(statistics.totalGames)",
                    // -----------------------------------------------------
                    color: .blue
                )
                
                StatRow(
                    icon: "text.word.spacing",
                    title: "Words Found",
                    // --- CONFLICT RESOLVED: USING statistics.totalWords ---
                    value: "\(statistics.totalWords)",
                    // ------------------------------------------------------
                    color: .green
                )
                
                StatRow(
                    icon: "star.fill",
                    title: "High Score",
                    // --- CONFLICT RESOLVED: USING statistics.highScore ---
                    value: "\(statistics.highScore)",
                    // ----------------------------------------------------
                    color: .orange
                )
                
                StatRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Average Score",
                    // --- CONFLICT RESOLVED: USING calculatedAverageScore ---
                    value: "\(calculatedAverageScore)",
                    // --------------------------------------------------------
                    color: .purple
                )
                
                StatRow(
                    icon: "textformat.size",
                    title: "Longest Word",
                    // --- CONFLICT RESOLVED: USING statistics.longestWord ---
                    value: statistics.longestWord.isEmpty ? "—" : statistics.longestWord.uppercased(),
                    // -------------------------------------------------------
                    color: .red
                )
            }
            
            Section("Achievements") {
                AchievementRow(
                    title: "First Word",
                    description: "Find your first word",
                    // --- CONFLICT RESOLVED: USING statistics.totalWords ---
                    isUnlocked: statistics.totalWords > 0,
                    // ------------------------------------------------------
                    icon: "trophy.fill"
                )
                
                AchievementRow(
                    title: "Word Master",
                    description: "Find 100 words",
                    // --- CONFLICT RESOLVED: USING statistics.totalWords ---
                    isUnlocked: statistics.totalWords >= 100,
                    // ------------------------------------------------------
                    icon: "crown.fill"
                )
                
                AchievementRow(
                    title: "High Scorer",
                    description: "Score over 1000 points",
                    // --- CONFLICT RESOLVED: USING statistics.highScore ---
                    isUnlocked: statistics.highScore >= 1000,
                    // -----------------------------------------------------
                    icon: "star.circle.fill"
                )
            }
            
            Section("Location") {
                if locationManager.isAuthorized {
                    if locationManager.isLoading {
                        HStack {
                            ProgressView()
                            Text("Getting location...")
                                .foregroundColor(.secondary)
                        }
                    } else if let error = locationManager.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else if locationManager.hasLocation {
                        StatRow(
                            icon: "location.fill",
                            title: "Your Location",
                            value: locationManager.locationName,
                            color: .blue
                        )
                        
                        StatRow(
                            icon: "mappin.circle.fill",
                            title: "Coordinates",
                            value: locationManager.formattedCoordinates,
                            color: .green
                        )
                    } else {
                        Button(action: {
                            locationManager.startLocationUpdates()
                        }) {
                            Label("Enable Location", systemImage: "location.circle.fill")
                        }
                    }
                } else {
                    Button(action: {
                        locationManager.requestLocationPermission()
                    }) {
                        Label("Enable Location Services", systemImage: "location.slash.fill")
                    }
                }
            }
            
            Section("Leaderboard") {
                // --- CONFLICT RESOLVED: KEEPING DEV'S LEADERBOARD LOGIC ---
                if BackendService.shared.isAuthenticated {
                    LeaderboardView() // Assuming LeaderboardView is a view you added to dev
                } else {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.secondary)
                        Text("Global Leaderboard")
                        Spacer()
                        Text("Sign in to view")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                // ----------------------------------------------------------
            }
        }
        .navigationTitle("Statistics")
        // --- CONFLICT RESOLVED: KEEPING DEV'S ONAPPEAR REFRESH ---
        .onAppear {
            statistics = DataPersistence.shared.loadStatistics()
            // Request location if authorized
            if locationManager.isAuthorized && !locationManager.hasLocation {
                locationManager.startLocationUpdates()
            }
        }
        // ----------------------------------------------------------
    }
}

// StatRow, AchievementRow, and Preview are non-conflicting and kept as is.
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
