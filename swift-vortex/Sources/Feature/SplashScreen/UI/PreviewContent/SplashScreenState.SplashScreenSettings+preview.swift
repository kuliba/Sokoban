//
//  SplashScreenState.SplashScreenSettings+preview.swift
//
//
//  Created by Igor Malyarov on 13.03.2025.
//

extension SplashScreenState.Settings {
    
    static let preview: Self = .init(
        image: .morning,
        bank: .init(color: .blue, shadow: .logo),
        name: .init(color: .pink, shadow: .name),
        text: .init(color: .green, size: 24, value: "Hello, world!", shadow: .text),
        subtext: .init(color: .blue, size: 16, value: "A long quite boring subtext to kill user attention.", shadow: .subtext)
    )
}

extension SplashScreenState.Settings.Shadow {
    
    static let logo: Self = .init(color: .black, opacity: 1, radius: 12, x: 0, y: 4)
    static let name: Self = .init(color: .black, opacity: 1, radius: 12, x: 0, y: 4)
    static let text: Self = .init(color: .black, opacity: 1, radius: 12, x: 0, y: 4)
    static let subtext: Self = .init(color: .black, opacity: 1, radius: 12, x: 0, y: 4)
}
