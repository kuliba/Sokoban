//
//  CardGuardian+State.swift
//
//
//  Created by Andryusina Nataly on 01.02.2024.
//

import Foundation

public extension CardGuardian {
    
    enum State: Equatable {
        
        case buttonTapped(ButtonEvent, CardGuardianStatus)
    }
}
