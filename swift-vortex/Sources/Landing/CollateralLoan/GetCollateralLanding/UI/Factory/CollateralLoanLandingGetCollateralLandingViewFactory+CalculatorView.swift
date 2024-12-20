//
//  CollateralLoanLandingGetCollateralLandingViewFactory+CalculatorView.swift
//
//
//  Created by Valentin Ozerov on 19.11.2024.
//

extension CollateralLoanLandingGetCollateralLandingViewFactory {
    
    func makeCalculatorView(with product: GetCollateralLandingProduct)
        -> CollateralLoanLandingGetCollateralLandingCalculatorView {

            .init(
                config: config,
                theme: product.theme.map()
            )
    }
}
