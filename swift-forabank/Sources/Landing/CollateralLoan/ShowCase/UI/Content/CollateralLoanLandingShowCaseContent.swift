//
//  CollateralLoanLandingShowCaseContent.swift
//
//
//  Created by Valentin Ozerov on 10.10.2024.
//

import Foundation

public final class CollateralLoanLandingShowCaseContent: ObservableObject {
        
    @Published var viewState = ViewState.spinner
    
    let data: ShowCaseData

    init(
        data: ShowCaseData
    ) {
        
        self.data = data
    }
}

extension CollateralLoanLandingShowCaseContent {

    enum ViewState {
        
        case content
        case spinner
    }

    typealias ShowCaseData = CollateralLoanLandingShowCaseData
}
