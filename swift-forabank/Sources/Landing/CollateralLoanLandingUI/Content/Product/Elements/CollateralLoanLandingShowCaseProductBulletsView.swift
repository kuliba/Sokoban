//
//  CollateralLoanLandingShowCaseProductBulletsView.swift
//  
//
//  Created by Valentin Ozerov on 15.10.2024.
//

import SwiftUI

struct CollateralLoanLandingShowCaseProductBulletsView: View {
    
    let header: String?
    let bulletsData: [(Bool, String)]
    let config: Config
    let theme: Theme
    
    var body: some View {
        
        Group {
            header.map {
                Text($0)
                    .font(config.fonts.body)
                    .foregroundColor(theme.foregroundColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, config.paddings.top)
            }
            CollateralLoanLandingShowCaseBulletListView(listItems: bulletsData, theme: theme, config: config)
        }
        .padding(.leading, config.paddings.outer.leading)
        .padding(.trailing, config.paddings.outer.trailing)
    }
}

extension CollateralLoanLandingShowCaseProductBulletsView {

    typealias Config = CollateralLoanLandingShowCaseViewConfig
    typealias Theme = CollateralLoanLandingShowCaseTheme
}
