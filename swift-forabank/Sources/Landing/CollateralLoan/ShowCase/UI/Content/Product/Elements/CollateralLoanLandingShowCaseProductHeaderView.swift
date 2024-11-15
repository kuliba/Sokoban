//
//  CollateralLoanLandingShowCaseProductHeaderView.swift
//
//
//  Created by Valentin Ozerov on 14.10.2024.
//

import SwiftUI

public struct CollateralLoanLandingShowCaseProductHeaderView: View {
    
    public let title: String
    public let config: Config
    public let theme: Theme

    public  init(title: String, config: Config, theme: Theme) {
        self.title = title
        self.config = config
        self.theme = theme
    }
    
    public var body: some View {

        Text(title)
            .multilineTextAlignment(.leading)
            .foregroundColor(theme.foregroundColor)
            .font(config.fonts.header)
            .frame(
                maxWidth: .infinity,
                idealHeight: config.headerView.height,
                maxHeight: config.headerView.height,
                alignment: .leading
            )
            .padding(.top, config.paddings.top)
            .padding(.leading, config.paddings.outer.leading)
            .padding(.trailing, config.paddings.outer.trailing)
    }
}

public extension CollateralLoanLandingShowCaseProductHeaderView {
    
    typealias Config = CollateralLoanLandingShowCaseViewConfig
    typealias Theme = CollateralLoanLandingShowCaseTheme
}
