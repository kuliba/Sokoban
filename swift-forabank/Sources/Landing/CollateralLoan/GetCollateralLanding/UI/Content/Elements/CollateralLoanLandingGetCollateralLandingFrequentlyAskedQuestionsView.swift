//
//  CollateralLoanLandingGetCollateralLandingFrequentlyAskedQuestionsView.swift
//
//
//  Created by Valentin Ozerov on 10.12.2024.
//

import SwiftUI
import DropDownTextListComponent

struct CollateralLoanLandingGetCollateralLandingFrequentlyAskedQuestionsView: View {
    
    private let config: Config
    private let theme: Theme
    private let product: Product

    init(config: Config, theme: Theme, product: Product) {
        self.config = config
        self.theme = theme
        self.product = product
    }
    
    var body: some View {
        
        DropDownTextListView(
            config: config.frequentlyAskedQuestions,
            list: product.dropDownTextList
        )
    }
}

extension CollateralLoanLandingGetCollateralLandingFrequentlyAskedQuestionsView {
    
    typealias Config = CollateralLoanLandingGetCollateralLandingViewConfig
    typealias Theme = CollateralLoanLandingGetCollateralLandingTheme
    typealias Product = GetCollateralLandingProduct
}

// MARK: - Previews

struct CollateralLoanLandingGetCollateralLandingFrequentlyAskedQuestionsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CollateralLoanLandingGetCollateralLandingFrequentlyAskedQuestionsView(
            config: .default,
            theme: .gray,
            product: cardData
        )
    }
    
    static let cardData = GetCollateralLandingProduct.cardStub
    static let realEstateData = GetCollateralLandingProduct.realEstateStub
}
