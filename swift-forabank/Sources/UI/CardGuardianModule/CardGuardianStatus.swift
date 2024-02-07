//
//  CardGuardianStatus.swift
//
//
//  Created by Andryusina Nataly on 07.02.2024.
//

public extension CardGuardian {
    
    enum CardGuardianStatus: Equatable, Hashable, Identifiable {
        
        public var id: Self {

            return self
        }

        case active
        case blockedUnlockAvailable
        case blockedUnlockNotAvailable
        case notActivated
    }
}
