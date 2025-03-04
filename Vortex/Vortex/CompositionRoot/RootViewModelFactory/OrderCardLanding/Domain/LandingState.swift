//
//  LandingState.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 03.03.2025.
//

import Foundation
import OrderCard

extension OrderCardLandingDomain {
    
    struct LandingState<Landing> {
        
        var isLoading = false
        var status: Status? = nil

        enum Status {
            
            case landing(Landing)
            case failure(LoadFailure)
            case mix(Landing, LoadFailure)
        }
    }
}
