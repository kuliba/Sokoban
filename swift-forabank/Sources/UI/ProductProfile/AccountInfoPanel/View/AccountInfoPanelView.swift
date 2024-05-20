//
//  AccountInfoPanelView.swift
//
//
//  Created by Andryusina Nataly on 04.03.2024.
//

import SwiftUI

struct AccountInfoPanelView: View {
    
    let buttons: [AccountInfoPanelState.PanelButton] // state
    let event: (ButtonEvent) -> Void
    let config: Config
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 24) {
            ForEach(buttons, id: \.self, content: buttonView)
        }
        .padding(.vertical, config.paddings.vertical)
        .frame(maxWidth: .infinity)
        .padding(.leading, config.paddings.leading)
        .padding(.trailing, config.paddings.trailing)
    }
    
    private func buttonView(button: AccountInfoPanelState.PanelButton) -> some View {
        
        Button(action: { event(button.event) }) {
            
            VStack(alignment: .leading) {
                
                HStack(spacing: config.paddings.leading) {
                    
                    iconView(button.iconType)
                    
                    Text(button.title)
                        .font(config.fonts.title)
                }
                .frame(height: config.sizes.buttonHeight)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                button.subtitle.map {
                    
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
        .foregroundColor(config.colors.foreground)
        .frame(maxWidth: .infinity)
    }
    
    private func iconView(_ type: Config.IconType) -> some View {
        
        config.images.imageByType(type)
            .frame(width: config.sizes.icon, height: config.sizes.icon)
            .padding(config.paddings.vertical)
            .background(Color(red: 0.96, green: 0.96, blue: 0.97))
            .cornerRadius(config.sizes.cornerRadius)
    }
}

struct AccountInfoPanelView_Previews: PreviewProvider {
    
    static var previews: some View {
       
        Group {
            
            AccountInfoPanelView(
                buttons: .previewRegular,
                event: { _ in },
                config: .preview
            )
            .previewDisplayName("Владелец карты + свои допки")

            
            AccountInfoPanelView(
                buttons: .previewAdditionalSelfNotOwner,
                event: { _ in },
                config: .preview
            )
            .previewDisplayName("Допка, основная на другого")


            AccountInfoPanelView(
                buttons: .previewAdditionalOther,
                event: { _ in },
                config: .preview
            )
            .previewDisplayName("Владелец основной, допка на другого")

        }
    }
}
