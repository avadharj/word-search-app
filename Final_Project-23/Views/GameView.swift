//
//  GameView.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import SwiftUI

struct GameView: View {
    @Binding var navigationPath: NavigationPath
    @State private var score = 0
    @State private var wordsFound = 0
    @State private var currentWord = ""
    @State private var showResults = false
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Game Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Score")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(score)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Words Found")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(wordsFound)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Game Area Placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 20) {
                        Image(systemName: "cube.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.accentColor)
                        
                        Text("Game Cube")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Game logic will be implemented here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .frame(height: 400)
                .padding(.horizontal)
                
                // Current Word Display
                if !currentWord.isEmpty {
                    HStack {
                        Text("Current Word:")
                            .font(.headline)
                        Text(currentWord.uppercased())
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        // TODO: Implement pause/resume
                    }) {
                        Label("Pause", systemImage: "pause.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // TODO: Implement end game
                        showResults = true
                    }) {
                        Label("End Game", systemImage: "xmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle("Game")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showResults) {
            GameResultsView(
                score: score,
                wordsFound: wordsFound,
                navigationPath: $navigationPath
            )
        }
    }
}

#Preview {
    NavigationStack {
        GameView(navigationPath: .constant(NavigationPath()))
    }
}

