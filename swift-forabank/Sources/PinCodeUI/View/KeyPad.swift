//
//  KeyPad.swift
//  
//
//  Created by Andryusina Nataly on 10.07.2023.
//

import SwiftUI
import AudioToolbox

public struct KeyPad: View {
    
    @Binding var string: String
    let config: ButtonConfig
    let deleteImage: Image?
    let pinCodeLength: Int
    let action: () -> Void
    
    public init(
        string: Binding<String>,
        config: ButtonConfig,
        deleteImage: Image?,
        pinCodeLength: Int,
        action: @escaping () -> Void
    ) {
        
        self._string = string
        self.config = config
        self.deleteImage = deleteImage
        self.pinCodeLength = pinCodeLength
        self.action = action
    }
    
    public var body: some View {
        
        VStack(spacing: 20) {
            
            KeyPadRow(keys: .keys123, config: config)
            KeyPadRow(keys: .keys456, config: config)
            KeyPadRow(keys: .keys789, config: config)
            KeyPadRow(keys: [.key0, .init(value: "", image: deleteImage, type: .delete)], config: config)
        }.environment(\.keyPadButtonAction, self.keyWasPressed(_:))
    }
    
    private func keyWasPressed(_ key: ButtonInfo) {
        
        switch key.type {
            
        case .delete:
            if string.isEmpty { string = "" }
            else {
                
                string.removeLast()
                AudioServicesPlaySystemSound(1155)
            }
        default:
            if string.count < pinCodeLength {
                
                string += key.value
                AudioServicesPlaySystemSound(1104)
            }
        }
        action()
    }
}

