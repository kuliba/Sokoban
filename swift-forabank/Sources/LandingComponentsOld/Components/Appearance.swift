//
//  File.swift
//  
//
//  Created by Dmitry Martynov on 25.07.2023.
//

import SwiftUI

enum ColorProperty: String, Decodable {
    
    case grey = "GREY"
    case white = "WHITE"
    case black = "BLACK"
}

enum ButtonStyleProperty: String, Decodable {
    
    case whiteRed = "whiteRed"
    case blackWhite = "blackWhite"
}

enum ActionType: String, Decodable {
    
    case goToMain = "goToMain"
}

struct PushButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}
