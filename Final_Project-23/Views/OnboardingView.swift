//
//  OnboardingView.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var hasCompletedOnboarding: Bool
    
    let pages = [
        OnboardingPage(
            title: "Welcome to Word Search",
            description: "Connect touching letters to form words on a vanishing cube",
            systemImage: "cube.fill"
        ),
        OnboardingPage(
            title: "How to Play",
            description: "Swipe across letters to form words. The longer the word, the better your score!",
            systemImage: "hand.draw"
        ),
        OnboardingPage(
            title: "Challenge Yourself",
            description: "Each letter can be used three times before its cube disappears, revealing new letters",
            systemImage: "sparkles"
        )
    ]
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Bottom Button
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        Button(action: {
                            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                            hasCompletedOnboarding = true
                        }) {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 32)
                    } else {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 32)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let systemImage: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: page.systemImage)
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
                .padding()
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}

