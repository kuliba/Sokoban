//
//  CollateralLoanLandingGetShowcaseViewFactory+View.swift
//
//
//  Created by Valentin Ozerov on 14.10.2024.
//

import Foundation
import SwiftUI

extension CollateralLoanLandingGetShowcaseViewFactory {
    
    public func makeView(with model: CollateralLoanLandingGetShowcaseData.Product)
    -> CollateralLoanLandingGetShowcaseProductView {

        let headerView = makeHeaderView(with: model)
        let termsView = makeTermsView(with: model)
        let bulletsView = makeBulletsView(with: model)
        let imageView = makeImageView(with: model)
        let footerView = makeFooterView(with: model)
        
        return .init(
            headerView: headerView,
            termsView: termsView,
            bulletsView: bulletsView,
            imageView: imageView,
            footerView: footerView,
            theme: model.theme.map()
        )
    }
}
