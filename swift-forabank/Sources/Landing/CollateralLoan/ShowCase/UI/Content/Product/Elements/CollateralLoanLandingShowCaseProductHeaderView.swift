//
//  CollateralLoanLandingShowCaseProductHeaderView.swift
//
//
//  Created by Valentin Ozerov on 14.10.2024.
//

import SwiftUI

struct CollateralLoanLandingShowCaseProductHeaderView: View {
    
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

extension CollateralLoanLandingShowCaseProductHeaderView {
    
    typealias Config = CollateralLoanLandingShowCaseViewConfig
    typealias Theme = CollateralLoanLandingShowCaseTheme
}
