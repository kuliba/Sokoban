//
//  CollateralLoanLandingGetShowcaseProductView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

import SwiftUI

public struct CollateralLoanLandingGetShowcaseProductView: View {
    
    let headerView: HeaderView
    let termsView: TermsView
    let bulletsView: BulletsView
    let imageView: ImageView
    let footerView: FooterView
    let theme: Theme
    
    public var body: some View {

        VStack {
            
            headerView
            termsView
            bulletsView
            imageView
            footerView
        }
        .background(theme.backgroundColor)
    }
}

extension CollateralLoanLandingGetShowcaseProductView {
    
    typealias HeaderView = CollateralLoanLandingGetShowcaseProductHeaderView
    typealias TermsView = CollateralLoanLandingGetShowcaseProductTermsView
    typealias BulletsView = CollateralLoanLandingGetShowcaseProductBulletsView
    typealias ImageView = CollateralLoanLandingGetShowcaseProductImageView
    typealias FooterView = CollateralLoanLandingGetShowcaseProductFooterView
    typealias Theme = CollateralLoanLandingGetShowcaseTheme
}
