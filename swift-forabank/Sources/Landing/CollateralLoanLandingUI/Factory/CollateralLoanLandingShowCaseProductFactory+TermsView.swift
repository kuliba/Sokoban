//
//  CollateralLoanLandingShowCaseProductFactory+TermsView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

extension CollateralLoanLandingShowCaseProductFactory {

    func makeTermsView(with model: CollateralLoanLandingShowCaseUIModel.Product)
        -> CollateralLoanLandingShowCaseProductTermsView? {

            guard
                let params = model.keyMarketingParams,
                params.term != nil || params.amount != nil || params.rate != nil
            else {
                return nil
            }
            
            return .init(
                params: params,
                config: config,
                theme: CollateralLoanLandingShowCaseTheme.map(model.theme)
            )
    }
}
