//
//  LocationAgentMock.swift
//  ForaBank
//
//  Created by Max Gribov on 12.04.2022.
//

import Foundation
import Combine
import CoreLocation

class LocationAgentMock: LocationAgentProtocol {
    
    let status: CurrentValueSubject<LocationAgentStatus, Never> = .init(.disabled)
    let currentLoaction: CurrentValueSubject<CLLocationCoordinate2D?, Never> = .init(nil)
    
    func requestPermissions() {
        
    }
    
    func start() {
        
    }
    
    func stop() {
        
    }
}
