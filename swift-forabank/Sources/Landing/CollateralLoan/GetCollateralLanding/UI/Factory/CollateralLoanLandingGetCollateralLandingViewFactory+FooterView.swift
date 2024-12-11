//
//  CollateralLoanLandingGetCollateralLandingViewFactory+FooterView.swift
//
//
//  Created by Valentin Ozerov on 11.12.2024.
//

extension CollateralLoanLandingGetCollateralLandingViewFactory {
    
    func makeFooterView(with product: GetCollateralLandingProduct)
        -> CollateralLoanLandingGetCollateralLandingFooterView {

            .init(
                config: config,
                theme: product.theme.map(),
                action: {}
            )
    }
}
