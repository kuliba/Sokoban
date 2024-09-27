//
//  ButtonsContainer.swift
//
//
//  Created by Дмитрий Савушкин on 20.09.2024.
//

import SwiftUI

public struct ButtonsContainer: View {
    
    let applyAction: () -> Void
    let clearOptionsAction: () -> Void
    let isAvailable: Bool
    let config: Config
    
    public init(
        applyAction: @escaping () -> Void,
        clearOptionsAction: @escaping () -> Void,
        isAvailable: Bool,
        config: Config
    ) {
        self.applyAction = applyAction
        self.clearOptionsAction = clearOptionsAction
        self.isAvailable = isAvailable
        self.config = config
    }
    
    public var body: some View {
        
        HStack(spacing: 8) {
            
            BottomButton(
                title: config.clearButtonTitle,
                action: clearOptionsAction,
                isAvailable: true,
                config: .init(
                    background: config.disableButtonBackground,
                    foreground: .black
                ))
            
            BottomButton(
                title: config.applyButtonTitle,
                action: applyAction, 
                isAvailable: isAvailable,
                config: .init(
                    background: isAvailable ? .red : config.disableButtonBackground,
                    foreground: isAvailable ? .white : .black
                ))
            .allowsHitTesting(isAvailable)
        }
    }
    
    public struct Config {
        
        let clearButtonTitle: String
        let applyButtonTitle: String
        let applyButtonColors: ApplyButtonColor?
        let disableButtonBackground: Color
        
        public init(
            clearButtonTitle: String,
            applyButtonTitle: String,
            applyButtonColors: ApplyButtonColor? = nil,
            disableButtonBackground: Color
        ) {
            self.clearButtonTitle = clearButtonTitle
            self.applyButtonTitle = applyButtonTitle
            self.applyButtonColors = applyButtonColors
            self.disableButtonBackground = disableButtonBackground
        }
        
        public struct ApplyButtonColor {
            
            let bgColor: Color
            let fgColor: Color
        }
    }
    
    struct BottomButton: View {
        
        typealias Config = ButtonConfig
        
        let title: String
        let action: () -> Void
        let isAvailable: Bool
        let config: Config
        
        var body: some View {
            
            Button(action: action) {
                
                Text(title)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .foregroundColor(config.foreground)
                    .background(config.background)
                    .cornerRadius(12)
                    .font(.system(size: 18))
            }
        }
        
        struct ButtonConfig {
            
            let background: Color
            let foreground: Color
        }
    }
}
