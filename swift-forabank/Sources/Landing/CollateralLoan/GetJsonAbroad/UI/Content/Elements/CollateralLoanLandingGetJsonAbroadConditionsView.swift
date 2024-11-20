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
            
            conditionsListView(config.conditions)
        }
        .padding(.leading, config.paddings.outerLeading)
        .padding(.trailing, config.paddings.outerTrailing)
    }
    
    private func conditionsListView(_ config: Config.Conditions) -> some View {
                
        VStack {
        
            config.header.text.text(
                withConfig: .init(
                    textFont: config.header.headerFont.font,
                    textColor: config.header.headerFont.foreground
                )
            )
            .padding(.horizontal, config.horizontalPadding)
            .padding(.vertical, config.listTopPadding)
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack {
                
                ForEach(conditions, id: \.title) {
                    
                    conditionView($0, config: config)
                }
                .padding(.horizontal, config.horizontalPadding)
                .padding(.bottom, config.spacing)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, config.listTopPadding)
        }
    }
    
    private func conditionView(_ condition: Condition, config: Config.Conditions) -> some View {
        
        HStack(spacing: 0) {
            
            VStack {
                
                // simulacrum
                Circle()
                    .fill(config.iconBackground)
                    .frame(
                        width: config.iconSize.width,
                        height: config.iconSize.height
                    )
                    .padding(.trailing, config.iconTrailingPadding)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                
                condition.title.text(
                    withConfig: .init(
                        textFont: config.titleFont.font,
                        textColor: config.titleFont.foreground
                    )
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                condition.subTitle.text(
                    withConfig: .init(
                        textFont: config.subTitleFont.font,
                        textColor: config.subTitleFont.foreground
                    )
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, config.subTitleTopPadding)
                
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
