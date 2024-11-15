//
//  CollateralLoanLandingShowCaseViewFactory+View.swift
//
//
//  Created by Valentin Ozerov on 14.10.2024.
//

import Foundation
import SwiftUI

public extension CollateralLoanLandingShowCaseViewFactory {
    
    func makeView(with model: CollateralLoanLandingShowCaseData.Product)
    -> CollateralLoanLandingShowCaseProductView {

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
