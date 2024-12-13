//
//  GetCollateralLandingTheme.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

import SwiftUI

public struct GetCollateralLandingTheme {

    public let foregroundColor: Color
    public let backgroundColor: Color
    
    public init(foregroundColor: Color, backgroundColor: Color) {
     
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }
}

extension GetCollateralLandingTheme: Equatable {}
