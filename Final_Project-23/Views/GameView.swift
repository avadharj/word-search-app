//
//  GameView.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import SwiftUI

struct GameView: View {
    @Binding var navigationPath: NavigationPath
    @StateObject private var gameState: GameState
    @State private var showResults = false
    @State private var gameEngine = GameEngine()
    
    init(navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
        // Initialize with a new puzzle
        let puzzle = Puzzle.generate(size: 3)
        self._gameState = StateObject(wrappedValue: GameState(cube: puzzle.cube))
    }
    
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
                        Text("\(gameState.score)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Words Found")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(gameState.wordsFound.count)")
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
                                    .background(Color.accentColor.opacity(0.2))
                                    .foregroundColor(.accentColor)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        gameState.isPaused.toggle()
                    }) {
                        Label(gameState.isPaused ? "Resume" : "Pause", systemImage: gameState.isPaused ? "play.fill" : "pause.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
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
            .disabled(gameState.isPaused)
            .overlay {
                if gameState.isPaused {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack {
                        Text("Paused")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Button("Resume") {
                            gameState.isPaused = false
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                        .padding(.top)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                }
            }
        }
        .navigationTitle("Game")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showResults) {
            GameResultsView(
                score: gameState.score,
                wordsFound: gameState.wordsFound.count,
                navigationPath: $navigationPath
            )
            .onAppear {
                // Save game statistics when results are shown
                DataPersistence.shared.updateStatistics(
                    score: gameState.score,
                    wordsFound: gameState.wordsFound
                )
                DataPersistence.shared.saveGameRecord(
                    score: gameState.score,
                    wordsFound: gameState.wordsFound
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        GameView(navigationPath: .constant(NavigationPath()))
    }
}

