//
//  CollateralLoanLandingGetJsonAbroadBodyView.swift
//
//
//  Created by Valentin Ozerov on 14.11.2024.
//

import SwiftUI

public struct CollateralLoanLandingGetJsonAbroadBodyView: View {
    
    let headerView: HeaderView
    let theme: Theme
    
    public var body: some View {

        VStack {
            
            headerView
        }
        .background(theme.backgroundColor)
    }
}

public extension CollateralLoanLandingGetJsonAbroadBodyView {
    
    typealias HeaderView = CollateralLoanLandingGetJsonAbroadHeaderView
    typealias Theme = CollateralLoanLandingGetJsonAbroadTheme
}
