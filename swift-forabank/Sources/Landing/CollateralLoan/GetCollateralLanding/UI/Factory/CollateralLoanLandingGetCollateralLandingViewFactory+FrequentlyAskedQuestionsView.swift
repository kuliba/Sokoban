//
//  CollateralLoanLandingGetCollateralLandingViewFactory+FrequentlyAskedQuestionsView.swift
//
//
//  Created by Valentin Ozerov on 10.12.2024.
//

extension CollateralLoanLandingGetCollateralLandingViewFactory {
    
    func makeFrequentlyAskedQuestionsView(with product: GetCollateralLandingProduct)
    -> CollateralLoanLandingGetCollateralLandingFrequentlyAskedQuestionsView? {
        
        guard
            !product.frequentlyAskedQuestions.isEmpty
        else { return nil}
        
        return .init(config: config,
                     theme: product.theme.map(),
                     product: product
        )
    }
}
