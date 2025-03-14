//
//  SplashScreenContentViewConfig+preview.swift
//
//
//  Created by Igor Malyarov on 13.03.2025.
//

extension SplashScreenContentViewConfig {
    
    static let preview: Self = .init(
        edges: .init(top: 132, leading: 16, bottom: 0, trailing: 16),
        footer: .splashScreenName,
        footerVPadding: 48,
        logo: .splashScreenLogo,
        logoSize: 64,
        spacing: 32,
        subtextFont: .headline,
        textFont: .title
    )
}
