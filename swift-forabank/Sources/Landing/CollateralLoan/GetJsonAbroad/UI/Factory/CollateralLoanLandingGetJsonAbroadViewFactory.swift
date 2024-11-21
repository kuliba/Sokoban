//
//  CollateralLoanLandingGetJsonAbroadViewFactory.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

struct CollateralLoanLandingGetJsonAbroadViewFactory {

    let config: CollateralLoanLandingGetJsonAbroadViewConfig = .default
}

extension CollateralLoanLandingGetJsonAbroadViewFactory {
    
    func makeView(_ product: GetJsonAbroadData.Product) -> CollateralLoanLandingGetJsonAbroadBodyView {

        let headerView = makeHeaderView(with: product)
        let conditionsView = makeConditionsView(with: product)
        let calculatorView = makeCalculatorView(with: product)
        
        return .init(
            backgroundImage: product.marketing.image,
            headerView: headerView,
            conditionsView: conditionsView,
            calculatorView: calculatorView,
            config: .default,
            theme: product.theme.map()
        )
    }
}
