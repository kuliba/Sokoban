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
    
    static let previewPhaseOne: Self = .init(
        state: .start,
        background: .backgroundImage,
        logo: .logoImage,
        footer: "Vortex",
        greeting: "Добрый день!",
        message: "С наступающим Вас Новым годом! Это время ожидания чудес, и пусть оно будет наполнено теплом и любовью близких! Здоровья,  мира,  добра, счастья и финансового благополучия Вам и Вашим близких!",
        animation: .easeInOut(duration: 1.2)
    )
    
    static let previewPhaseTwo: Self = .init(
        state: .splash,
        background: .backgroundImage,
        logo: .logoImage,
        footer: "Vortex",
        greeting: "Добрый день!",
        message: "С наступающим Вас Новым годом! Это время ожидания чудес, и пусть оно будет наполнено теплом и любовью близких! Здоровья,  мира,  добра, счастья и финансового благополучия Вам и Вашим близких!",
        animation: .easeInOut(duration: 1.2)
    )
}

extension SplashScreenDynamicConfig {
    
    static let preview: Self = .init(
        greeting: .init(textFont: .largeTitle.bold().italic(), textColor: .cyan),
        message: .init(textFont: .callout.italic(), textColor: .red),
        footer: .init(textFont: .largeTitle.weight(.black), textColor: .green)
    )
}

extension SplashScreenStaticConfig {
    
    static let preview: Self = .init(
        logoSize: .init(width: 60.0, height: 60.0),
        paddings: .init(top: 200, bottom: 100),
        spacing: 50,
        scaleEffect: .init(start: 1, end: 1.6)
    )
}
