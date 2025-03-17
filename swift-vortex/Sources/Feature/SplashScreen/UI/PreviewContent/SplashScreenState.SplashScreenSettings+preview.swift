//
//  SplashScreenState.SplashScreenSettings+preview.swift
//
//
//  Created by Igor Malyarov on 13.03.2025.
//

extension SplashScreenState.Settings {
    
    static let preview: Self = .init(
        image: .morning,
        logo: .init(color: .blue, shadow: .logo),
        text: .init(color: .green, size: 24, value: "Hello, world!", shadow: .text),
        subtext: .init(color: .blue, size: 16, value: "A long quite boring subtext to kill user attention.", shadow: .subtext),
        footer: .init(color: .pink, shadow: .footer)
    )
}

extension SplashScreenState.Settings.Shadow {
    
    static let logo:    Self = .init(color: .init(hex: "FF0000"), opacity: 0.5, radius: 10, x: 10, y: 0)
    static let text:    Self = .init(color: .red, opacity: 1, radius: 12, x: 0, y: 4)
    static let subtext: Self = .init(color: .red, opacity: 1, radius: 12, x: 0, y: 4)
    static let footer:  Self = .init(color: .red, opacity: 1, radius: 0, x: 20, y: 20)
}

import SwiftUI

extension Color {
    
    init(hex: String) {
        
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        var int: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&int) else {
            self = Color.clear
            return
        }
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit) -> Expand to 24-bit
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            self = Color.clear
            return
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
    }
}
