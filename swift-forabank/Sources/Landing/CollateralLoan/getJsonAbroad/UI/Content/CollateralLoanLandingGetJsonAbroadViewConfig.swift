//
//  CollateralLoanLandingGetJsonAbroadViewConfig.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

import SwiftUI

public struct CollateralLoanLandingGetJsonAbroadViewConfig {
    
    public let fonts: Fonts
    public let backgroundImageHeight: CGFloat
    public let paddings: Paddings
    public let headerView: HeaderView
    public let conditionsView: ConditionsView
    public let calculatorView: CalculatorView
    public let frequentlyAskedQuestionView: FrequentlyAskedQuestionView
    public let documentsView: DocumentsView
    public let footerView: FooterView
        
    public init(
        fonts: Fonts,
        backgroundImageHeight: CGFloat,
        paddings: Paddings,
        headerView: HeaderView,
        conditionsView: ConditionsView,
        calculatorView: CalculatorView,
        frequentlyAskedQuestionView: FrequentlyAskedQuestionView,
        documentsView: DocumentsView,
        footerView: FooterView
    ) {
        self.fonts = fonts
        self.backgroundImageHeight = backgroundImageHeight
        self.paddings = paddings
        self.headerView = headerView
        self.conditionsView = conditionsView
        self.calculatorView = calculatorView
        self.frequentlyAskedQuestionView = frequentlyAskedQuestionView
        self.documentsView = documentsView
        self.footerView = footerView
    }
    
    public struct Fonts {
        
        public let body: FontConfig
        
        public init(body: FontConfig) {
            self.body = body
        }
    }
    
    public struct Paddings {}

    public struct HeaderView {
        
        public let height: CGFloat
        public let labelTag: LabelTag
        public let params: Params
        
        public init(
            height: CGFloat,
            labelTag: LabelTag,
            params: Params
        ) {
            self.height = height
            self.labelTag = labelTag
            self.params = params
        }
        
        public struct LabelTag {

            public let fontConfig: FontConfig
            public let cornerSize: CGFloat
            public let topOuterPadding: CGFloat
            public let leadingOuterPadding: CGFloat
            public let horizontalInnerPadding: CGFloat
            public let verticalInnerPadding: CGFloat
            public let rotationDegrees: CGFloat
            
            public init(
                fontConfig: FontConfig,
                cornerSize: CGFloat,
                topOuterPadding: CGFloat,
                leadingOuterPadding: CGFloat,
                horizontalInnerPadding: CGFloat,
                verticalInnerPadding: CGFloat,
                rotationDegrees: CGFloat
            ) {
                self.fontConfig = fontConfig
                self.cornerSize = cornerSize
                self.topOuterPadding = topOuterPadding
                self.leadingOuterPadding = leadingOuterPadding
                self.horizontalInnerPadding = horizontalInnerPadding
                self.verticalInnerPadding = verticalInnerPadding
                self.rotationDegrees = rotationDegrees
            }
        }
        
        public struct Params {
            
            public let fontConfig: FontConfig
            public let spacing: CGFloat
            public let leadingPadding: CGFloat
            public let topPadding: CGFloat
            
            public init(
                fontConfig: FontConfig,
                spacing: CGFloat,
                leadingPadding: CGFloat,
                topPadding: CGFloat
            ) {
                self.fontConfig = fontConfig
                self.spacing = spacing
                self.leadingPadding = leadingPadding
                self.topPadding = topPadding
            }
        }
    }

    public struct ConditionsView {}

    public struct CalculatorView {}
    
    public struct FrequentlyAskedQuestionView {}

    public struct DocumentsView {}

    public struct FooterView {}
    
    public struct FontConfig {
        
        public let font: Font
        public let foregroundColor: Color
        public let backgroundColor: Color
        
        public init(
            _ font: Font,
            foregroundColor: Color = .primary,
            backgroundColor: Color = Color(UIColor.systemBackground)
        ) {
            self.font = font
            self.foregroundColor = foregroundColor
            self.backgroundColor = backgroundColor
        }
    }
}

extension CollateralLoanLandingGetJsonAbroadViewConfig {

    static let `default` = Self(
        fonts: .init(body: FontConfig(Font.system(size: 14))),
        backgroundImageHeight: 703,
        paddings: .init(),
        headerView: .init(
            height: 642,
            labelTag: .init(
                fontConfig: .init(
                    Font.system(size: 32).bold(),
                    foregroundColor: .white,
                    backgroundColor: Color(UIColor(red: 255/255, green: 54/255, blue: 54/255, alpha: 1))
                ),
                cornerSize: 10,
                topOuterPadding: 215,
                leadingOuterPadding: 25,
                horizontalInnerPadding: 10,
                verticalInnerPadding: 6,
                rotationDegrees: -5
            ),
            params: .init(
                fontConfig: .init(Font.system(size: 14)),
                spacing: 20,
                leadingPadding: 20,
                topPadding: 30
            )
        ),
        conditionsView: .init(),
        calculatorView: .init(),
        frequentlyAskedQuestionView: .init(),
        documentsView: .init(),
        footerView: .init()
    )
}
