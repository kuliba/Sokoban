//
//  CollateralLoanLandingShowCaseTheme.swift
//
//
//  Created by Valentin Ozerov on 09.10.2024.
//

import SwiftUI

public struct CollateralLoanLandingShowCaseTheme {

    let foregroundColor: Color
    let backgroundColor: Color
}

extension CollateralLoanLandingShowCaseTheme {

    public static func map(_ modelTheme: CollateralLoanLandingShowCaseUIModel.Product.Theme?) -> Self {

        switch modelTheme {
        case .gray:
            return .gray
        case .white:
            return .white
        default:
            return .white
        }
    }
}

extension CollateralLoanLandingShowCaseTheme: Equatable {}
