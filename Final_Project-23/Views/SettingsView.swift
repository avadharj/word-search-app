//
//  SettingsView.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var soundManager = SoundManager.shared
    @AppStorage("difficulty") private var difficulty = "Medium"
    @State private var showAbout = false
    @State private var showHelp = false
    
    var body: some View {
        List {
            Section("Game Settings") {
                Toggle(isOn: $soundManager.soundEnabled) {
                    Label("Sound Effects", systemImage: "speaker.wave.2.fill")
                }
                .onChange(of: soundManager.soundEnabled) { _ in
                    if soundManager.soundEnabled {
                        SoundManager.shared.playSound("letterSelect")
                    }
                }
                
                Toggle(isOn: $soundManager.hapticsEnabled) {
                    Label("Haptic Feedback", systemImage: "hand.tap.fill")
                }
                .onChange(of: soundManager.hapticsEnabled) { _ in
                    if soundManager.hapticsEnabled {
                        SoundManager.shared.playHaptic(.medium)
                    }
                }
                
                Picker("Difficulty", selection: $difficulty) {
                    ForEach(Difficulty.allCases, id: \.self) { diff in
                        Text(diff.rawValue).tag(diff.rawValue)
                    }
                }
                
                HStack {
                    Text("Cube Size")
                    Spacer()
                    Text(Difficulty(rawValue: difficulty)?.cubeSize.description ?? "3")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Help") {
                Button(action: {
                    showHelp = true
                }) {
                    Label("How to Play", systemImage: "questionmark.circle.fill")
                }
                
                Button(action: {
                    showAbout = true
                }) {
                    Label("About", systemImage: "info.circle.fill")
                }
                
                HStack {
                    Label("Version", systemImage: "app.badge")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Account") {
                Button(action: {
                    // TODO: Implement sign in
                }) {
                    Label("Sign In", systemImage: "person.circle.fill")
                }
                
                Button(action: {
                    // TODO: Implement leaderboard sync
                }) {
                    Label("Sync Progress", systemImage: "arrow.clockwise.circle.fill")
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .sheet(isPresented: $showHelp) {
            HelpView()
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "cube.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                
                Text("Word Search")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("An iOS word search game played on a vanishing cube. Connect touching letters to form words, the longer the better!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("About")
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

#Preview {
    NavigationView {
        SettingsView()
    }
}

