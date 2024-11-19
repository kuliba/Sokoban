//
//  CollateralLoanLandingGetJsonAbroadBodyView.swift
//
//
//  Created by Valentin Ozerov on 14.11.2024.
//

import SwiftUI

struct CollateralLoanLandingGetJsonAbroadBodyView: View {
    
    let backgroundImage: String
    let headerView: HeaderView
    let conditionsView: ConditionsView
    let calculatorView: CalculatorView
    let config: Config
    let theme: Theme
    
    var body: some View {

        ScrollView {
            ZStack {
                
                backgroundImageView
                contentView
            }
            .background(theme.backgroundColor)
        }
        .ignoresSafeArea()
    }
    
    typealias Config = CollateralLoanLandingGetJsonAbroadViewConfig
}

private extension CollateralLoanLandingGetJsonAbroadBodyView {
    
    var backgroundImageView: some View {
        
        VStack {
            // TODO: Need to realized
            // Image(backgroundImage)
            
            // simulacrum
            if #available(iOS 15.0, *) {
                Color.teal
                    .frame(height: config.backgroundImageHeight)
            }
            
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .ignoresSafeArea(edges: .all)
    }
    
    var contentView: some View {
        
        VStack {
            
            headerView
            conditionsView
            calculatorView
        }
        .background(Color.clear)
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.bottom, config.paddings.outerBottom)
        .ignoresSafeArea(edges: .all)
    }
}

extension CollateralLoanLandingGetJsonAbroadBodyView {
    
    typealias HeaderView = CollateralLoanLandingGetJsonAbroadHeaderView
    typealias ConditionsView = CollateralLoanLandingGetJsonAbroadConditionsView
    typealias CalculatorView = CollateralLoanLandingGetJsonAbroadCalculatorView
    typealias Theme = CollateralLoanLandingGetJsonAbroadTheme
}
