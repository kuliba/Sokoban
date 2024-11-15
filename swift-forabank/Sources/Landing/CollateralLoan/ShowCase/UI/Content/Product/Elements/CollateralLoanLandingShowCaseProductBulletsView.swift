//
//  CollateralLoanLandingShowCaseProductBulletsView.swift
//  
//
//  Created by Valentin Ozerov on 15.10.2024.
//

import SwiftUI

public struct CollateralLoanLandingShowCaseProductBulletsView: View {
    
    public let header: String?
    public let bulletsData: [(Bool, String)]
    public let config: Config
    public let theme: Theme
    
    public init(header: String?, bulletsData: [(Bool, String)], config: Config, theme: Theme) {
        self.header = header
        self.bulletsData = bulletsData
        self.config = config
        self.theme = theme
    }
    
    public var body: some View {
        
        Group {
            
            headerView
            ListView(listItems: bulletsData, theme: theme, config: config)
        }
        .padding(.leading, config.paddings.outer.leading)
        .padding(.trailing, config.paddings.outer.trailing)
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

public extension CollateralLoanLandingShowCaseProductBulletsView {

    typealias Config = CollateralLoanLandingShowCaseViewConfig
    typealias Theme = CollateralLoanLandingShowCaseTheme
    typealias ListView = CollateralLoanLandingShowCaseBulletListView
}
