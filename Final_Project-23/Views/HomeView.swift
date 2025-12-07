//
//  HomeView.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import SwiftUI
import Combine

struct HomeView: View {
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "cube.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                        
                        Text("Word Search")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Connect letters, form words")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    // Menu Cards
                    VStack(spacing: 16) {
                        MenuCard(
                            title: "Play Game",
                            subtitle: "Start a new puzzle",
                            icon: "gamecontroller.fill",
                            color: .blue
                        ) {

                            SoundManager.shared.playHaptic(.medium)
                            navigationPath.append("game")
                        }
                        
                        MenuCard(
                            title: "Statistics",
                            subtitle: "View your progress",
                            icon: "chart.bar.fill",
                            color: .green
                        ) {

                            SoundManager.shared.playHaptic(.light)

                            navigationPath.append("stats")
                        }
                        
                        MenuCard(
                            title: "Settings",
                            subtitle: "Customize your experience",
                            icon: "gearshape.fill",
                            color: .gray
                        ) {

                            SoundManager.shared.playHaptic(.light)

                            navigationPath.append("settings")
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "game":
                    GameView(navigationPath: $navigationPath)
                case "stats":
                    StatsView()
                case "settings":
                    SettingsView()
                default:
                    EmptyView()
                }
            }
        }
    }
}

struct MenuCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(color)
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
}

