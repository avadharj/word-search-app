//
//  HomeView.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: GameView()) {
                    Label("Play Game", systemImage: "gamecontroller")
                }
                
                NavigationLink(destination: StatsView()) {
                    Label("Statistics", systemImage: "chart.bar")
                }
                
                NavigationLink(destination: SettingsView()) {
                    Label("Settings", systemImage: "gearshape")
                }
            }
            .navigationTitle("Word Search")
        }
    }
}

#Preview {
    HomeView()
}

