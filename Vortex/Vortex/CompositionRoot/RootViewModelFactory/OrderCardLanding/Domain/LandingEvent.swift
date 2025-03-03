//
//  LandingEvent.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 03.03.2025.
//

import Foundation
import OrderCard

extension OrderCardLandingDomain {
    
    enum LandingEvent<Landing> {
        
        case dismissInformer
        case load
        case loadResult(Result<Landing, LoadFailure>)
    }
}
