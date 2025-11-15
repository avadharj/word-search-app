//
//  ContentView.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showOnboarding = false
    @State private var hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    
    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView()
                    .onAppear {
                        // After onboarding, set flag
                        // UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    }
            } else {
                HomeView()
            }
        }
    }
}

#Preview {
    ContentView()
}

