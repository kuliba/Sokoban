//
//  CollateralLoanLandingGetJsonAbroadViewFactory.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

public struct CollateralLoanLandingGetJsonAbroadViewFactory {

    let config: CollateralLoanLandingGetJsonAbroadViewConfig = .base

    public init() {}
}

public extension CollateralLoanLandingGetJsonAbroadViewFactory {
    
    func makeView(_ product: GetJsonAbroadData.Product) -> CollateralLoanLandingGetJsonAbroadBodyView {

        let headerView = makeHeaderView(with: product)
        
        return .init(
            headerView: headerView,
            theme: product.theme.map()
        )
    }
}
