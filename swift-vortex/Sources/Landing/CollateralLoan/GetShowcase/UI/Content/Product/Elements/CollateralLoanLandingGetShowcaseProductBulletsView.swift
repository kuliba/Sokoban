//
//  CollateralLoanLandingGetShowcaseProductBulletsView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

import SwiftUI

struct CollateralLoanLandingGetShowcaseProductBulletsView: View {
    
    let header: String?
    let bulletsData: [(Bool, String)]
    let config: Config
    let theme: Theme
    
    var body: some View {
        
        Group {
            
            headerView
            ListView(listItems: bulletsData, theme: theme, config: config)
        }
        .padding(.leading, config.paddings.outer.leading)
        .padding(.trailing, config.paddings.outer.trailing)
        .padding(.top, config.paddings.outer.vertical)
    }
    
    @ViewBuilder
    var headerView: some View {

        header.map {

            Text($0)
                .font(config.fonts.body)
                .foregroundColor(theme.foregroundColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, config.paddings.top)
        }
    }
}

extension CollateralLoanLandingGetShowcaseProductBulletsView {

    typealias Config = CollateralLoanLandingGetShowcaseViewConfig
    typealias Theme = CollateralLoanLandingGetShowcaseTheme
    typealias ListView = CollateralLoanLandingGetShowcaseBulletListView
}
