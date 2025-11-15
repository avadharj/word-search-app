//
//  StatsView.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import SwiftUI

struct StatsView: View {
    var body: some View {
        List {
            Section("Statistics") {
                // TODO: Add stats display
                Text("Stats placeholder")
            }
            
            Section("Leaderboard") {
                // TODO: Add leaderboard
                Text("Leaderboard placeholder")
            }
        }
        .navigationTitle("Stats")
    }
}

#Preview {
    NavigationView {
        StatsView()
    }
}

