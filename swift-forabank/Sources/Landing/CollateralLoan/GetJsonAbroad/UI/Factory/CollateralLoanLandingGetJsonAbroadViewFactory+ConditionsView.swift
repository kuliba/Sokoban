//
//  CollateralLoanLandingGetJsonAbroadViewFactory+ConditionsView.swift
//
//
//  Created by Valentin Ozerov on 15.11.2024.
//

public extension CollateralLoanLandingGetJsonAbroadViewFactory {
    
    func makeConditionsView(with product: GetJsonAbroadData.Product)
        -> CollateralLoanLandingGetJsonAbroadConditionsView {

            .init(
                config: config,
                theme: product.theme.map(),
                conditions: product.conditions
            )
    }
}
