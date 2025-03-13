//
//  Model+splash.swift
//  Vortex
//
//  Created by Igor Malyarov on 12.03.2025.
//

import Combine

extension Model {
    
    var pinOrSensorAuthOK: some Publisher<Void, Never> {
        
        let pinAuthOk = action
            .compactMap { $0 as? ModelAction.Auth.Pincode.Check.Response }
            .filter {
                
                switch $0 {
                case .correct: return true
                default:       return false
                }
            }
            .map { _ in () }
        
        let sensorAuthOK = action
            .compactMap { $0 as? ModelAction.Auth.Sensor.Evaluate.Response }
            .filter {
                
                switch $0 {
                case .success: return true
                default:       return false
                }
            }
            .map { _ in () }
        
        return pinAuthOk.merge(with: sensorAuthOK)
    }
    
    var hideCoverStartSplash: some Publisher<Void, Never> {
        
        auth.compactMap {
        
            switch $0 {
            case .authorized: return ()
            default:          return nil
            }
        }
    }
}
