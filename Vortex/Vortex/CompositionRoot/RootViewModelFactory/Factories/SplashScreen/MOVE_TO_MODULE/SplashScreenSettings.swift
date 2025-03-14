//
//  SplashScreenSettings.swift
//  Vortex
//
//  Created by Igor Malyarov on 11.03.2025.
//

import Foundation
import SwiftUI
import VortexTools

#warning("move to SplashScreenCore")
struct SplashScreenSettings: Equatable {
    
    let logo: Logo
    let text: Text
    let subtext: Text?
    let footer: Logo
    
    let imageData: Result<Data, DataFailure>?
    let link: String
    let period: String
}

extension SplashScreenSettings {
    
    struct DataFailure: Error, Equatable {}
    
    struct Logo: Equatable {
        
        let color: String
        let shadow: Shadow
    }
    
    struct Text: Equatable {
        
        let color: String
        let size: CGFloat // TODO: ???
        let value: String
        let shadow: Shadow
    }
    
    struct Shadow: Equatable {
        
        let color: String
        let opacity: Double
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

extension SplashScreenSettings: Categorized {
    
    var category: String { period }
}
