//
//  SplashScreenContentViewConfig+preview.swift
//  
//
//  Created by Igor Malyarov on 13.03.2025.
//

extension SplashScreenContentViewConfig {
    
    static let preview: Self = .init(
        logo: .splashScreenLogo,
        logoSize: 64,
        name: .splashScreenName,
        nameVPadding: 48,
        spacing: 32,
        textFont: .title,
        subtextFont: .headline,
        edges: .init(top: 132, leading: 16, bottom: 0, trailing: 16)
    )
}
