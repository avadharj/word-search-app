//
//  GameResultsView.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import SwiftUI

struct GameResultsView: View {
    var body: some View {
        VStack {
            Text("Game Results")
                .font(.largeTitle)
            // TODO: Add game results display
            Text("Score: --")
            Text("Words Found: --")
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        GameResultsView()
    }
}

