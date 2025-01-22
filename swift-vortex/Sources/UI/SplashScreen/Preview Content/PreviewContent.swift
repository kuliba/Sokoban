//
//  PreviewContent.swift
//  
//
//  Created by Nikolay Pochekuev on 24.12.2024.
//

import SwiftUI


extension Image {
    
    static let backgroundImage: Self = .init(systemName: "book")
    static let logoImage: Self = .init(systemName: "info.circle")
}

extension SplashScreenData {

    static let preview: Self = SplashScreenData(
        backgroundImage: .backgroundImage,
        logoImage: .logoImage,
        userNameText: "Иван Иванович",
        dayTimeText: "Добрый день!"
    )
}

extension SplashScreenConfig {
    
    static let `default`: Self = .init(
        textConfig: .init(textFont: .title, textColor: .black),
        sizes: .init(
            iconSize: 64
        ),
        paddings: .init(
            imageBottomPadding: 32,
            bottomPadding: 200
        ),
        defaultBackgroundImage: .backgroundImage,
        defaultLogoImage: .logoImage
    )
}

