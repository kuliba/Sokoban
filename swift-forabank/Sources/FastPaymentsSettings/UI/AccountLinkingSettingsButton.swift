//
//  AccountLinkingSettingsButton.swift
//  
//
//  Created by Igor Malyarov on 25.01.2024.
//

import SwiftUI

struct AccountLinkingSettingsButton: View {
    
    let action: () -> Void
    
    var body: some View {
        
        Button("Настройки привязки счета", action: action)
    }
}

struct AccountLinkingSettingsButton_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AccountLinkingSettingsButton {}
    }
}
