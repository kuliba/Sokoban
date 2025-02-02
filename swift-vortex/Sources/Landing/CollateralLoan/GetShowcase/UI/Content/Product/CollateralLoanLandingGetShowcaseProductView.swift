//
//  CollateralLoanLandingGetShowcaseProductView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

import SwiftUI

public struct CollateralLoanLandingGetShowcaseProductView: View {
    
    let product: Product
    let event: (GetShowcaseViewEvent.External) -> Void
    let config: Config
    let factory: Factory
    
    public var body: some View {

        VStack {
            
            HeaderView(
                title: product.name,
                config: config,
                theme: product.theme.map()
            )
            
            TermsView(
                params: product.keyMarketingParams,
                config: config,
                theme: product.theme.map()
            )
            
            BulletsView(
                header: product.features.header,
                bulletsData: product.features.list.map { ($0.bullet, $0.text) },
                config: config,
                theme: product.theme.map()
            )

            ImageView(
                url: product.image,
                config: config,
                makeImageViewByURL: factory.makeImageViewByURL
            )
            
            FooterView(
                landingId: product.landingId,
                termsUrl: product.terms,
                event: event,
                config: config,
                theme: product.theme.map()
            )
        }
        .background(product.theme.map().backgroundColor)
    }
}

extension CollateralLoanLandingGetShowcaseProductView {
    
    typealias HeaderView = CollateralLoanLandingGetShowcaseProductHeaderView
    typealias TermsView = CollateralLoanLandingGetShowcaseProductTermsView
    typealias BulletsView = CollateralLoanLandingGetShowcaseProductBulletsView
    typealias ImageView = CollateralLoanLandingGetShowcaseProductImageView
    typealias FooterView = CollateralLoanLandingGetShowcaseProductFooterView
    typealias Theme = CollateralLoanLandingGetShowcaseTheme
    typealias Product = CollateralLoanLandingGetShowcaseData.Product
    typealias Config = CollateralLoanLandingGetShowcaseViewConfig
    typealias Event = GetShowcaseDomain.Event
    typealias Factory = CollateralLoanLandingGetShowcaseViewFactory
}
