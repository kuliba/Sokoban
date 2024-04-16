//
//  AccountLinkingSettingsButton.swift
//
//
//  Created by Igor Malyarov on 25.01.2024.
//

import SwiftUI

struct AccountLinkingSettingsButton: View {
    
    let action: () -> Void
    let config: AccountLinkingConfig
    
    var body: some View {
        
        Button(action: action) {
            
            HStack(spacing: 8) {
                
                config.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .frame(width: 32, height: 32)
                
                "Настройки привязки счета".text(withConfig: config.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .foregroundColor(config.title.textColor)
    }
}

struct AccountLinkingSettingsButton_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AccountLinkingSettingsButton(
            action: {},
            config: .preview
        )
    }
}
