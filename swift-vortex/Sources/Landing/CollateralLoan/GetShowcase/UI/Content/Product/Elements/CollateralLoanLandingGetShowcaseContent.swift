//
//  CollateralLoanLandingGetShowcaseContent.swift
//
//
//  Created by Valentin Ozerov on 10.10.2024.
//

import Foundation

public final class CollateralLoanLandingGetShowcaseContent: ObservableObject {
        
    @Published var viewState = ViewState.spinner
    
    let data: GetShowcaseData

    init(
        data: GetShowcaseData
    ) {
        
        self.data = data
    }
}

extension CollateralLoanLandingGetShowcaseContent {

    enum ViewState {
        
        case content
        case spinner
    }

    typealias GetShowcaseData = CollateralLoanLandingGetShowcaseData
}
