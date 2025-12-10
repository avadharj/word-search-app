//
//  MotionManager.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import Foundation
import CoreMotion
import Combine

class MotionManager: ObservableObject {
    static let shared = MotionManager()
    
    private let motionManager = CMMotionManager()
    
    @Published var rotationRate: CMRotationRate?
    @Published var userAcceleration: CMAcceleration?
    @Published var gravity: CMAcceleration?
    @Published var attitude: CMAttitude?
    @Published var isMotionAvailable: Bool = false
    @Published var isMotionActive: Bool = false
    
    // Motion sensitivity settings
    @Published var motionSensitivity: Double = 1.0 // 0.0 to 2.0
    @Published var motionEnabled: Bool = true
    
    // Shake detection
    @Published var shakeDetected: Bool = false
    private var lastShakeTime: Date = Date()
    private let shakeThreshold: Double = 2.5 // G-force threshold
    private let shakeCooldown: TimeInterval = 1.0 // Seconds between shake detections
    
    private init() {
        isMotionAvailable = motionManager.isDeviceMotionAvailable
        motionSensitivity = UserDefaults.standard.double(forKey: "motionSensitivity")
        if motionSensitivity == 0 {
            motionSensitivity = 1.0 // Default
        }
        motionEnabled = UserDefaults.standard.bool(forKey: "motionEnabled")
    }
    
    // MARK: - Motion Updates
    
    func startMotionUpdates() {
        guard isMotionAvailable && motionEnabled else { return }
        guard !isMotionActive else { return }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // 60 Hz
        motionManager.showsDeviceMovementDisplay = false
        
        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else {
                if let error = error {
                    print("Motion update error: \(error.localizedDescription)")
                }
                return
            }
            
            self.rotationRate = motion.rotationRate
            self.userAcceleration = motion.userAcceleration
            self.gravity = motion.gravity
            self.attitude = motion.attitude
            
            // Detect shake
            self.detectShake(acceleration: motion.userAcceleration)
        }
        
        isMotionActive = true
    }
    
    func stopMotionUpdates() {
        guard isMotionActive else { return }
        motionManager.stopDeviceMotionUpdates()
        isMotionActive = false
        
        // Reset values
        rotationRate = nil
        userAcceleration = nil
        gravity = nil
        attitude = nil
    }
    
    // MARK: - Shake Detection
    
    private func detectShake(acceleration: CMAcceleration) {
        let magnitude = sqrt(
            acceleration.x * acceleration.x +
            acceleration.y * acceleration.y +
            acceleration.z * acceleration.z
        )
        
        if magnitude > shakeThreshold {
            let now = Date()
            if now.timeIntervalSince(lastShakeTime) > shakeCooldown {
                lastShakeTime = now
                shakeDetected = true
                
                // Reset after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.shakeDetected = false
                }
            }
        }
    }
    
    // MARK: - Settings
    
    func setMotionSensitivity(_ sensitivity: Double) {
        motionSensitivity = max(0.0, min(2.0, sensitivity))
        UserDefaults.standard.set(motionSensitivity, forKey: "motionSensitivity")
    }
    
    func setMotionEnabled(_ enabled: Bool) {
        motionEnabled = enabled
        UserDefaults.standard.set(motionEnabled, forKey: "motionEnabled")
        
        if enabled {
            startMotionUpdates()
        } else {
            stopMotionUpdates()
        }
    }
    
    // MARK: - Helper Methods
    
    /// Get rotation delta for cube rotation (in radians)
    func getRotationDelta() -> (x: Double, y: Double) {
        guard let rotation = rotationRate, motionEnabled else {
            return (0, 0)
        }
        
        // Apply sensitivity and convert to rotation delta
        let deltaX = rotation.y * motionSensitivity * 0.01 // Y rotation affects X axis
        let deltaY = rotation.x * motionSensitivity * 0.01 // X rotation affects Y axis
        
        return (deltaX, deltaY)
    }
    
    /// Get tilt angle for cube orientation
    func getTiltAngle() -> (pitch: Double, roll: Double) {
        guard let attitude = attitude, motionEnabled else {
            return (0, 0)
        }
        
        // Convert attitude to pitch and roll
        let pitch = attitude.pitch * motionSensitivity
        let roll = attitude.roll * motionSensitivity
        
        return (pitch, roll)
    }
    
    /// Check if device is being shaken
    func isShaking() -> Bool {
        return shakeDetected
    }
    
    deinit {
        stopMotionUpdates()
    }
}

