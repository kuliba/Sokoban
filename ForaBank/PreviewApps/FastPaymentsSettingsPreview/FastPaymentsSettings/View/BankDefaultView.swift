//
//  BankDefaultView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 18.01.2024.
//

import FastPaymentsSettings
import SwiftUI

struct BankDefaultView: View {
    
    let bankDefault: UserPaymentSettings.BankDefault
    let action: () -> Void
    
    var body: some View {
        
        VStack {
            
            Text("Банк по умолчанию")
                .font(.subheadline)
            
            HStack {
                
                bankDefaultIcon(bankDefault)
                
                Text("ForaBank")
            }
        }
    }
    
    @ViewBuilder
    private func bankDefaultIcon(
        _ bankDefault: UserPaymentSettings.BankDefault
    ) -> some View {
        
        switch bankDefault {
        case .onDisabled:
            ToggleMockView(status: .active)
                .opacity(0.4)
            
        case .offEnabled:
            Button(action: action) {
                
                ToggleMockView(status: .inactive)
            }
            
        case .offDisabled:
            ToggleMockView(status: .active)
                .opacity(0.4)
        }
    }
}

struct BankDefaultView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 64) {
            
            bankDefaultView(.onDisabled)
            bankDefaultView(.offEnabled)
            bankDefaultView(.offDisabled)
        }
    }
    
    static func bankDefaultView(
        _ bankDefault: UserPaymentSettings.BankDefault
    ) -> some View {
        
        BankDefaultView(bankDefault: bankDefault, action: {})
    }
}
