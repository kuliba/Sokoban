//
//  LocationAgent.swift
//  ForaBank
//
//  Created by Max Gribov on 11.04.2022.
//

import Foundation
import Combine
import CoreLocation

class LocationAgent: NSObject, LocationAgentProtocol {
    
    var status: CurrentValueSubject<LocationAgentStatus, Never>
    var currentLoaction: CurrentValueSubject<CLLocationCoordinate2D?, Never>
    
    private let locationManager: CLLocationManager
    private var bindings = Set<AnyCancellable>()
    
    override init() {
        
        self.status = .init(.disabled)
        self.currentLoaction = .init(nil)
        self.locationManager = CLLocationManager()
        super.init()
        
        locationManager.delegate = self
        bind()
        updateStatus()
    }
    
    func requestPermissions() {
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    func start() {
        
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        
        locationManager.stopUpdatingLocation()
    }
}

//MARK: - Private Helpers

extension LocationAgent {
    
    func bind() {
        
        status.sink {[unowned self] status in
            
            if status == .disabled {
                
                currentLoaction.value = nil
            }
            
        }.store(in: &bindings)
    }
    
    func updateStatus() {
        
        let authStatus = locationManager.authorizationStatus
        status.value = .init(with: authStatus)
    }
}

//MARK: - CLLocationManagerDelegate

extension LocationAgent: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        updateStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let firstLocation = locations.first else {
            return
        }
        
        currentLoaction.value = firstLocation.coordinate
    }
}
