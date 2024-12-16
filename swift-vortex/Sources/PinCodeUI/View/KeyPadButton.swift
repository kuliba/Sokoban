//
//  KeyPadButton.swift
//  
//
//  Created by Andryusina Nataly on 10.07.2023.
//

import SwiftUI

struct KeyPadButton: View {
    
    let buttonInfo: ButtonInfo
    let config: ButtonConfig
    
    var body: some View {
        
        Button(action: { self.action(self.buttonInfo) }) {
            
            ZStack {
               
                if let image = buttonInfo.image {
                    
                    image
                        .fixedSize()
                        .frame(alignment: .center)
                } else {
                    
                    Circle()
                        .foregroundColor(config.buttonColor)
                }
                Text(buttonInfo.value)
                    .font(config.font)
                    .foregroundColor(config.textColor)
            }
        }
        .frame(width: 80, height: 80)

    }

    enum ActionKey: EnvironmentKey {
        static var defaultValue: (ButtonInfo) -> Void { { _ in } }
    }

    @Environment(\.keyPadButtonAction) var action: (ButtonInfo) -> Void
}

extension EnvironmentValues {
    
    var keyPadButtonAction: (ButtonInfo) -> Void {
        
        get { self[KeyPadButton.ActionKey.self] }
        set { self[KeyPadButton.ActionKey.self] = newValue }
    }
}

struct KeyPadButton_Previews: PreviewProvider {
    
    static var previews: some View {
        
        KeyPadButton(
            buttonInfo: .init(
                value: "8",
                image: nil,
                type: .digit),
            config: .init(
                font: .title,
                textColor: .black,
                buttonColor: .gray
            )
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
