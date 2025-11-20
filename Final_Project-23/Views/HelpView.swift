//
//  HelpView.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "cube.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                        
                        Text("How to Play")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 16) {
                        InstructionRow(
                            icon: "hand.draw.fill",
                            title: "Select Letters",
                            description: "Tap on letters to form words. Letters must be touching (neighbors) to be selected."
                        )
                        
                        InstructionRow(
                            icon: "text.word.spacing",
                            title: "Form Words",
                            description: "Connect touching letters to create valid words. Words must be at least 3 letters long."
                        )
                        
                        InstructionRow(
                            icon: "star.fill",
                            title: "Score Points",
                            description: "Longer words score more points. Words 6+ letters get bonus points!"
                        )
                        
                        InstructionRow(
                            icon: "sparkles",
                            title: "Vanishing Cubes",
                            description: "Each letter can be used 3 times. After that, the cube disappears revealing new letters."
                        )
                        
                        InstructionRow(
                            icon: "chart.bar.fill",
                            title: "Track Progress",
                            description: "View your statistics, achievements, and found words in the Stats screen."
                        )
                    }
                    .padding(.horizontal)
                    
                    // Scoring
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Scoring")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Text("Base Score:")
                            Spacer()
                            Text("10 points per letter")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Bonus (6+ letters):")
                            Spacer()
                            Text("+20 per extra letter")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Difficulty
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Difficulty Levels")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            HStack(alignment: .top) {
                                Text("•")
                                    .foregroundColor(.accentColor)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(difficulty.rawValue)
                                        .fontWeight(.semibold)
                                    Text(difficulty.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationTitle("Help")
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

struct InstructionRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    HelpView()
}

