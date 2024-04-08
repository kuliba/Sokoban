//
//  File.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 08.04.2024.
//

import SwiftUI

struct PanelView: View {
    
    let buttons: [PanelButton]
    let config: Config = .default
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: config.spacings.vstack) {
            ForEach(buttons, id: \.config.title, content: buttonView)
        }
        .frame(maxWidth: .infinity)
        .padding(.leading, config.paddings.leading)
        .padding(.trailing, config.paddings.trailing)
    }
    
    private func buttonView(button: PanelButton) -> some View {
        
        Button(action: button.event) {
            
            VStack(alignment: .leading, spacing: 0) {
                
                HStack(spacing: config.spacings.hstack) {
                    
                    button.config.icon
                        .frame(width: config.height, height: config.height)
                        .background(config.colors.background)
                        .cornerRadius(config.height/2)
                    
                    Text(button.config.title)
                        .font(config.fonts.title)
                }
                .frame(height: config.height)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                button.config.subtitle.map {
                    
                    Text($0)
                        .font(config.fonts.subtitle)
                        .foregroundColor(config.colors.subtitle)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, config.paddings.subtitleLeading)
                }
            }
        }
        .buttonStyle(PushButtonStyle())
        .foregroundColor(config.colors.title)
        .frame(maxWidth: .infinity)
    }
}
