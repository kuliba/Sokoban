//
//  ThreeButtonsView.swift
//
//
//  Created by Andryusina Nataly on 31.01.2024.
//

import SwiftUI

struct ThreeButtonsView: View { // верстка
    
    let buttons: [CardGuardianState._Button] // state
    let event: (CardGuardian.ButtonTapped) -> Void
    let config: CardGuardian.Config
    
    var body: some View {
        
        VStack(alignment: .leading) {
            ForEach(buttons, id: \.self, content: buttonView)
        }
        .padding(.vertical, config.paddings.vertical)
        .frame(maxWidth: .infinity)
        .padding(.leading, config.paddings.leading)
        .padding(.trailing, config.paddings.trailing)
        .border(.green)
    }
    
    private func buttonView(button: CardGuardianState._Button) -> some View {
        
        Button(action: {
            event(button.event)})  {
                HStack(spacing: config.paddings.leading) {
                    iconView(button.iconType)
                    VStack(alignment: .leading) {
                        Text(button.title)
                            .font(config.fonts.title)
                        button.subtitle.map {
                            Text($0)
                                .font(config.fonts.subtitle)
                                .foregroundColor(config.colors.subtitle)
                        }
                    }
                    Spacer()
                }
                .frame(height: config.sizes.buttonHeight)
            }
            .foregroundColor(config.colors.foreground)
            .frame(maxWidth: .infinity)
    }
    
    private func iconView(_ type: CardGuardian.Config.IconType) -> some View {
        HStack {
            config.images.imageByType(type)
                .frame(width: config.sizes.icon, height: config.sizes.icon)
        }
        .padding(config.paddings.vertical)
        .background(Color(red: 0.96, green: 0.96, blue: 0.97))
        .cornerRadius(config.sizes.cornerRadius)
    }
}

struct ThreeButtonsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ThreeButtonsView(
            buttons: .preview,
            event: { _ in },
            config: .preview
        )
    }
}
