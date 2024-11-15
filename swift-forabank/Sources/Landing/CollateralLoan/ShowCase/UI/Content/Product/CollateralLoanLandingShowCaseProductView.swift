//
//  CollateralLoanLandingShowCaseProductView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

import SwiftUI

public struct CollateralLoanLandingShowCaseProductView: View {
    
    public let headerView: HeaderView
    public let termsView: TermsView
    public let bulletsView: BulletsView
    public let imageView: ImageView
    public let footerView: FooterView
    public let theme: Theme
    
    public init(
        headerView: HeaderView,
        termsView: TermsView,
        bulletsView: BulletsView,
        imageView: ImageView,
        footerView: FooterView,
        theme: Theme
    ) {
        self.headerView = headerView
        self.termsView = termsView
        self.bulletsView = bulletsView
        self.imageView = imageView
        self.footerView = footerView
        self.theme = theme
    }
    
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

public extension CollateralLoanLandingShowCaseProductView {
    
    typealias HeaderView = CollateralLoanLandingShowCaseProductHeaderView
    typealias TermsView = CollateralLoanLandingShowCaseProductTermsView
    typealias BulletsView = CollateralLoanLandingShowCaseProductBulletsView
    typealias ImageView = CollateralLoanLandingShowCaseProductImageView
    typealias FooterView = CollateralLoanLandingShowCaseProductFooterView
    typealias Theme = CollateralLoanLandingShowCaseTheme
}
