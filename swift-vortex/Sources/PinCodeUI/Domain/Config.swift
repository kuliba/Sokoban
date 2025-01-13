//
//  Config.swift
//  
//
//  Created by Andryusina Nataly on 14.07.2023.
//

extension PinCodeView {
    
    public struct Config: Equatable {
        
        public let buttonConfig: ButtonConfig
        public let pinCodeConfig: PinCodeConfig
        
        public init(
            buttonConfig: ButtonConfig,
            pinCodeConfig: PinCodeConfig
        ) {
            
            self.buttonConfig = buttonConfig
            self.pinCodeConfig = pinCodeConfig
        }
    }
}

extension PinCodeView.Config {
    
    static let defaultConfig: Self = .init(
        buttonConfig: .defaultConfig,
        pinCodeConfig: .defaultValue)
}
