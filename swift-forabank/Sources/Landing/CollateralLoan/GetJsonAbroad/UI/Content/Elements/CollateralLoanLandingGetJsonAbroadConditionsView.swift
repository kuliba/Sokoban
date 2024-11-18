//
//  CollateralLoanLandingGetJsonAbroadConditionsView.swift
//  
//
//  Created by Valentin Ozerov on 15.11.2024.
//

import SwiftUI

public struct CollateralLoanLandingGetJsonAbroadConditionsView: View {
    
    public let config: Config
    public let theme: Theme
    public let conditions: [Condition]
    
    public init(config: Config, theme: Theme, conditions: [Condition]) {
        self.config = config
        self.theme = theme
        self.conditions = conditions
    }
    
    public var body: some View {
        
        conditionsView
    }
    
    private var conditionsView: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: config.cornerRadius)
                .fill(Color.grayLightest)
                .frame(maxWidth: .infinity)
            
            conditionsListView
        }
        .padding(.leading, config.paddings.outerLeading)
        .padding(.trailing, config.paddings.outerTrailing)
    }
    
    private var conditionsListView: some View {
                
        VStack {
        
            config.conditions.header.text.text(
                withConfig: .init(
                    textFont: config.conditions.header.headerFont.font,
                    textColor: config.conditions.header.headerFont.foreground
                )
            )
            .padding(.horizontal, config.conditions.horizontalPadding)
            .padding(.vertical, config.conditions.listTopPadding)
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack {
                ForEach(conditions, id: \.title) {
                    
                    conditionView($0)
                }
                .padding(.horizontal, config.conditions.horizontalPadding)
                .padding(.bottom, config.conditions.spacing)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, config.conditions.listTopPadding)
        }
    }
    
    private func conditionView(_ condition: Condition) -> some View {
        
        HStack(spacing: 0) {
            
            VStack {
                
                // simulacrum
                Circle()
                    .fill(config.conditions.iconBackground)
                    .frame(
                        width: config.conditions.iconSize.width,
                        height: config.conditions.iconSize.height
                    )
                    .padding(.trailing, config.conditions.iconTrailingPadding)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                
                condition.title.text(
                    withConfig: .init(
                        textFont: config.conditions.titleFont.font,
                        textColor: config.conditions.titleFont.foreground
                    )
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                condition.subTitle.text(
                    withConfig: .init(
                        textFont: config.conditions.subTitleFont.font,
                        textColor: config.conditions.subTitleFont.foreground
                    )
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, config.conditions.subTitleTopPadding)
                
                Spacer()
            }
        }
    }
}

public extension CollateralLoanLandingGetJsonAbroadConditionsView {
    
    typealias Config = CollateralLoanLandingGetJsonAbroadViewConfig
    typealias Theme = CollateralLoanLandingGetJsonAbroadTheme
    typealias Condition = GetJsonAbroadData.Product.Condition
}

// MARK: - Previews

struct CollateralLoanLandingGetJsonAbroadView_Previews: PreviewProvider {
    
    static var previews: some View {
        CollateralLoanLandingGetJsonAbroadView(
            content: content,
            factory: factory
        )
    }
    
    static let cardData = GetJsonAbroadData.cardStub
    static let realEstateData = GetJsonAbroadData.realEstateStub
    static let content = Content(data: cardData)
    static let factory = Factory()
    
    typealias Content = CollateralLoanLandingGetJsonAbroadContent
    typealias Factory = CollateralLoanLandingGetJsonAbroadViewFactory
}
