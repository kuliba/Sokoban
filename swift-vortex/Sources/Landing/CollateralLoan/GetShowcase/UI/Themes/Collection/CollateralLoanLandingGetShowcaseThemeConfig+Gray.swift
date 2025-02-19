//
//  CollateralLoanLandingGetShowcaseThemeConfig+Gray.swift
//
//
//  Created by Valentin Ozerov on 12.11.2024.
//

import SwiftUI

extension CollateralLoanLandingGetShowcaseTheme {

    public static let gray = Self(
        foregroundColor: .black,
        backgroundColor: .lightGreyBackground
    )
}

private extension Color {
    
    static let lightGreyBackground: Self = .init(red: 0.9647, green: 0.9647, blue: 0.97)
}
