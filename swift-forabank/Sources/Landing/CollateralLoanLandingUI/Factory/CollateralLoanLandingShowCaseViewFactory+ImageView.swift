//
//  CollateralLoanLandingShowCaseViewFactory+ImageView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

extension CollateralLoanLandingShowCaseViewFactory {
    
    func makeImageView(with model: CollateralLoanLandingShowCaseData.Product)
        -> CollateralLoanLandingShowCaseProductImageView {

            .init(
                url: model.image,
                config: config
            )
    }
}
