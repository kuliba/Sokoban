//
//  CollateralLoanLandingGetJsonAbroadViewFactory+CalculatorView.swift
//
//
//  Created by Valentin Ozerov on 19.11.2024.
//

extension CollateralLoanLandingGetJsonAbroadViewFactory {
    
    func makeCalculatorView(with product: GetJsonAbroadData.Product)
        -> CollateralLoanLandingGetJsonAbroadCalculatorView {

            .init(
                config: config,
                theme: product.theme.map()
            )
    }
}
