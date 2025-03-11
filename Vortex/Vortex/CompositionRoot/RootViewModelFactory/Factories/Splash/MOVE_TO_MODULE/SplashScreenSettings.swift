//
//  SplashScreenSettings.swift
//  Vortex
//
//  Created by Igor Malyarov on 11.03.2025.
//

import Foundation
import VortexTools

#warning("move to SplashScreenCore")
struct SplashScreenSettings: Equatable {
    
    let imageData: Result<Data, DataFailure>?
    let link: String
    let period: String
    
    struct DataFailure: Error, Equatable {}
}

extension SplashScreenSettings: Categorized {
    
    var category: String { period }
}
