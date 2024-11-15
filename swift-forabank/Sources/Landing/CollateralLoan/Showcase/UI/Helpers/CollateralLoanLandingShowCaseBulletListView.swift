//
//  CollateralLoanLandingShowCaseBulletListView.swift
//
//
//  Created by Valentin Ozerov on 14.10.2024.
//

import SwiftUI
import Foundation

public struct CollateralLoanLandingShowCaseBulletListView: View {

    public let listItems: [(bullet: Bool, text: String)]
    public let bullet: String = "•"
    public let bulletWidth: CGFloat? = nil
    public let bulletAlignment: Alignment = .leading
    public let theme: Theme
    public let config: Config
    
    public init(listItems: [(bullet: Bool, text: String)], theme: Theme, config: Config) {
        self.listItems = listItems
        self.theme = theme
        self.config = config
    }
    
    public var body: some View {
        
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

public extension CollateralLoanLandingShowCaseBulletListView {

    typealias Theme = CollateralLoanLandingShowCaseTheme
    typealias Config = CollateralLoanLandingShowCaseViewConfig
}
