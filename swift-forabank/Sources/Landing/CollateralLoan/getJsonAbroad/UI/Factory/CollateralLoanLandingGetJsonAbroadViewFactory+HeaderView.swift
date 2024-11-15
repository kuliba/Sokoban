//
//  File.swift
//  
//
//  Created by Valentin Ozerov on 14.11.2024.
//

public extension CollateralLoanLandingGetJsonAbroadViewFactory {
    
    func makeHeaderView(with product: GetJsonAbroadData.Product)
        -> CollateralLoanLandingGetJsonAbroadHeaderView {

            .init(
                title: product.name,
                config: config,
                theme: product.theme.map()
            )
    }
}
