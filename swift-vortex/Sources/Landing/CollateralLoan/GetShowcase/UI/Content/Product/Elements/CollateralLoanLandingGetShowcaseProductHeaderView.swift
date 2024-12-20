//
//  CollateralLoanLandingGetShowcaseProductHeaderView.swift
//
//
//  Created by Valentin Ozerov on 14.10.2024.
//

import SwiftUI

struct CollateralLoanLandingGetShowcaseProductHeaderView: View {
    
    let title: String
    let config: Config
    let theme: Theme

    var body: some View {

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

extension CollateralLoanLandingGetShowcaseProductHeaderView {
    
    typealias Config = CollateralLoanLandingGetShowcaseViewConfig
    typealias Theme = CollateralLoanLandingGetShowcaseTheme
}
