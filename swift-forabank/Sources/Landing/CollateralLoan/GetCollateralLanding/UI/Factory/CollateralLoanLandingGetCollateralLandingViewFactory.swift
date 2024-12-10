//
//  CollateralLoanLandingGetCollateralLandingViewFactory.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

struct CollateralLoanLandingGetCollateralLandingViewFactory {

    let config: CollateralLoanLandingGetCollateralLandingViewConfig = .default
}

extension CollateralLoanLandingGetCollateralLandingViewFactory {
    
    func makeView(_ product: GetCollateralLandingProduct) -> CollateralLoanLandingGetCollateralLandingBodyView {

        let headerView = makeHeaderView(with: product)
        let conditionsView = makeConditionsView(with: product)
        let calculatorView = makeCalculatorView(with: product)
        let frequentlyAskedQuestionsView = makeFrequentlyAskedQuestionsView(with: product)
        let documentsView = makeDocumentsView(with: product)
        
        return .init(
            backgroundImage: product.marketing.image,
            headerView: headerView,
            conditionsView: conditionsView,
            calculatorView: calculatorView,
            frequentlyAskedQuestionsView: frequentlyAskedQuestionsView,
            documentsView: documentsView,
            config: .default,
            theme: product.theme.map()
        )
    }
}
