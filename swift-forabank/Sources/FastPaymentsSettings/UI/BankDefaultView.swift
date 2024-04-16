//
//  BankDefaultView.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

import SwiftUI

struct BankDefaultView: View {
    
    let bankDefault: BankDefault
    let action: () -> Void
    let config: BankDefaultConfig
    
    var body: some View {
        
        HStack {
         
            icon()
            label()
            Spacer()
            bankDefaultToggle(bankDefault, config.toggleConfig)
        }
    }
    
    private func icon() -> some View {
        
        ZStack {
            
            config.logo.backgroundColor
                .clipShape(Circle())
            
            config.logo.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
        }
        .frame(width: 32, height: 32)
    }

    private func label() -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            "Банк по умолчанию".text(withConfig: config.subtitle)
            "Фора-банк".text(withConfig: config.title)
        }
    }
    
    @ViewBuilder
    private func bankDefaultToggle(
        _ bankDefault: BankDefault,
        _ config: BankDefaultConfig.ToggleConfig
    ) -> some View {
        
        switch bankDefault {
        case .onDisabled:
            ToggleMockView(
                status: .on(.disabled),
                color: config.onDisabled.toggleColor
            )
            
        case .offEnabled:
            VStack(alignment: .leading) {
                
                Button(action: action) {
            
                    ToggleMockView(
                        status: .off(.enabled),
                        color: config.offEnabled.toggleColor
                    )
                }
            }
            
        case .offDisabled:
            ToggleMockView(
                status: .off(.disabled),
                color: config.offDisabled.toggleColor
            )
        }
    }
}

extension BankDefaultView {
    
    typealias BankDefault = UserPaymentSettings.GetBankDefaultResponse.BankDefault
}

struct BankDefaultView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            bankDefaultView(.onDisabled)
            bankDefaultView(.offEnabled)
            bankDefaultView(.offDisabled)
        }
    }
    
    static func bankDefaultView(
        _ bankDefault: BankDefaultView.BankDefault
    ) -> some View {
        
        BankDefaultView(
            bankDefault: bankDefault,
            action: {},
            config: .preview
        )
    }
}
