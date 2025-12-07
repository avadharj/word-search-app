//
//  LocationManager.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let manager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationName: String = "Unknown"
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer // Use lower accuracy for privacy
        manager.distanceFilter = 1000 // Update only when moved 1km
        authorizationStatus = manager.authorizationStatus
    }
    
    // MARK: - Public Methods
    
    func requestLocationPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestLocationPermission()
            return
        }
        
        isLoading = true
        errorMessage = nil
        manager.requestLocation()
    }
    
    func stopLocationUpdates() {
        manager.stopUpdatingLocation()
        isLoading = false
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        self.location = location
        isLoading = false
        
        // Reverse geocode to get location name
        reverseGeocode(location: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                errorMessage = "Location access denied. Please enable location services in Settings."
            case .network:
                errorMessage = "Network error while getting location."
            default:
                errorMessage = "Failed to get location: \(error.localizedDescription)"
            }
        } else {
            errorMessage = "Location error: \(error.localizedDescription)"
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        case .denied, .restricted:
            errorMessage = "Location access denied. Enable in Settings to see location-based features."
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - Reverse Geocoding
    
    private func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                self.locationName = "Location: \(String(format: "%.4f", location.coordinate.latitude)), \(String(format: "%.4f", location.coordinate.longitude))"
                return
            }
            
            if let placemark = placemarks?.first {
                var components: [String] = []
                
                if let city = placemark.locality {
                    components.append(city)
                }
                if let state = placemark.administrativeArea {
                    components.append(state)
                }
                if let country = placemark.country {
                    components.append(country)
                }
                
                if components.isEmpty {
                    self.locationName = "Location: \(String(format: "%.4f", location.coordinate.latitude)), \(String(format: "%.4f", location.coordinate.longitude))"
                } else {
                    self.locationName = components.joined(separator: ", ")
                }
            } else {
                self.locationName = "Location: \(String(format: "%.4f", location.coordinate.latitude)), \(String(format: "%.4f", location.coordinate.longitude))"
            }
        }
    }
    
    // MARK: - Helper Methods
    
    var hasLocation: Bool {
        return location != nil
    }
    
    var isAuthorized: Bool {
        return authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    var formattedCoordinates: String {
        guard let location = location else { return "Not available" }
        return String(format: "%.4f, %.4f", location.coordinate.latitude, location.coordinate.longitude)
    }
}

