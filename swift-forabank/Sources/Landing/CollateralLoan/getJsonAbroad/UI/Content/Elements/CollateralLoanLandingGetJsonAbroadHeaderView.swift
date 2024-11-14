//
//  CollateralLoanLandingGetJsonAbroadHeaderView.swift
//
//
//  Created by Valentin Ozerov on 14.11.2024.
//

import SwiftUI

public struct CollateralLoanLandingGetJsonAbroadHeaderView: View {
    
    let title: String
    let config: Config
    let theme: Theme

    public var body: some View {

        Text(title)
    }
}

public extension CollateralLoanLandingGetJsonAbroadHeaderView {
    
    typealias Config = CollateralLoanLandingGetJsonAbroadViewConfig
    typealias Theme = CollateralLoanLandingGetJsonAbroadTheme
}
