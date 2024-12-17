//
//  Model+Location.swift
//  ForaBank
//
//  Created by Max Gribov on 12.04.2022.
//

import Foundation

//MARK: - Action

extension ModelAction {
    
    enum Location {
  
        enum Updates {
        
            struct Start: Action {}
            
            struct Stop: Action {}
        }
    }
}

//MARK: - Handlers

extension Model {
    
    func handleLocationUpdatesStart() {
        
        if locationAgent.status.value == .disabled {
            
            locationAgent.requestPermissions()
        }
        
        locationAgent.start()
    }
    
    func handleLocationUpdateStop() {
        
        locationAgent.stop()
    }
}
