//
//  CollateralLoanLandingGetJsonAbroadViewFactory.swift
//
//
//  Created by Valentin Ozerov on 14.11.2024.
//

public extension CollateralLoanLandingGetJsonAbroadViewFactory {
    
    func makeHeaderView(with product: GetJsonAbroadData.Product)
        -> CollateralLoanLandingGetJsonAbroadHeaderView {

            .init(
                labelTag: product.marketing.labelTag,
                params: product.marketing.params,
                config: config,
                theme: product.theme.map()
            )
    }
}
