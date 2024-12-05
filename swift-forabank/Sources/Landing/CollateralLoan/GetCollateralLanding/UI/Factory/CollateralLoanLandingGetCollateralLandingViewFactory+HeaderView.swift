//
//  CollateralLoanLandingGetCollateralLandingViewFactory.swift
//
//
//  Created by Valentin Ozerov on 14.11.2024.
//

extension CollateralLoanLandingGetCollateralLandingViewFactory {
    
    func makeHeaderView(with product: GetCollateralLandingProduct)
        -> CollateralLoanLandingGetCollateralLandingHeaderView {

            .init(
                labelTag: product.marketing.labelTag,
                params: product.marketing.params,
                config: config,
                theme: product.theme.map()
            )
    }
}
