//
//  CollateralLoanLandingGetCollateralLandingViewFactory+ConditionsView.swift
//
//
//  Created by Valentin Ozerov on 15.11.2024.
//

extension CollateralLoanLandingGetCollateralLandingViewFactory {
    
    func makeConditionsView(with product: GetCollateralLandingProduct)
        -> CollateralLoanLandingGetCollateralLandingConditionsView? {

            guard
                !product.conditions.isEmpty
            else { return nil }
            
            return .init(
                config: config,
                theme: product.theme.map(),
                conditions: product.conditions
            )
    }
}
