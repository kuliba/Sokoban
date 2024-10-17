//
//  CollateralLoanLandingShowCaseProductView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

import SwiftUI

struct CollateralLoanLandingShowCaseProductView: View {
    
    let headerView: HeaderView
    let termsView: TermsView
    let bulletsView: BulletsView
    let imageView: ImageView
    let footerView: FooterView
    
    let theme: Theme
    
    var body: some View {

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

extension CollateralLoanLandingShowCaseProductView {
    
    typealias HeaderView = CollateralLoanLandingShowCaseProductHeaderView
    typealias TermsView = CollateralLoanLandingShowCaseProductTermsView
    typealias BulletsView = CollateralLoanLandingShowCaseProductBulletsView
    typealias ImageView = CollateralLoanLandingShowCaseProductImageView
    typealias FooterView = CollateralLoanLandingShowCaseProductFooterView
    typealias Theme = CollateralLoanLandingShowCaseTheme
}
