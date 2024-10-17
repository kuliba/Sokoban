//
//  CollateralLoanLandingShowCaseContent.swift
//
//
//  Created by Valentin Ozerov on 10.10.2024.
//

import Foundation

public final class CollateralLoanLandingShowCaseContent {

    enum ViewState {

        case content
        case spinner
    }
    
    let model: Model
    
    @Published var viewState = ViewState.spinner
    
    init(
        model: Model
    ) {
        
        self.model = model
    }
}

extension CollateralLoanLandingShowCaseContent {
    
    typealias Model = CollateralLoanLandingShowCaseUIModel
}
