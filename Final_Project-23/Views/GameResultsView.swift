//
//  GameResultsView.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import SwiftUI

struct GameResultsView: View {
    let score: Int
    let wordsFound: Int
    @Binding var navigationPath: NavigationPath
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Results Icon
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    // Title
                    Text("Game Complete!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // Stats Cards
                    VStack(spacing: 16) {
                        ResultCard(
                            title: "Final Score",
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
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {

                            SoundManager.shared.playHaptic(.medium)

                            dismiss()
                            navigationPath.removeLast()
                        }) {
                            Text("Play Again")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {


                            SoundManager.shared.playHaptic(.light)

                            dismiss()
                            navigationPath = NavigationPath()
                        }) {
                            Text("Back to Home")
                                .font(.headline)
                                .foregroundColor(.accentColor)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.accentColor, lineWidth: 2)
                                )
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                        navigationPath = NavigationPath()
                    }
                }
            }
        }
    }
}

struct ResultCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(color)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    GameResultsView(
        score: 1250,
        wordsFound: 15,
        navigationPath: .constant(NavigationPath())
    )
}

