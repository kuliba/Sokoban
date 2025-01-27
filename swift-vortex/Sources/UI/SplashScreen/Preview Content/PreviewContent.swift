//
//  PreviewContent.swift
//
//
//  Created by Nikolay Pochekuev on 24.12.2024.
//

import SwiftUI


extension Image {
    
    static let backgroundImage: Self = {
        
        if let uiImage = UIImage(named: "MORNING2.jpg", in: .module, with: nil) {
            return .init(uiImage: uiImage)
        } else {
            print("ERROR!!")
            return .init(systemName: "plane")
        }
        
    }()
    static let logoImage: Self = .init(systemName: "info.circle")
}

extension SplashScreenState {
    
    static let preview: Self = .init(
        showSplash: true,
        background: .backgroundImage,
        logo: .logoImage,
        footer: "Vortex",
        greeting: "Добрый день!",
        animation: .easeInOut(duration: 1.7)
    )
}

extension SplashScreenDynamicConfig {
    
    static let preview: Self = .init(
        greeting: .init(textFont: .largeTitle.bold().italic(), textColor: .cyan),
        footer: .init(textFont: .largeTitle.weight(.black), textColor: .green)
    )
}

extension SplashScreenStaticConfig {
    
    static let preview: Self = .init(
        logoSize: .init(width: 60.0, height: 60.0),
        paddings: .init(top: 200, bottom: 100),
        spacing: 50,
        scaleEffect: .init(start: 1, end: 1.4)
    )
}
