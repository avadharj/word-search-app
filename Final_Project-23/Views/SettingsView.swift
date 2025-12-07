//
//  SettingsView.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import SwiftUI

struct SettingsView: View {
    // --- CONFLICT RESOLVED: KEEPING DEV'S STATE OBJECTS AND VARIABLES ---
    @ObservedObject private var soundManager = SoundManager.shared
    @AppStorage("difficulty") private var difficulty = "Medium"
    @State private var showAbout = false
    @State private var showHelp = false
    @State private var showAuth = false
    // ---------------------------------------------------------------------
    
    var body: some View {
        List {
            Section("Game Settings") {
                // --- CONFLICT RESOLVED: USING soundManager BINDINGS AND ONCHANGE ---
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
                // --------------------------------------------------------------------
            }
            
            // --- NEW SECTION FROM DEV: Help ---
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
            // ----------------------------------
            
            Section("Location Services") {
                HStack {
                    Label("Location Access", systemImage: "location.fill")
                    Spacer()
                    if LocationManager.shared.isAuthorized {
                        Text("Enabled")
                            .foregroundColor(.green)
                            .font(.caption)
                    } else {
                        Text("Disabled")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                
                if !LocationManager.shared.isAuthorized {
                    Button(action: {
                        LocationManager.shared.requestLocationPermission()
                    }) {
                        Label("Enable Location", systemImage: "location.circle.fill")
                    }
                }
            }
            
            Section("Account") {
                // --- CONFLICT RESOLVED: KEEPING DEV'S SIGN IN/OUT LOGIC ---
                if BackendService.shared.isAuthenticated {
                    HStack {
                        Label("Signed In", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Spacer()
                        Button("Sign Out") {
                            BackendService.shared.logout()
                        }
                        .foregroundColor(.red)
                    }
                } else {
                    Button(action: {
                        showAuth = true
                    }) {
                        Label("Sign In", systemImage: "person.circle.fill")
                    }
                }
                
                Button(action: {
                    Task {
                        do {
                            try await DataPersistence.shared.syncStatisticsToBackend()
                            try await DataPersistence.shared.syncGameHistoryToBackend()
                        } catch {
                            print("Sync failed: \(error)")
                        }
                    }
                }) {
                    Label("Sync Progress", systemImage: "arrow.clockwise.circle.fill")
                }
                .disabled(!BackendService.shared.isAuthenticated)
                // ----------------------------------------------------------
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        // --- CONFLICT RESOLVED: KEEPING DEV'S ADDITIONAL SHEETS ---
        .sheet(isPresented: $showHelp) {
            HelpView()
        }
        .sheet(isPresented: $showAuth) {
            AuthenticationView()
        }
        // ---------------------------------------------------------
    }
}

// NOTE: The AboutView remains unchanged and is included below for completeness.
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
