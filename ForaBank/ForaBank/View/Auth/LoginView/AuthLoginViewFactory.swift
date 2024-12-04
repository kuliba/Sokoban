//
//  AuthLoginViewFactory.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 04.12.2024.
//

import SwiftUI

final class AuthLoginViewFactory {
    
    func makeText(_ text: String) -> Text {
        
        Text(text)
    }

    func makeAlertButton(text: String, action: (() -> Void)?) -> Alert.Button {
        
        Alert.Button.default(Text(text), action: action)
    }
}
