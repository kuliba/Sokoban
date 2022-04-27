//
//  LocationAgentProtocol.swift
//  ForaBank
//
//  Created by Max Gribov on 11.04.2022.
//

import Foundation
import Combine
import CoreLocation

protocol LocationAgentProtocol {
    
    var status: CurrentValueSubject<LocationAgentStatus, Never> { get }
    var currentLoaction: CurrentValueSubject<CLLocationCoordinate2D?, Never> { get }
    func requestPermissions()
    func start()
    func stop()
}

enum LocationAgentStatus {
    
    case disabled
    case available
    
    init(with status: CLAuthorizationStatus) {
        
        switch status {
        case .authorized, .authorizedAlways, .authorizedWhenInUse:
            self = .available
            
        default:
            self = .disabled
        }
    }
}
