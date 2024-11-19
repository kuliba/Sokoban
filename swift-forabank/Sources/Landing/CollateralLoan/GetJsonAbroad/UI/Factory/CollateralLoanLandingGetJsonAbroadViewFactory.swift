//
//  CollateralLoanLandingGetJsonAbroadViewFactory.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

public struct CollateralLoanLandingGetJsonAbroadViewFactory {

    let config: CollateralLoanLandingGetJsonAbroadViewConfig = .default

    public init() {}
}

public extension CollateralLoanLandingGetJsonAbroadViewFactory {
    
    func makeView(_ product: GetJsonAbroadData.Product) -> CollateralLoanLandingGetJsonAbroadBodyView {

        let headerView = makeHeaderView(with: product)
        let conditionsView = makeConditionsView(with: product)
        
        return .init(
            backgroundImage: product.marketing.image,
            headerView: headerView,
            conditionsView: conditionsView,
            config: .default,
            theme: product.theme.map()
        )
    }
}
