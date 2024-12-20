//
//  CollateralLoanLandingGetShowcaseViewFactory+ImageView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

extension CollateralLoanLandingGetShowcaseViewFactory {
    
    func makeImageView(with model: CollateralLoanLandingGetShowcaseData.Product)
        -> CollateralLoanLandingGetShowcaseProductImageView {

            .init(
                url: model.image,
                config: config
            )
    }
}
