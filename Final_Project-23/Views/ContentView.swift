//
//  ContentView.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import SwiftUI
// The view for all the contents
struct ContentView: View {
    @State private var hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    
    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasSeenOnboarding)
            } else {
                HomeView()
            }
        }
    }
}

#Preview {
    ContentView()
}

