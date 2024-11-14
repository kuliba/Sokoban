//
//  CollateralLoanLandingGetJsonAbroadViewConfig.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

import SwiftUI

public struct CollateralLoanLandingGetJsonAbroadViewConfig {
    
    public let fonts: Fonts
    public let paddings: Paddings
    public let headerView: HeaderView
    public let conditionsView: ConditionsView
    public let calculatorView: CalculatorView
    public let frequentlyAskedQuestionView: FrequentlyAskedQuestionView
    public let documentsView: DocumentsView
    public let footerView: FooterView
        
    public init(
        fonts: Fonts,
        paddings: Paddings,
        headerView: HeaderView,
        conditionsView: ConditionsView,
        calculatorView: CalculatorView,
        frequentlyAskedQuestionView: FrequentlyAskedQuestionView,
        documentsView: DocumentsView,
        footerView: FooterView
    ) {
        self.fonts = fonts
        self.paddings = paddings
        self.headerView = headerView
        self.conditionsView = conditionsView
        self.calculatorView = calculatorView
        self.frequentlyAskedQuestionView = frequentlyAskedQuestionView
        self.documentsView = documentsView
        self.footerView = footerView
    }
    
    public struct Fonts {
        
        public let body: Font
        
        public init(body: Font) {
            self.body = body
        }
    }
    
    public struct Paddings {}

    public struct HeaderView {}

    public struct ConditionsView {}

    public struct CalculatorView {}
    
    public struct FrequentlyAskedQuestionView {}

    public struct DocumentsView {}

    public struct FooterView {}
}

extension CollateralLoanLandingGetJsonAbroadViewConfig {

    static let base = Self(
        fonts: .init(body: Font.system(size: 14)),
        paddings: .init(),
        headerView: .init(),
        conditionsView: .init(),
        calculatorView: .init(),
        frequentlyAskedQuestionView: .init(),
        documentsView: .init(),
        footerView: .init()
    )
}
