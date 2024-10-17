//
//  CollateralLoanLandingShowCaseTheme.swift
//
//
//  Created by Valentin Ozerov on 09.10.2024.
//

import SwiftUI

public struct CollateralLoanLandingShowCaseTheme {

    public let foregroundColor: Color
    public let backgroundColor: Color
    
    public init(foregroundColor: Color, backgroundColor: Color) {
     
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }
}

extension CollateralLoanLandingShowCaseTheme: Equatable {}
