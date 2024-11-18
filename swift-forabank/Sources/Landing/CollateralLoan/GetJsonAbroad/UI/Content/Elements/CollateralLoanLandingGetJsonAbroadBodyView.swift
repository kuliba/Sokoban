//
//  CollateralLoanLandingGetJsonAbroadBodyView.swift
//
//
//  Created by Valentin Ozerov on 14.11.2024.
//

import SwiftUI

public struct CollateralLoanLandingGetJsonAbroadBodyView: View {
    
    let backgroundImage: String
    let headerView: HeaderView
    let conditionsView: ConditionsView
    let config: Config
    let theme: Theme
    
    public var body: some View {

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
            
            Spacer()
        }
        .background(Color.clear)
        .frame(maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea(edges: .all)
    }
}

public extension CollateralLoanLandingGetJsonAbroadBodyView {
    
    typealias HeaderView = CollateralLoanLandingGetJsonAbroadHeaderView
    typealias ConditionsView = CollateralLoanLandingGetJsonAbroadConditionsView
    typealias Theme = CollateralLoanLandingGetJsonAbroadTheme
}
