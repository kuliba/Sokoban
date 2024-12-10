//
//  CollateralLoanLandingGetCollateralLandingDocumentsView.swift
//
//
//  Created by Valentin Ozerov on 10.12.2024.
//

import SwiftUI

struct CollateralLoanLandingGetCollateralLandingDocumentsView: View {

    private let config: Config
    private let theme: Theme
    private let documents: [Document]
    
    init(config: Config, theme: Theme, documents: [Document]) {
        self.config = config
        self.theme = theme
        self.documents = documents
    }
    
    var body: some View {
        
        Text("CollateralLoanLandingGetCollateralLandingDocumentsView")
    }
}

extension CollateralLoanLandingGetCollateralLandingDocumentsView {
    
    typealias Config = CollateralLoanLandingGetCollateralLandingViewConfig
    typealias Theme = CollateralLoanLandingGetCollateralLandingTheme
    typealias Document = GetCollateralLandingProduct.Document
}
