//
//  CollateralLoanLandingShowCaseBulletListView.swift
//
//
//  Created by Valentin Ozerov on 14.10.2024.
//

import SwiftUI
import Foundation

struct CollateralLoanLandingShowCaseBulletListView: View {

    var listItems: [(bullet: Bool, text: String)]
    var bullet: String = "•"
    var bulletWidth: CGFloat? = nil
    var bulletAlignment: Alignment = .leading
    var theme: Theme
    var config: Config
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: config.bulletsView.itemSpacing) {
            ForEach(listItems, id: \.self.text) { data in
                HStack(alignment: .top) {
                    if data.bullet {
                        Text(bullet)
                            .frame(width: bulletWidth, alignment: bulletAlignment)
                    }
                    Text(data.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .font(config.fonts.body)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(theme.foregroundColor)
            }
        }
        .frame(height: config.bulletsView.height)
    }
}

extension CollateralLoanLandingShowCaseBulletListView {
    typealias Theme = CollateralLoanLandingShowCaseTheme
    typealias Config = CollateralLoanLandingShowCaseViewConfig
}
