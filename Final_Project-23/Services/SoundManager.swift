//
//  SoundManager.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import AVFoundation
import UIKit

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    @Published var soundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")
        }
    }
    
    @Published var hapticsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hapticsEnabled, forKey: "hapticsEnabled")
        }
    }
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    private init() {
        self.soundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled", defaultValue: true)
        self.hapticsEnabled = UserDefaults.standard.bool(forKey: "hapticsEnabled", defaultValue: true)
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    // MARK: - Sound Effects
    
    func playSound(_ soundName: String) {
        guard soundEnabled else { return }
        
        if let player = audioPlayers[soundName] {
            player.currentTime = 0
            player.play()
        } else {
            // Generate system sounds
            playSystemSound(soundName)
        }
    }
    
    private func playSystemSound(_ soundName: String) {
        let systemSoundID: SystemSoundID
        
        switch soundName {
        case "letterSelect":
            systemSoundID = 1104 // Tink sound
        case "wordFound":
            systemSoundID = 1057 // Success sound
        case "wordInvalid":
            systemSoundID = 1053 // Error sound
        case "letterRemove":
            systemSoundID = 1054 // Alert sound
        case "gameComplete":
            systemSoundID = 1052 // Success fanfare
        default:
            systemSoundID = 1104
        }
        
        AudioServicesPlaySystemSound(systemSoundID)
    }
    
    // MARK: - Haptic Feedback
    
    func playHaptic(_ type: HapticType) {
        guard hapticsEnabled else { return }
        
        switch type {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .medium:
            hapticGenerator.impactOccurred()
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        case .success:
            notificationGenerator.notificationOccurred(.success)
        case .error:
            notificationGenerator.notificationOccurred(.error)
        case .warning:
            notificationGenerator.notificationOccurred(.warning)
        }
    }
}

enum HapticType {
    case light
    case medium
    case heavy
    case success
    case error
    case warning
}

extension UserDefaults {
    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return bool(forKey: key)
    }
}

