//
//  LandingState.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 03.03.2025.
//

import Foundation
import OrderCard
    
public struct LandingState<Landing> {
    
    public var isLoading = false
    public var status: Status? = nil
    
    public init(
        isLoading: Bool = false,
        status: Status? = nil
    ) {
        self.isLoading = isLoading
        self.status = status
    }
    
    public enum Status {
        
        case landing(Landing)
        case failure(LoadFailure)
        case mix(Landing, LoadFailure)
    }
}
