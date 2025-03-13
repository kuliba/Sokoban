//
//  SplashScreenState.swift
//
//
//  Created by Igor Malyarov on 13.03.2025.
//

import SwiftUI

public struct SplashScreenState: Equatable {
    
    public var phase: Phase
    public let settings: Settings
    
    public init(
        phase: Phase,
        settings: Settings
    ) {
        self.phase = phase
        self.settings = settings
    }
}

extension SplashScreenState {
    
    public enum Phase: Equatable {
        
        case cover
        case warm
        case presented
        case hidden
    }
    
    public struct Settings: Equatable {
        
        public let image: Image
        
        public init(
            image: Image
        ) {
            self.image = image
        }
    }
}
