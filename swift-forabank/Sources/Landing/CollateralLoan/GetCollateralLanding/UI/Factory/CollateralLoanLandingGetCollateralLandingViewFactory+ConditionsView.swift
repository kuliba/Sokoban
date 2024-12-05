//
//  CollateralLoanLandingGetCollateralLandingViewFactory+ConditionsView.swift
//
//
//  Created by Valentin Ozerov on 15.11.2024.
//

extension CollateralLoanLandingGetCollateralLandingViewFactory {
    
    func makeConditionsView(with product: GetCollateralLandingProduct)
        -> CollateralLoanLandingGetCollateralLandingConditionsView {

            .init(
                config: config,
                theme: product.theme.map(),
                conditions: product.conditions
            )
    }
}
