//
//  ActiveContractView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 12.01.2024.
//

import FastPaymentsSettings
import SwiftUI

struct ActiveContractView: View {
    
    let contractDetails: UserPaymentSettings.ContractDetails
    let actionOff: () -> Void
    let setBankDefault: () -> Void
    
    var body: some View {
        
        VStack(spacing: 64) {
            
            VStack(spacing: 16) {
                
                Button("Выключить переводы СБП", action: actionOff)
                
                HStack(spacing: 16) {
                    
                    Text("Переводы включены")
                        .font(.subheadline)
                    
                    ToggleMockView(status: .active)
                }
            }
            
            bankDefaultView(contractDetails.bankDefault)
        }
    }
    
    @ViewBuilder
    private func bankDefaultView(
        _ bankDefault: UserPaymentSettings.BankDefault
    ) -> some View {
        
        HStack {
            bankDefaultIcon(bankDefault)
            
            Text("ForaBank")
        }
    }
    
    @ViewBuilder
    private func bankDefaultIcon(
        _ bankDefault: UserPaymentSettings.BankDefault
    ) -> some View {
        
        switch bankDefault {
        case .onDisabled:
            Color.green.opacity(0.3)
                .clipShape(.circle)
                .frame(width: 32, height: 32)
            
        case .offEnabled:
            Button(action: setBankDefault) {
                Color.black
                    .clipShape(.circle)
                    .frame(width: 32, height: 32)
            }
            
        case .offDisabled:
            Color.black.opacity(0.4)
                .clipShape(.circle)
                .frame(width: 32, height: 32)
        }
    }
}

struct ActiveContractView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ActiveContractView(
            contractDetails: .preview(),
            actionOff:  {},
            setBankDefault: {}
        )
    }
}
