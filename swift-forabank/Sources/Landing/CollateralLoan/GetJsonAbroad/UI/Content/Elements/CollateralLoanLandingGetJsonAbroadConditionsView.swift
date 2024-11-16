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
            
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.grayLightest)
                .frame(maxWidth: .infinity)
                .padding(.leading, 16)
                .padding(.trailing, 15)
            
            conditionsListView
        }
    }
    
    private var conditionsListView: some View {
        
        Text("Выгодные условия")
        
        VStack {
            ForEach(conditions, id: \.title) {
                
                conditionView($0)
            }
        }
    }
    
    private func conditionView(_ condition: Condition) -> some View {
        
        Text(condition.title)
    }
}

public extension CollateralLoanLandingGetJsonAbroadConditionsView {
    
    typealias Config = CollateralLoanLandingGetJsonAbroadViewConfig
    typealias Theme = CollateralLoanLandingGetJsonAbroadTheme
    typealias Condition = GetJsonAbroadData.Product.Condition
}

// MARK: - Previews

struct CollateralLoanLandingGetJsonAbroadConditionsView_Previews: PreviewProvider {
    
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

